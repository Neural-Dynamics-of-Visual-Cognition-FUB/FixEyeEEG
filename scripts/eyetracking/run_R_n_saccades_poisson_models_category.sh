#!/bin/bash

#SBATCH --mail-user=haebeg19@zedat.fu-berlin.de
#SBATCH --job-name=R_script_eyetracking
#SBATCH --mail-type=end
#SBATCH --mem=3000
#SBATCH --time=05:00:00
#SBATCH --qos=standard


module add R/4.0.3-foss-2020b 
Rscript n_saccades_poisson_models_category.R



