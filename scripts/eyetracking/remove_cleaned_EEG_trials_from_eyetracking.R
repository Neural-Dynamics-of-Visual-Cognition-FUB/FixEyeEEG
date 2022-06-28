## reject additonal trials from EEG analysis 
library(dplyr)
library(data.table)
library("R.matlab")

subs = c(2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)


# calculate accuracy for all subjects 
for (sub in subs){
  cleaned_trials = paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_wo_artifacts_and_visual_degree_sub00",sub,".Rda",sep="")
  load(cleaned_trials)
  behav_files = paste("/scratch/haebeg19/data/FixEyeEEG/main/behav_data/behav_data_",sub,".Rda",sep="")
  load(behav_files)
  behav_data$checkResp[behav_data$category==999 & behav_data$response==1] ='Hit'
  behav_data$checkResp[behav_data$category!=999 & behav_data$response==1] ='FA'
  behav_data$checkResp[behav_data$category!=999 & behav_data$response==0] ='CR'
  behav_data$checkResp[behav_data$category==999 & behav_data$response==0] ='Miss'
  
  behav_data$acc <- round(length(behav_data$checkResp[behav_data$checkResp=='Hit']) / 
                            (length(behav_data$checkResp[behav_data$checkResp=='Miss'])+
                               length(behav_data$checkResp[behav_data$checkResp=='Hit'])),2)
  save(behav_data,
       file = paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_wo_artifacts_sub00",sub,".Rda",sep="" ))
  
  ## remove few trials that have been removed in EEG cleaning: 
  
  file_beh <- paste('/scratch/haebeg19/data/FixEyeEEG/main/behav_data/subject',sub, '_meta_info.mat',sep="")
  dat_cfg <- readMat(file_beh)
  rejected_trials = dat_cfg$subjectinfo[3][[1]]
  
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints = df_eyetracking_cleaned_witout_trials_with_missing_timepoints[!df_eyetracking_cleaned_witout_trials_with_missing_timepoints$block %in%  rejected_trials,]
  
  write.csv(df_eyetracking_cleaned_witout_trials_with_missing_timepoints, 
            file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_wo_artifacts_and_removed_eeg_trials_and_visual_degree_sub00",sub,".csv",sep=""))
}