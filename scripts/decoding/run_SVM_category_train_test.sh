#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=train_test
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=5:00:00
#SBATCH --qos=prio

declare -a permutations
index=0
for sub in 2 3 4 5 6 7 8 9 10 11 
do
	for methods in 1 2
do
    permutations[$index]="$sub $methods" 
    index=$((index + 1))
	done
done
#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
sub=${params[0]}
methods=${params[1]}
echo sub $sub
echo methods $methods
### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/decoding/

### Start job

matlab -nosplash -noFigureWindows -r "train_on_standard_test_on_bulls_SVM_category(${sub}, ${methods})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



