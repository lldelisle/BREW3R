#!/bin/bash

#SBATCH -o slurm-%x-%A_%2a.out # Template for the std output of the job uses the job name, the job id and the array id
#SBATCH -e slurm-%x-%A_%2a.err # Template for the std error of the job
#SBATCH --nodes 1 # We always use 1 node
#SBATCH --ntasks 1 # In this script everything is sequencial
#SBATCH --job-name Stringtie_indiv # Job name that appear in squeue as well as in output and error text files

configFile=$1

# This script run stringtie without reference to get the transcripts from BAM 

##################################
#### TO SET FOR EACH ANALYSIS ####
##################################

### Specify the options for your analysis:
# number of CPU to use
# Only change if you don't want to use all CPUs allocated
nbOfThreads=${SLURM_CPUS_PER_TASK}

source $configFile

##################################
####### BEGINING OF SCRIPT #######
##################################

# Check everything is set correctly:
if [ -z $configFile ]; then
    echo "A config file is required"
    exit 1
fi
if [ -z "$strandness" ]; then
    echo "strandness must be defined in the config file."
    exit 1
fi
if [ "$strandness" != "forward" ] && [ "$strandness" != "reverse" ] && [ "$strandness" != "unstranded" ]; then
    echo "strandness must be among 'unstranded', 'forward' or 'reverse'."
    exit 1
fi
if [ -z "$dirWithBAMfiles" ]; then
    echo "dirWithBAMfiles must be defined in the config file."
    exit 1
fi
if [ ! -e "$dirWithBAMfiles" ]; then
    echo "$dirWithBAMfiles must exists and contains bam files"
    exit 1
fi
if [ -z "$pathForSingularity" ]; then
    echo "pathForSingularity must be defined in the config file."
    exit 1
fi
if [ ! -e "$pathForSingularity" ]; then
    echo "$pathForSingularity must exists."
    exit 1
fi
# Optional
if [ -z "$minCount" ]; then
    minCount=10
fi



inputBAM=$(ls "${dirWithBAMfiles}/"*.bam | awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i{print}')

sample=$(basename $inputBAM .bam)
sample=$(basename $sample _Aligned.sortedByCoord.out)

if [ ! -e ${sample}_stringtie.gtf ]; then
  if [ "$strandness" = "unstranded" ]; then 
    strandnessArg=""
  elif [ "$strandness" = "forward" ]; then
    strandnessArg="--rf"
  else
    strandnessArg="--fr"
  fi
    srun apptainer exec --bind "${dirWithBAMfiles}" "$pathForSingularity" stringtie ${inputBAM} \
        -c "$minCount" -s "$minCount" -j "$minCount" \
        -p "${nbOfThreads}" $strandnessArg \
        -o ${sample}_stringtie.gtf
fi
