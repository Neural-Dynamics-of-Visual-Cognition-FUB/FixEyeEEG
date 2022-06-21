#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=category 
#SBATCH --mail-type=end
#SBATCH --mem=3000
#SBATCH --time=00:20:00
#SBATCH --qos=standard

declare -a permutations
index=0
for sub in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 
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

cd /home/haebeg19/FixEyeEEG/scripts/eyetracking/

### Start job

matlab -nosplash -noFigureWindows -r "preprocess_eyetracking(${sub})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



