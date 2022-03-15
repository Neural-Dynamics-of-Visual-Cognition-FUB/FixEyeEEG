#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=train_test
#SBATCH --mail-type=end
#SBATCH --mem=9000
#SBATCH --time=5:00:00
#SBATCH --qos=prio

declare -a permutations
index=0
for sub in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
do
	for methods in 1 2
	do
		for within in 1 2 
do
    permutations[$index]="$sub $methods $within" 
    index=$((index + 1))
	done
done
done
#Extract parameters
params=(${permutations[${SLURM_ARRAY_TASK_ID}]})
sub=${params[0]}
methods=${params[1]}
within=${params[2]}
echo sub $sub
echo methods $methods
echo within $within
### Set up runtime environment

module add MATLAB/2021a

# wait a bit so it doesn't crash
sleep 50

cd /home/haebeg19/FixEyeEEG/scripts/decoding/

### Start job

matlab -nosplash -noFigureWindows -r "time_time_category_decoding(${sub}, ${methods}, ${within})" > serial.out #this worked
echo set to run
### Output core and memory efficiency

seff $SLURM_JOBID



