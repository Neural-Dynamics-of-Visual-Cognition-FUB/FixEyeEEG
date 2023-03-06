#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=objects_pearsson_time_time 
#SBATCH --mail-type=end
#SBATCH --mem=2000
#SBATCH --time=03:00:00
#SBATCH --qos=standard

# define permutation parameters and qvalues


declare -a permutations
index=0
for splithalf in 1 2 3 
do
    for distance in 2
    do
        for random in 1 2
        do
        permutations[$index]="$splithalf $distance $random"
        index=$((index + 1))
        done
    done
done
#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
splithalf=${params[0]}
distance=${params[1]}
random=${params[2]}

echo split_half $splithalf
echo distance_measure $distance
echo random $random

### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/stats/

### Start job

matlab -nosplash -noFigureWindows -r "statistics_rsa(${splithalf}, ${distance}, ${random})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



