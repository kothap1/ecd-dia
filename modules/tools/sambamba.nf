process sambamba_markdup {
    tag {"$sampleID"}
    
    input:
    tuple val(sampleID), file(bam)

    output:
    tuple val(sampleID), file("*.markeddup.bam"), file("*bai")

    script:
    """
    sambamba markdup ${task.ext.args} $bam ${sampleID}.markeddup.bam
    """
}

process sambamba_merge {
    tag {"$sampleID"}
    
    input:
    tuple val(sampleID), file(bam)

    output:
    tuple val(sampleID), file("*.merged.bam"), file("*bai")

    script:
    """
    sambamba merge ${task.ext.args} ${sampleID}.merged.bam $bam 
    """
}