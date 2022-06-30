#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=R_script_eyetracking
#SBATCH --mail-type=end
#SBATCH --mem=3000
#SBATCH --time=01:00:00
#SBATCH --qos=standard


module add R/4.0.3-foss-2020b 
Rscript remove_all_trials_from_eyetracking_not_in_EEG.R



