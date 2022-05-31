process mergeFastqs {
    tag {"$sampleID"}

    input:
    tuple val(sampleID), path("${sampleID}_R1_*.fastq.gz"), path("${sampleID}_R2_*.fastq.gz")

    output:
    tuple val(sampleID), path("*R1.merged.fastq.gz"),  path("*R2.merged.fastq.gz")

    script:
    """
    cat ${sampleID}_R1_*.fastq.gz > ${sampleID}_R1.merged.fastq.gz
    cat ${sampleID}_R2_*.fastq.gz > ${sampleID}_R2.merged.fastq.gz
    """
}
