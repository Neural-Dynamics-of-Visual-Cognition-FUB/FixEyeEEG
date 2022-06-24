#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=R_script_eyetracking
#SBATCH --mail-type=end
#SBATCH --mem=3000
#SBATCH --time=10:00:00
#SBATCH --qos=standard

Rscript eyetracking_preprocessing_correct_trialinfo.R



