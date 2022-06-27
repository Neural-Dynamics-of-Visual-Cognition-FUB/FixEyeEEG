
eyetracking_preprocessing_correct_trialinfo_curta <- function(sub) {
library("eyelinker")
library("intervals")
library("dplyr")
library("R.matlab")
# load behavioural data 
# prepare data frame for collecting responses to empty categories 

category_to_be_deleted_all_subjects <- data.frame(matrix(ncol = 7, nrow = 0))

x <- c("sub", "block", "trial", "cond",  "exemplar", "response", "category")
colnames(category_to_be_deleted_all_subjects) <- x
percentage_deleted = double(30)

  trials = data.frame(matrix(ncol = 7, nrow = 0))
  
  #file_beh <- paste("/Users/ghaeberle/Downloads/FixCrossExp_s1cfgdata.mat")
  
  file_beh <- paste("/scratch/haebeg19/data/FixEyeEEG/main/behav_data/FixCrossExp_s",sub,"cfgdata.mat",sep="")
  dat_cfg <- readMat(file_beh)
  exp_data <- dat_cfg$data #data collected during the experiment
  #ntrials <- 3000
  ntrials = 4200
  # create data frame for behavioral data 
  behav_data <- data.frame(sub=rep(sub,ntrials),
                           block=NA,
                           trial=rep(1:ntrials),
                           cond=NA,
                           exemplar=NA,
                           response=NA,
                           category=NA)
  
  behav_data$block <- t(dat_cfg$block)
  behav_data$cond <- as.factor(dat_cfg$cond) #standard(2) or bullseye(1)
  resp <- dat_cfg$data[8] #keyboard press
  behav_data$response <- t(resp[[1]])
  behav_data$exemplar <- exp_data[[7]] 
  behav_data$category <- t(exp_data[[9]])
  
  # load eyetracking data and preprocess 
  #file_eye =  paste("/Volumes/ESD-USB/FixEyeEEGMAIN/eye",sub,".asc",sep="")
  file_eye <- paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/raw/",sub,"/eye",sub,".asc",sep="")
  dat = read.asc(file_eye)
  raw = dat$raw # raw eyemovement data 
  
  #renaming of trials 
  msg = dat$msg
  head(msg)
  start_trial = msg$time[which(msg$text=="STARTTIME")]
  start_first =  which(raw$time == start_trial[1]-1);
  trial = rep(1,start_first);
  for (idx in 1:4200){
    if (idx == 4200){
      tps = nrow(raw) - which(raw$time == start_trial[idx])+1
    }else{
      tps = which(raw$time == start_trial[idx+1]) - which(raw$time == start_trial[idx])
    }
    trial = c(trial,(rep(idx, tps)))
  }
  
  raw$block = trial
  
  # Delete Catch Trials 
  catch = behav_data$trial[behav_data$category == 999]
  raw_without_catch =raw[!raw$block %in% catch,]
  
  pauses_start = msg$time[which(msg$text=="PAUSE")]
  pauses_end = msg$time[which(msg$text=="PAUSE")+2]
  pauses = cbind(pauses_start, pauses_end)
  
  # between excludes everything >= value, but the end of our pause is already the beginning of the next trial!! 
  #raw_without_pauses = raw_without_catch %>% dplyr::filter((!(dplyr::between(time, pauses[,1],pauses[,2]-1))))
  #raw_without_pauses = raw_without_catch %>% dplyr::filter(!(pauses %in% time))
  raw_without_pauses = raw_without_catch 
  remove(raw_without_catch)
  for (idx in 1:nrow(pauses)){
    raw_without_pauses = raw_without_pauses %>% dplyr::filter((!(dplyr::between(time, pauses[idx,1],pauses[idx,2]-1))))
  }
  
  # exclusion of blinks + 100ms before and after 
  blinks = cbind(dat$blinks$stime, dat$blinks$etime) # Define a set of intervals
  blinks_df = filter(raw_without_pauses, time %In% blinks)
  length(unique(blinks_df[["block"]]))
  
  hundretMS_blinks = Intervals(blinks) %>% expand(100, "absolute")
  #exclusion of out of range values 
  out_of_range_cx = na.omit(raw_without_pauses[raw_without_pauses$xp>1680,])
  out_of_range_cy = na.omit(raw_without_pauses[raw_without_pauses$yp>1050,])
  tmp_cx = cbind(out_of_range_cx$time,out_of_range_cx$time)
  tmp_cy = cbind(out_of_range_cy$time,out_of_range_cy$time)
  hundreths_cx = Intervals(tmp_cx) %>% expand(100, "absolute")
  hundreths_cy = Intervals(tmp_cy) %>% expand(100, "absolute")
  
  # exclusion of negative values 
  negative_cx = na.omit(raw_without_pauses[raw_without_pauses$xp<0,])
  negative_cy = na.omit(raw_without_pauses[raw_without_pauses$yp<0,])
  tmp_ncx = cbind(negative_cx$time, negative_cx$time)
  tmp_ncy = cbind(negative_cy$time, negative_cy$time)
  hundreths_ncx = Intervals(tmp_ncx) %>% expand(100, "absolute")
  hundreths_ncy = Intervals(tmp_ncy) %>% expand(100, "absolute")
  
  
  # actual exclusion of all values 
  # # raw_without_pauses = raw_without_catch %>% filter(!(between(time, pauses[,1],pauses[,2])))
  #  df_eyetracking_cleaned = raw_without_pauses %>% 
  #    filter(!(dplyr::between(time,hundretMS_blinks[,1], hundretMS_blinks[,2]))) %>% 
  #    filter(!(dplyr::between(time,hundreths_cx[,1], hundreths_cx[,2]))) %>% 
  #    filter(!(dplyr::between(time,hundreths_cy[,1], hundreths_cy[,2]))) %>% 
  #    filter(!(dplyr::between(time,hundreths_ncx[,1], hundreths_ncx[,2]))) %>% 
  #    filter(!(dplyr::between(time,hundreths_ncy[,1], hundreths_ncy[,2]))) 
  # check how many trials we would in principle lose 
  df_eyetracking_cleaned = raw_without_pauses
  remove(raw_without_pauses)
  if (nrow(hundretMS_blinks) > 0) {
    
    for (idx in 1:nrow(hundretMS_blinks)) {
      
      tmp1 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundretMS_blinks[idx,1],]
      tmp2 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundretMS_blinks[idx,2],]
      
      trials = rbind(trials, tmp1)
      trials = rbind(trials, tmp2)
      
      df_eyetracking_cleaned = df_eyetracking_cleaned %>% 
        filter(!(dplyr::between(time,hundretMS_blinks[idx,1], hundretMS_blinks[idx,2])))
      
      
    }
  }
  
  if (nrow(hundreths_cx) > 0) {
    for (idx in 1:nrow(hundreths_cx)) {
      
      tmp1 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_cx[idx,1],]
      tmp2 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_cx[idx,2],]
      
      trials = rbind(trials, tmp1)
      trials = rbind(trials, tmp2)
      
      df_eyetracking_cleaned = df_eyetracking_cleaned %>% 
        filter(!(dplyr::between(time,hundreths_cx[idx,1], hundreths_cx[idx,2])))
      
      
    }
  }
  
  if (nrow(hundreths_cy) > 0) {
    for (idx in 1:nrow(hundreths_cy)) {
      tmp1 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_cy[idx,1],]
      tmp2 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_cy[idx,2],]
      
      trials = rbind(trials, tmp1)
      trials = rbind(trials, tmp2)
      
      df_eyetracking_cleaned = df_eyetracking_cleaned %>% 
        filter(!(dplyr::between(time,hundreths_cy[idx,1], hundreths_cy[idx,2])))
      
      
    }
  }
  
  if (nrow(hundreths_ncx) > 0) {
    for (idx in 1:nrow(hundreths_ncx)) {
      tmp1 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_ncx[idx,1],]
      tmp2 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_ncx[idx,2],]
      
      trials = rbind(trials, tmp1)
      trials = rbind(trials, tmp2)
      df_eyetracking_cleaned = df_eyetracking_cleaned %>% 
        filter(!(dplyr::between(time,hundreths_ncx[idx,1], hundreths_ncx[idx,2])))
      
      
    }
  }
  
  if (nrow(hundreths_ncy) > 0) {
    for (idx in 1:nrow(hundreths_ncy)) {
      tmp1 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_ncy[idx,1],]
      tmp2 = df_eyetracking_cleaned[df_eyetracking_cleaned$time == hundreths_ncy[idx,2],]
      
      trials = rbind(trials, tmp1)
      trials = rbind(trials, tmp2)
      df_eyetracking_cleaned = df_eyetracking_cleaned %>% 
        filter(!(dplyr::between(time,hundreths_ncy[idx,1], hundreths_ncy[idx,2]))) 
      
    }
  }
  
  #check for remaining NAs
  nan_values = is.na(df_eyetracking_cleaned)
  array_ind_nan_values = which(nan_values, arr.ind = TRUE)
  unique_nan_rows = unique(array_ind_nan_values[,1])
  trials_nan = df_eyetracking_cleaned[unique_nan_rows,]
  unique_trials = unique(trials_nan$block)
  df_eyetracking_cleaned = na.omit(df_eyetracking_cleaned)
  
  #unique_blocks_with = unique(df_eyetracking_cleaned_nas$block)
  # missing_trials  = subset(df_eyetracking_cleaned, !(block %in% df_eyetracking_cleaned_nas$block))
  
  
  # how many trials are remaining after deleting these trials 
  remaining = length(unique(df_eyetracking_cleaned$block)) - 
    length(unique(blinks_df$block))- 
    length(unique(out_of_range_cx$block)) -
    length(unique(out_of_range_cy$block)) - 
    length(unique(negative_cx$block)) - 
    length(unique(negative_cy$block)) 
  
  throw_away =  length(unique(blinks_df$block))+ 
    length(unique(out_of_range_cx$block)) +
    length(unique(out_of_range_cy$block)) + 
    length(unique(negative_cx$block)) +
    length(unique(negative_cy$block))
  
  # percentage left over trials 
  100/length(unique(df_eyetracking_cleaned$block))*remaining
  
  
  # find out which trials need to be deleted: 
  trial_numbers_to_be_deleted1 = unique(c(unique(blinks_df$block),
                                          unique(out_of_range_cx$block),
                                          unique(out_of_range_cy$block),
                                          unique(negative_cx$block),
                                          unique(negative_cy$block),
                                          unique_trials))
  trial_numbers_to_be_deleted = unique(trials$block)
  remove(trials)
  # find out which category and exemplar these belong to: 
  category_to_be_deleted = behav_data[behav_data$trial %in% trial_numbers_to_be_deleted,]
  category_to_be_deleted$exemplar = category_to_be_deleted$exemplar %>% unlist()
  category_to_be_deleted_all_subjects = rbind(category_to_be_deleted_all_subjects,category_to_be_deleted)
  percentage_deleted[sub] = 100/length(unique(df_eyetracking_cleaned$block))*length(category_to_be_deleted$exemplar)
  
  
  # remove trials from continous eyetracking data 
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints = df_eyetracking_cleaned[!df_eyetracking_cleaned$block %in%  trial_numbers_to_be_deleted,]
  
  
  # save data
  
  #behavioural data
  save(behav_data, file=paste("/scratch/haebeg19/data/FixEyeEEG/main/behav_data/behav_data_",sub,".Rda",sep=""))
  # fwrite(behav_data, file =paste("behav_data_",sub,".csv",sep=""))
  
  conversion_px_degree_monitor = 3.55
  x_size_monitor = 1680
  y_size_monitor = 1050
  distance_to_monitor = 600
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints$xp_centered <- df_eyetracking_cleaned_witout_trials_with_missing_timepoints$xp - x_size_monitor/2
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints$yp_centered <- df_eyetracking_cleaned_witout_trials_with_missing_timepoints$yp - y_size_monitor/2
  mmy <- df_eyetracking_cleaned_witout_trials_with_missing_timepoints$yp_centered / conversion_px_degree_monitor
  mmx <- df_eyetracking_cleaned_witout_trials_with_missing_timepoints$xp_centered / conversion_px_degree_monitor
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints$x_visual_angle <- 2*atan2(df_eyetracking_cleaned_witout_trials_with_missing_timepoints$xp_centered*mmx,distance_to_monitor)
  df_eyetracking_cleaned_witout_trials_with_missing_timepoints$y_visual_angle <- 2*atan2(df_eyetracking_cleaned_witout_trials_with_missing_timepoints$yp_centered*mmy,distance_to_monitor)
  
  save(df_eyetracking_cleaned_witout_trials_with_missing_timepoints, 
       file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_wo_artifacts_and_visual_degree_sub00",sub,".Rda",sep=""))
  
  
  write.csv(df_eyetracking_cleaned_witout_trials_with_missing_timepoints, 
            file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/eyetracking_cleaned_wo_artifacts_and_visual_degree_sub00",sub,".csv",sep=""))
  
  
  
  # categories that have been deleted for all subjects
  #writeMat('/Users/ghaeberle/Downloads/eyetracking_data.mat', eyetracking_cleaned = df_eyetracking_cleaned)
  write.csv(category_to_be_deleted,
            file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/deleted_categories_sub00",sub,".csv",sep=""))
  
  # trial numbers that need to be deleted
  write.csv(trial_numbers_to_be_deleted, 
            file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/cleaned/deleted_trial_numbers_sub00",sub,".csv",sep=""))
  
  
  remove(category_to_be_deleted)
  remove(df_eyetracking_cleaned)
  remove(df_eyetracking_cleaned_witout_trials_with_missing_timepoints)
  remove(trial_numbers_to_be_deleted)

}


