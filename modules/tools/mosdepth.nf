process mosdepth {
    tag {"$sampleID"}

    input:
    tuple val(sampleID), file(bam), file(bai)

    output:
    tuple val(sampleID), file("*.txt")

    script:
    """
    mosdepth ${task.ext.args} $sampleID $bam
    """
}