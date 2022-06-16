process generate_manifests {
    tag {"$redsheet"}

    input:
	val flag
    val user_id
    path(redsheet)
    path(manifestdir)
	each samplename

    output:
    path("*json")

    script:
    """
	generate_manifests_for_outputs.py \
	--redsheet ${redsheet} \
	--manifestdir ${manifestdir} \
	--samplename ${samplename} \
    --userid ${user_id}
    """
}