# Set the parameters to run BREW3R
pathForSingularity="/scratch/ldelisle/BREW3R/brew3r_v2.sif" # You can get it from docker using for example `apptainer pull docker://lldelisle/brew3r:v2`
dirWithBAMfiles="/scratch/ldelisle/BREW3R/RNAseq/Rabbit/allFinalFiles/bam/" # All BAM files in this directory will be used
strandness="unstranded" # The strandness of BAM files in the directory. Must be among 'unstranded', 'forward' or 'reverse'.
pathForGTFfile="/scratch/ldelisle/BREW3R/RNAseq/Rabbit/Oryctolagus_cuniculus.OryCun2.0.111_UCSC.gtf"
pathForFinalGTFfile="/scratch/ldelisle/BREW3R/RNAseq/Rabbit/Oryctolagus_cuniculus.OryCun2.0.111_UCSC_BREW3R_60unstranded.gtf"
pathForRscript="/home/ldelisle/softwares/BREW3R/slurm/brew3r.r_script.R"
dirWithIndividualStringTieGTF="/scratch/ldelisle/BREW3R/RNAseq/Rabbit/single_gtf/"
minCount="10" # Minimum number of count to be considered as a transcript
minFPKM="1" # Minimum value of FPKM to be included into the merge
RscriptOptions="-f" # If you have unstranded RNA I recommand to use '-f' to avoid extended genes with convergent 3'UTR as this may introduce background on genes. You can also use '-e ^Gm' to avoid extending genes that have names starting with Gm.
sbatchArgs="--mem 4G --cpus-per-task 1 --time 1:00:00"
