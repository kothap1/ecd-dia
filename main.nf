nextflow.enable.dsl=2

include { parseManifests } from './modules/local/parseManifests'
include { mergeFastqs } from './modules/local/mergeFastqs'
include { fastp } from './modules/tools/fastp'
include { bwamem } from './modules/tools/bwa'
include { samtools_filter } from './modules/tools/samtools'
include { sambamba_markdup; sambamba_merge } from './modules/tools/sambamba'
include { mosdepth } from './modules/tools/mosdepth'
include { picard_CollectInsertSizeMetrics; picard_CollectMultipleMetrics } from './modules/tools/picard'
include { collateQC } from './modules/local/collateQC'
include { multiqc } from './modules/local/multiqc'
include { generate_manifests } from './modules/local/generateManifests'

log.info """
         EARLY  CANCER  DETECTION  PIPELINE    
         ===================================
         reference        : ${params.reference}
         sample(s)        : ${ params.samples ? params.samples : params.samplename ? "${params.samplename}\n         manifestdir      : ${params.manifestdir}" : "${params.redsheet}\n         manifestdir      : ${params.manifestdir}\n         sampledir        : ${params.sampledir}"}
         outdir           : ${params.outdir}
         merging          : ${params.merge_FASTQs}
         skip filtering   : ${params.skip_filter}
         User             : ${params.user_id}
         """
         .stripIndent()


workflow {
    multiqc_config = file("$projectDir/assets/multiqc_config.yml")
    /*
    Check mandatory parameters
    */
    def valid_params = [
        fastq_merging  : ['no-merging','per-lane','per-sequencer'],
        picard_modules :  ['CollectAlignmentSummaryMetrics', 'CollectInsertSizeMetrics', 'QualityScoreDistribution', 'MeanQualityByCycle', 'CollectBaseDistributionByCycle', 'CollectGcBiasMetrics', 'RnaSeqMetrics', 'CollectSequencingArtifactMetrics', 'CollectQualityYieldMetrics'],
    ]

    CheckParams.checkRequiredParams(params, log, valid_params)

    if(params.samples) {
        samples = file(params.samples, checkIfExists: true)
        if (samples.isEmpty()) {exit 1, "Input file is empty: ${samples.getName()}"}
    }

    if(params.redsheet) {
        redsheet = file(params.redsheet, checkIfExists: true)
        if (redsheet.isEmpty()) {exit 1, "Input redsheet is empty: ${redsheet.getName()}"}
    }

    reference = file(params.reference, checkIfExists: true)
    if (reference.isEmpty()) { exit 1, "Reference FASTA is empty: ${reference.getName()}" }

    /*
    Parse Manifests to get sample information
    */
    if (params.samplename && params.manifestdir) {
        parseManifests(params.samplename)
    } else if (params.redsheet && (params.manifestdir || params.sampledir)) {
        parseManifests(params.redsheet)
    } else if (params.samples) {
        parseManifests(params.samples)
    }

    /*
    Main workflow
    */
    
    // Upfront merging
    if(params.merge_FASTQs) {
        parseManifests.out
        .splitCsv(header: true, sep: '\t')
        .map { row-> tuple(row.sampleID, file(row.read1), file(row.read2)) }
        .groupTuple(by: [0])
        .set { ch_reads }

        ch_samples = mergeFastqs(ch_reads)
    } else if (!params.merge_FASTQs) {
        parseManifests.out
        .splitCsv(header: true, sep: '\t')
        .map { row-> tuple(row.sampleID, file(row.read1), file(row.read2)) }
        .set { ch_samples }
    }


    ch_unfiltered_bam = Channel.empty()
    ch_markdup_bam = Channel.empty()

    // FASTQ Quality control and trimming
    fastp(ch_samples)

    // Mapping
    bwamem(fastp.out.trimmed_fqs)
    ch_unfiltered_bam = bwamem.out

    // Skip BAM files which are empty -- {{{
    ch_unfiltered_bam
    .map { sampleID, bam -> [ sampleID ] + CheckParams.checkBamSize(sampleID, bam) }
    .branch { sampleID, bam, size, pass ->
        pass: pass
        fail: !pass 
    }
    .set { ch_unfiltered_bam_check }

    ch_unfiltered_bam_check.fail
        .subscribe {sampleID, bam, size, pass -> CheckParams.emptyBAMWarn(sampleID, bam, size, log) }

    // Merge BAMs
    ch_unfiltered_bam_check.pass
        .map { it -> [ (it[0] =~ /^(.+?)_S\d+(?=_(?:L00[0-4]|\d{4,}))/)[0][0], it[1]] }
        .groupTuple(by: [0])
        .set { ch_merge_bams }


    sambamba_merge(ch_merge_bams)
    ch_unfiltered_bam_checkpass = sambamba_merge.out.map { it -> [it[0], it[1]] }
    // }}} ---

    //Sort, filter and index (if filter is enabled)
    if (!params.skip_filter) {
        samtools_filter(ch_unfiltered_bam_checkpass)
        ch_input_markdup = samtools_filter.out.filtered_bams
    } else {
        ch_input_markdup = ch_unfiltered_bam_checkpass
    }

    //Mark duplicates
    sambamba_markdup(ch_input_markdup)
    ch_markdup_bam = sambamba_markdup.out

    // Calculate coverage
    mosdepth(ch_markdup_bam)

    // Fragment length distribution
    picard_CollectInsertSizeMetrics(ch_markdup_bam.map {it -> [it[0], it[1]]})

    // Whole genome mapping metrics
    picard_CollectMultipleMetrics(ch_markdup_bam.map {it -> [it[0], it[1]]})

    ch_sample_names = ch_markdup_bam.map {it -> it[0]}.toList()

    // Collate QC metrics for all samples
    if (params.redsheet) {
        collateQC (
            redsheet.getName().split("\\.")[0],
            fastp.out.fastp_qc.collect(),
            mosdepth.out.collect {it[1]},
            picard_CollectInsertSizeMetrics.out.collect {it[1]},
            picard_CollectMultipleMetrics.out.collect {it[1]},
            ch_sample_names
        )
    }

    // MultiQC report for output of fastp
    multiqc (
        redsheet.getName().split("\\.")[0],
        multiqc_config,
        fastp.out.fastp_qc.collect(),
        ch_sample_names
    )

    // Create manifests for output files - (only for the files that are retained)
    if (redsheet && params.manifestdir) {
        generate_manifests(
            collateQC.out.collation_completed,
            params.user_id,
            redsheet,
            params.manifestdir,
            ch_sample_names
        )
    }
}

/*
Introspection
*/
workflow.onComplete {
    log.info """
            Pipeline execution summary
            ===================================   
            Completed at : ${workflow.complete}
            Duration     : ${workflow.duration}
            Success      : ${workflow.success}
            Exit status  : ${workflow.exitStatus}
            Error report : ${workflow.errorReport ?: 'No errors'}
            """
    .stripIndent()
}
