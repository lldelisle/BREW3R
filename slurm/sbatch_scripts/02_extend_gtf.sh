#!/bin/bash

#SBATCH -o slurm-%x-%A.out # Template for the std output of the job uses the job name, the job id and the array id
#SBATCH -e slurm-%x-%A.err # Template for the std error of the job
#SBATCH --nodes 1 # We always use 1 node
#SBATCH --ntasks 1 # In this script everything is sequencial
#SBATCH --job-name Stringtie_BREW3R.r # Job name that appear in squeue as well as in output and error text files

configFile=$1

# This script run stringtie merge without reference
# And uses BREW3R.r to extend the gtf


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
if [ -z "$dirWithIndividualStringTieGTF" ]; then
    echo "dirWithIndividualStringTieGTF must be defined in the config file."
    exit 1
fi
if [ ! -e "$dirWithIndividualStringTieGTF" ]; then
    echo "$dirWithIndividualStringTieGTF must exists and contains gtf files"
    exit 1
fi
if [ -z "$pathForGTFfile" ]; then
    echo "pathForGTFfile must be defined in the config file."
    exit 1
fi
if [ ! -e "$pathForGTFfile" ]; then
    echo "$pathForGTFfile must exists."
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
if [ -z "$pathForRscript" ]; then
    echo "pathForRscript must be defined in the config file."
    exit 1
fi
if [ ! -e "$pathForRscript" ]; then
    echo "$pathForRscript must exists."
    exit 1
fi
if [ -z "${pathForFinalGTFfile}" ]; then
    echo "pathForFinalGTFfile must be defined in the config file."
    exit 1
fi
# Optional
if [ -z "$minFPKM" ]; then
    minFPKM=1
fi
wd=$(uuidgen)
mkdir -p "$wd"
cd "$wd"
inputGTFs=$(ls "$dirWithIndividualStringTieGTF"/*.gtf | tr "\n" " ")
echo "Using $inputGTFs"
srun apptainer exec --bind "${dirWithIndividualStringTieGTF}" "$pathForSingularity" stringtie --merge -p ${nbOfThreads} \
-o stringtie_merge.gtf \
-F "$minFPKM" -g 0 \
${inputGTFs}

mkdir -p "$(dirname ${pathForFinalGTFfile})"
srun apptainer exec --bind "$(dirname $pathForRscript)","$(dirname ${pathForFinalGTFfile})" "$pathForSingularity" Rscript \
    "$pathForRscript" -i "${pathForGTFfile}" \
    -g stringtie_merge.gtf ${RscriptOptions} \
    -o "${pathForFinalGTFfile}" 2> extend.log

echo "Extend log is in $PWD/extend.log"
