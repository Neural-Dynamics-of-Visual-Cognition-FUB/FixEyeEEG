library(dplyr)
library(data.table)
library("R.matlab")

source('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/MS_Toolbox_R/microsacc.R')
source('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/MS_Toolbox_R/vecvel.R')
# gather all subjects in one big data frame if the script was run for subjects individually 
cleaned_trials_all_subjects <- data.frame(matrix(ncol = 10, nrow = 0))
x <- c("block", "time", "xp", "yp", "ps",  "cr.info", "xp_centered", "yp_centered", "y_visual_angle", "x_visual_angle")
colnames(cleaned_trials_all_subjects) <- x
subs = c(2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)
# create data frame for all subjects 
# df_all_subj_all_sacs_behav = data.frame(matrix(ncol=18,nrow =0))
# colnames(df_all_subj_all_sacs_behav) = c("subj" ,"block" ,'trial', 'onset', 'end', 'peak_velocity',
#                                          'horizontal_comp', 'vertical_comp',
#                                          'horizontal_amp', 'vertical_amp',
#                                          "duration", "amplitude", "cond", "exemplar", "response" ,"category","checkResp", "acc"	)

# calculate accuracy for all subjects 
for (sub in subs){
  cleaned_trials = paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_same_trials_eeg_eyetracking_sub00",sub,".csv",sep="")
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints_tmp = read.csv(cleaned_trials)
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints= df_eyetracking_cleaned_witout_trials_with_missing_timepoints_tmp[-1]
  
  behav_files = paste("/scratch/haebeg19/data/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_wo_artifacts_sub00",sub,".Rda",sep="" )
  load(behav_files)
  
  # set parameters for algorithm 
  SAMPLING = 1000
  MINDUR = 8 #duration criterion
  VFAC = 8 #velocity criterion
  
  
  microsaccades <- matrix(data=NA, ncol=8)
  colnames(microsaccades) <- c("onset", "end", "vpeak", 
                               "comph", "compv","amph", "ampv","trial")
  
  list_microsaccades_all_trials = df_eyetracking_cleaned_witout_trials_with_missing_timepoints[,10:11] %>%
    split(df_eyetracking_cleaned_witout_trials_with_missing_timepoints$block) %>% 
    lapply(as.matrix) %>% 
    lapply(microsacc, VFAC=VFAC, MINDUR = MINDUR, SAMPLING = SAMPLING)
  
  
  # extract table for all trials from list inside list and get amount of detected saccades per trial 
  df_all_sacs = list_microsaccades_all_trials %>% 
    lapply(`[[`, 'table') %>%
    lapply(as.data.frame) %>%
    bind_rows(.id = "column_label")
  
  col_names = c('trial', 'onset', 'end', 'peak_velocity', 
                'horizontal_comp', 'vertical_comp',
                'horizontal_amp', 'vertical_amp'	)
  colnames(df_all_sacs) = col_names
  
  # get number of saccades per trial 
  
  df_all_sacs$subj = sub
  df_all_sacs$duration = df_all_sacs$end-df_all_sacs$onset
  df_all_sacs$amplitude = sqrt(df_all_sacs$horizontal_amp^2+df_all_sacs$vertical_amp^2)
  n_saccades_per_trial = as.data.frame(table(df_all_sacs$trial))
  
  
  # replicate behaviour data according to the amount of saccades present in the dataset 
  behav_df_saccades = bind_rows(replicate(n_saccades_per_trial[1,2],dplyr::filter(behav_data, trial == n_saccades_per_trial[1,1]), simplify = FALSE))
  for (idx in 2:nrow(n_saccades_per_trial)){
    tmp  = bind_rows(replicate(n_saccades_per_trial[idx,2],filter(behav_data, trial == n_saccades_per_trial[idx,1]), simplify = FALSE))
    behav_df_saccades = rbind(behav_df_saccades,tmp) 
  }
  
  # order data set by trials 
  behav_df_saccades = behav_df_saccades %>% arrange(trial)
  
  df_all_sacs_behav = cbind(df_all_sacs, behav_df_saccades[-1])                
  # remove doubled trial column 
  df_all_sacs_behav$trial = NULL      
  
  #reorder columns 
  col_order <- c("subj" ,"block" ,'trial', 'onset', 'end', 'peak_velocity', 
                 'horizontal_comp', 'vertical_comp',
                 'horizontal_amp', 'vertical_amp', 
                 "duration", "amplitude", "cond", "exemplar", "response" ,"category","checkResp", "acc"	)
  df_all_sacs_behav = df_all_sacs_behav[, col_order]
  df_all_subj_all_sacs_behav = rbind(df_all_subj_all_sacs_behav,df_all_sacs_behav)
  
  remove(df_all_sacs_behav)
  remove(df_all_sacs)
  remove(behav_data)
  remove(behav_df_saccades)
  save(df_all_subj_all_sacs_behav, 
       file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/df_all_subj_all_sacs_behav_tmp.Rda")
  
}

save(df_all_subj_all_sacs_behav, 
     file="/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/df_all_subj_all_sacs_behav.Rda")



