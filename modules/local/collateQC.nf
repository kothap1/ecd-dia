process collateQC {
	tag {"$redsheet_name"}
    afterScript "for sample in ${samplenames}; do cp collated_qc.html batchqc_\${sample}.html; cp collated_qc.xlsx batchqc_\${sample}.xlsx; done; rm collated_qc*"

    input:
	val redsheet_name
    path("QC_metrics/fastp/*")
	path("QC_metrics/mosdepth/*")
	path("QC_metrics/picard_CollectInsertSizeMetrics/*")
	path("QC_metrics/picard_CollectMultipleMetrics/*")
    val samplenames

    output:
	val true, emit: collation_completed
	file('*{html,xlsx}')

    script:
	samplenames = samplenames.join(' ').trim()
	def script = "${projectDir}/" + "ipynbs/" + "QC_metric_collation.ipynb"
    """
	cp $script .
	echo "_ --redsheet ${params.redsheet} --batch_path ./QC_metrics/ --xlsx collated_qc.xlsx" > .config_ipynb
	jupyter nbconvert --execute QC_metric_collation.ipynb --to html --no-input --output collated_qc.html --output-dir .
    """
}