process multiqc {
    tag {"$redsheet_name"}
    afterScript "for sample in ${samplenames}; do cp multiqc_report.html multiqc_\${sample}.html; done; rm multiqc_report.html"

    input:
    val redsheet_name
    path(multiqc_config)
    path("fastp/*")
    val samplenames

    output:
    path("*html")

    script:
    samplenames = samplenames.join(' ').trim()
    """
	multiqc .
    """
}