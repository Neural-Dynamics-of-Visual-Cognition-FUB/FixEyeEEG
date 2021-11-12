#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=category 
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=10:00:00
#SBATCH --qos=prio

declare -a permutations
i
ndex=1
for sub in 12 
do
    permutations[$index]="$sub" 
    index=$((index + 1))
done

#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
sub=${params[0]}

echo sub $sub

### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /scratch/haebeg19/

cd /home/agnek95/SMST/PDM_PILOT_2/ANALYSIS_Full_experiment/MVPA/First-level/ # insert just directory name
echo changed directories

### Start job

matlab -nosplash -noFigureWindows -r "/home/haebeg19/FixEyeEEG/scripts/EEG/category_decoding_SVM(${sub})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



