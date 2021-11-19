#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=category 
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=10:00:00
#SBATCH --qos=prio

declare -a permutations
index=0
for sub in 1 3 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 
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

cd /home/haebeg19/FixEyeEEG/scripts/EEG/

### Start job

matlab -nosplash -noFigureWindows -r "object_decoding_SVM(${sub})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



