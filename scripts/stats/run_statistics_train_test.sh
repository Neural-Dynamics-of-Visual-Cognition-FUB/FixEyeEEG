#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=train_test_statistics 
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=03:00:00
#SBATCH --qos=standard

# define permutation parameters and qvalues


declare -a permutations
index=0
for decoding in 1 2  
do
    for method in 1 2
    do
        permutations[$index]="$decoding $method"
        index=$((index + 1))
        done
    done

#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
decoding=${params[0]}
method=${params[1]}


echo decoding $decoding
echo method $method

### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/stats/

### Start job

matlab -nosplash -noFigureWindows -r "statistics_train_test(${decoding}, ${method})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



