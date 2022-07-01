## reject additonal trials from EEG analysis 
library(dplyr)
library(data.table)
library("R.matlab")

subs = c(2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)


# calculate accuracy for all subjects 
for (sub in subs){
  raw_trials = paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/eyetracking_cleaned_wo_artifacts_and_removed_eeg_trials_and_visual_degree_sub00",sub,".csv",sep="")
  raw = read.csv(raw_trials)
  file_trials_to_keep <- paste('/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/',sub,'/timelocked/trials_to_keep.mat',sep="")
  trials = readMat(file_trials_to_keep)
  trials_to_keep = trials$trials.to.keep
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints = raw[raw$block %in%  trials_to_keep,]
  
  ## remove trials that still contained Nans in baseline and therefore also cannot be used in the eyetracking analysis 
  
  
  
  write.csv(df_eyetracking_cleaned_witout_trials_with_missing_timepoints, 
            file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_same_trials_eeg_eyetracking_sub00",sub,".csv",sep=""))
}