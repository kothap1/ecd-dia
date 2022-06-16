class CheckParams {
   public static void checkRequiredParams(params, log, valid_params) {
      if (!params.user_id) { 
         log.error "User ID not specified. This is required for manifests generated for the outputs of the pipeline."
         System.exit(1)
      }

      if (!params.samples && !params.samplename && !params.redsheet) { 
         log.error "Input sample(s) not specified!"
         System.exit(1)
      }

      if (params.samplename && !params.manifestdir) { 
         log.error "Please provide path to the directory where manifests for sample ${params.samplename} are expected."
         System.exit(1)
      }

      if (params.redsheet && (!params.manifestdir && !params.sampledir)) { 
         log.error "Please provide path to the directory where manifests/FASTQs for samples in redsheet '${params.redsheet}' are expected."
         System.exit(1)
      }

      if (params.redsheet && (params.manifestdir && params.sampledir)) { 
         log.error "Can't provide both- manifestdir and sampledir."
         System.exit(1)
      }

      if (!params.reference) { 
         log.error "Reference genome not specified!"
         System.exit(1)
      }

      if (!params.outdir) { 
         log.error "Output directory not specified!"
         System.exit(1)
      }

      // Check whether valid option is provided for merging FASTQs
      if (params.merge_FASTQs == null) { 
         log.error "Please specify whether to merge FASTQs or not by using '--merge_FASTQs'. \n" + 
                   "Available options are:\n" +
                   "    false         :  No merging\n" +
                   "    per-lane      :  All sequencers per lane\n" +
                   "    per-sequencer :  All lanes per sequencer"
         System.exit(1)
      } else {
         def merge = params.merge_FASTQs ? params.merge_FASTQs : 'no-merging'
         if (!valid_params['fastq_merging'].contains(merge)) { 
            log.error "Invalid option '${merge}' to parameter --merge_FASTQs. " +
                     "Please choose from one of the following options:\n" +
                     "    false         :  No merging\n" +
                     "    per-lane      :  All sequencers per lane\n" +
                     "    per-sequencer :  All lanes per sequencer"
            System.exit(1)
         }
      }

      // Check whether valid modules are provided to picard CollectMultipleMetrics
      def picard_modules = params.MULTI_METRICS_PROGRAMS.split(',').collect{ it.trim() }
         if ((valid_params['picard_modules'] + picard_modules).unique().size() != valid_params['picard_modules'].size()) {
         log.error "Invalid option: ${params.MULTI_METRICS_PROGRAMS}. Valid options for '--MULTI_METRICS_PROGRAMS':\n" +
                   "${valid_params['picard_modules'].join(', ')}"
         System.exit(1)
      }
   }

   public static ArrayList checkBamSize(sampleID, bam) {
      // TODO: Change BAM size cut-off
      if (bam.size() < 1000) {
         def total_reads = ['/bin/bash', '-c', /samtools view ${bam} | head | wc -l/].execute().text as int
         if (total_reads > 0) {
            return([bam, bam.size(), true])
         } else {
            return([bam, bam.size(), false])
         }
      } else {
         return([bam, bam.size(), true])
      }
   }

   public static void emptyBAMWarn(sampleID, bam, size, log) {
      log.warn "Skipping metrics calculation for sample $sampleID as BAM file seems empty.\n" +
               "      BAM: $bam\n" +
               "      Size: $size"
   }
}