process picard_CollectInsertSizeMetrics {
    tag {"$sampleID"}

    input:
    tuple val(sampleID), file(bam)

    output:
    tuple val(sampleID), file('*.{txt,pdf}')

    script:
    """
    picard CollectInsertSizeMetrics  \
    -I $bam \
    -O ${sampleID}.insert_size_metrics.txt \
    -H ${sampleID}.insert_size_histogram.pdf \
    ${task.ext.args}
    """
}

process picard_CollectMultipleMetrics {
    tag {"$sampleID"}

    input:
    tuple val(sampleID), file(bam)

    output:
    tuple val(sampleID), file('*')

    script:
    // Read list of metrics-to-collect from the config and transform appropriately to use in the final command
    programs_list = []
    for (param in params.MULTI_METRICS_PROGRAMS.split(',')) { programs_list << "--PROGRAM $param" }
    PROGRAMS = programs_list.join(' ').trim()

    """
    picard CollectMultipleMetrics  \
    -I $bam \
    -O ${sampleID} \
    -R ${params.reference} \
    --PROGRAM null \
    ${PROGRAMS} \
    ${task.ext.args}
    """
}