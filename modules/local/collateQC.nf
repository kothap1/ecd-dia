process collateQC {
	tag {"$redsheet_name"}

    input:
	val redsheet_name
    path("QC_metrics/fastp/*")
	path("QC_metrics/mosdepth/*")
	path("QC_metrics/picard_CollectInsertSizeMetrics/*")
	path("QC_metrics/picard_CollectMultipleMetrics/*")

    output:
	file('*{html,xlsx}')

    script:
	def script = "${projectDir}/" + "ipynbs/" + "QC_metric_collation.ipynb"
    """
	cp $script .
	echo "_ --redsheet ${params.redsheet} --batch_path ./QC_metrics/ --xlsx collated_qc_${redsheet_name}.xlsx" > .config_ipynb
	jupyter nbconvert --execute QC_metric_collation.ipynb --to html --no-input --output collated_qc_${redsheet_name}.html --output-dir .
    """
}