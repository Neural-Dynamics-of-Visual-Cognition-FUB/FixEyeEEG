#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=decoding_statistics 
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
        permutations[$index]="$split_half $distance_measure $random"
        index=$((index + 1))
        done
    done

#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
split_half=${params[0]}
distance_measure=${params[1]}
methods=${params[2]}

echo split_half $split_half
echo distance_measure $distance_measure
echo random $random

### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/stats/

### Start job

matlab -nosplash -noFigureWindows -r "statistics_decoding(${decoding}, ${method})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



