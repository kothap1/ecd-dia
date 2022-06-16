#!/bin/bash

# REDCAP HPC
# export PATH="/scratchfsx/early_cancer_detection/environment/nxf_env/bin:$PATH"
# export PATH="/scratchfsx/early_cancer_detection/environment/setup/multiqc/bin:$PATH"
# export LD_LIBRARY_PATH="/scratchfsx/early_cancer_detection/environment/nxf_env/lib:$LD_LIBRARY_PATH"
# export PATH="/scratchfsx/early_cancer_detection/environment/setup/python3/bin:$PATH"

# SC1 cluster
# export PATH="/sc1/groups/bfx-red/projects/neusomatic/strand/benchmarking/earlycancer/environment/early-cancer-detection/bin:$PATH"
# export PATH="/sc1/groups/bfx-red/projects/neusomatic/strand/benchmarking/earlycancer/environment/python3/bin:$PATH"
# export LD_LIBRARY_PATH="/sc1/groups/bfx-red/projects/neusomatic/strand/benchmarking/earlycancer/environment/early-cancer-detection/lib/:$LD_LIBRARY_PATH"

# only for dev purpose -- {{{
export PATH="/home/shivangi/miniconda3/envs/ecd_tools/bin:$PATH"
export PATH="/home/shivangi/miniconda3/envs/ecd_python3/bin:$PATH"
export PATH="/home/shivangi/miniconda3/envs/multiqc/bin:$PATH"
rm -rf work*
rm -rf .nextflow*
rm -rf results*

# work_dir=$PWD
# sed "s|pwd|$work_dir|g" sample_manifests.txt > sample_manifests_run.txt
# }}} --

nextflow run main.nf \
--redsheet $PWD/test_files/test_redsheet.csv \
--manifestdir $PWD/test_files \
--reference $PWD/test_files/chr22_bwa_index/chr22.fa \
--outdir results \
--merge_FASTQs per-lane \
--tmpdir /tmp \
--fastp_threads 2 \
--bwamem_threads 2 \
--samtools_filter_threads 2 \
--sambamba_merge_threads 2 \
--sambamba_markdup_threads 2 \
--overflow_list_size 200000 \
--mosdepth_threads 2 \
--flag 1796 