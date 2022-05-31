process parseManifests {
    tag {"$samples"}

    input:
    val(samples)

    output:
    path('*csv')

    script:
    """
    parse_manifests.py \
    ${task.ext.args}
    """
}