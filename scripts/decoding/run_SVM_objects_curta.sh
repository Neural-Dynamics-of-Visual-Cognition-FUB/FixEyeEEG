#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=object_decoding 
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=40:00:00
#SBATCH --qos=standard

declare -a permutations
index=0
for sub in 6 7
do
    for cond in 1 2
    do
        for methods in 1
        do
        permutations[$index]="$sub $cond $methods"
        index=$((index + 1))
        done
    done
done
#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
sub=${params[0]}
cond=${params[1]}
methods=${params[2]}

echo sub $sub
echo cond $cond
echo method $methods

### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/decoding/

### Start job

matlab -nosplash -noFigureWindows -r "object_decoding_SVM(${sub}, ${cond}, ${methods})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



