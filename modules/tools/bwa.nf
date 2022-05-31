process bwamem {
    tag {"$sampleID"}

    input:
    tuple val(sampleID), file(read1), file(read2)

    output:
    tuple val(sampleID), file("*bam")

    script:
    """
    bwa mem ${task.ext.args} \
    ${params.reference} $read1 $read2 | samtools view -hb | samtools sort -o ${sampleID}.sorted.bam
    """
}
