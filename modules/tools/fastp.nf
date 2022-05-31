process fastp {
    tag {"$sampleID"}
   
    input:
    tuple val(sampleID), file(read1), file(read2)

    output:
    tuple val(sampleID), file("${sampleID}_R1.trimmed.fq.gz"), file("${sampleID}_R2.trimmed.fq.gz"), emit: trimmed_fqs
    path("*json"), emit: fastp_qc

    script:
    """
    fastp -i $read1 -I $read2 \
    -o ${sampleID}_R1.trimmed.fq.gz -O ${sampleID}_R2.trimmed.fq.gz \
    -h ${sampleID}.html -j ${sampleID}.json -R "fastp report for sample: ${sampleID}" \
    ${task.ext.args}
    """
}