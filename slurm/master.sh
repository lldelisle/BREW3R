configFile=$1
# Check everything is set correctly:
if [ -z $configFile ]; then
    echo "A config file is required"
    exit 1
fi
source $configFile
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
if [ -z "$dirWithIndividualStringTieGTF" ]; then
    echo "dirWithIndividualStringTieGTF must be defined in the config file."
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

# Prepare the first step
mkdir -p "$dirWithIndividualStringTieGTF"
nBAM=$(ls "${dirWithBAMfiles}/"*.bam | wc -l)

jidStringtieIndividual=$(sbatch $sbatchArgs --array=1-${nBAM} --chdir "$dirWithIndividualStringTieGTF" $(dirname $0)/sbatch_scripts/01_individual_stringtie.sh $configFile | awk '{print $NF}')

jidExtend=$(sbatch $sbatchArgs --chdir "$dirWithIndividualStringTieGTF" --dependency=afterok:$jidStringtieIndividual $(dirname $0)/sbatch_scripts/02_extend_gtf.sh $configFile | awk '{print $NF}')

echo "To cancel all:"
echo "scancel $jidStringtieIndividual # stringtie individual"
echo "scancel $jidExtend # extension"
