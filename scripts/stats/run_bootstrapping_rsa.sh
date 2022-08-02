#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=rsa_boots
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=10:00:00
#SBATCH --qos=standard

# define permutation parameters and qvalues


declare -a permutations
index=0

for fixcross in 1 2
    do
        permutations[$index]="$fixcross"
        index=$((index + 1))
    done

#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
fixcross=${params[0]}

echo fixcross $fixcross

### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/stats/

### Start job

matlab -nosplash -noFigureWindows -r "bootstrapping_peak_latency_rsa(${fixcross})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



