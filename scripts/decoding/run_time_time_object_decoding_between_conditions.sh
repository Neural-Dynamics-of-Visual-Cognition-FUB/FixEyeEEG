#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=time_time_objects_train_test
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=30:00:00
#SBATCH --qos=prio

declare -a permutations
index=0
for sub in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
do
	for methods in 1 2
	do
		for cond in 1 2 
do
    permutations[$index]="$sub $methods $cond" 
    index=$((index + 1))
	done
done
done
#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
sub=${params[0]}
methods=${params[1]}
cond=${params[2]}
echo sub $sub
echo methods $methods
echo cond $cond
### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/decoding/

### Start job

matlab -nosplash -noFigureWindows -r "time_time_object_decoding_between_conditions(${sub}, ${methods}, ${cond})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



