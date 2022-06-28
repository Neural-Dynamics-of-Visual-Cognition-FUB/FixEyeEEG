library("eyelinker")
library("intervals")
library("dplyr")
library("R.matlab")
# load behavioural data 
# prepare data frame for collecting responses to empty categories 
subs = c(2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)
category_to_be_deleted_all_subjects <- data.frame(matrix(ncol = 7, nrow = 0))

x <- c("sub", "block", "trial", "cond",  "exemplar", "response", "category")
colnames(category_to_be_deleted_all_subjects) <- x
percentage_deleted = double(30)
for (sub in subs){
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
  
  conversion_px_degree_monitor = 3.55
  x_size_monitor = 1680
  y_size_monitor = 1050
  distance_to_monitor = 600
  raw$xp_centered <- raw$xp - x_size_monitor/2
  raw$yp_centered <- raw$yp - y_size_monitor/2
  mmy <- raw$yp_centered / conversion_px_degree_monitor
  mmx <- raw$xp_centered / conversion_px_degree_monitor
  raw$x_visual_angle <- 2*atan2(raw$xp_centered*mmx,distance_to_monitor)
  raw$y_visual_angle <- 2*atan2(raw$yp_centered*mmy,distance_to_monitor)
  
  write.csv(raw, 
            file=paste("/scratch/haebeg19/data/FixEyeEEG/main/eyetracking/preprocessed/raw_correct_trials/raw_sub00",sub,".csv",sep=""))
}