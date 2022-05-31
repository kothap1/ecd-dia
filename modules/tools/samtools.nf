process samtools_filter {
    tag {"$sampleID"}

    input:
    tuple val(sampleID), file(bam)

    output:
    tuple val(sampleID), file("*bam"), emit: filtered_bams
    file("*bai")

    script:
    """
    samtools view -b ${task.ext.args} $bam | samtools sort -o ${sampleID}.sorted.filtered.bam
    samtools index ${sampleID}.sorted.filtered.bam
    """
}

