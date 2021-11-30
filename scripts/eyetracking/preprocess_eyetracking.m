function [outputArg1,outputArg2] = preprocess_eyetracking(subj)

    %% set up prereqs
    if ismac
        addpath('/Users/ghaeberle/Documents/MATLAB/fieldtrip-20210928/')
        ft_defaults
        BASE = '/Users/ghaeberle/scratch/';
    elseif isunix
        addpath('/home/haebeg19/toolbox/fieldtrip/')
        BASE = '/scratch/haebeg19/';
        ft_defaults
    end
    
    %% load preprocessed eyetracking data from R & behavioral data

    filename_asc = '/Users/ghaeberle/Downloads/tmp/eye1.asc';
    filename_asc = sprintf('%sdata/FixEyeEEG/eyetracking/preprocessed/eye1.asc',BASE);
    data_eye_csv = readmatrix('/Users/ghaeberle/Downloads/tmp/eyetracking_cleaned_wo_artifacts_sub001.csv');

    % remove index column 
    data_eye_csv = data_eye_csv(:,2:end);
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/', BASE, subj);
   % eyetracking_removed = readmatrix(sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/trials_wo_artefacts/deleted_trial_numbers_sub00%s.csv', BASE,subj), 'Range', 'B2');
    % filepath_behav_data = sprintf('%sdata/FixEyeEEG/main/behav_data/FixCrossExp_s%scfgdata.mat', BASE, subj); 
    filepath_behav_data = '/Users/ghaeberle/Downloads/tmp/FixCrossExp_s1cfgdata.mat';

    behav = load(filepath_behav_data);
    
    behav_data = behav.data;
    exemplar = string(behav_data.category)';
    % the first line in the trialinfo (repmat(3,1,3000)') is jsut there to
    % replicate the trialinfo structure of the eeg data 
    trialinfo = [repmat(3,1,3000)' (1:3000)' behav_data.catlabel' exemplar behav_data.cond'];
    
    %% get info about start of each trial 
    hdr_eye = ft_read_header(filename_asc);
    msg = hdr_eye.orig.msg;
    idx_start_trial = find(contains(msg, 'STARTTIME'));
    msg_start_trial = msg(idx_start_trial);

    split_messages = cellfun(@(x) strsplit(x, {'\t', ' '}), msg_start_trial, 'UniformOutput', false);
    split_messages = vertcat(split_messages{:}); % To remove nesting of cell array newA
    timepoint_start_trial = str2num(vertcat(split_messages{:,2}));
    
   
    
    %% remove trials
      idx_kept_trials = unique(data_eye_csv(:,1));
      timepoint_start_kept_trials = timepoint_start_trial(idx_kept_trials);
      trialinfo_kept_trials = trialinfo(idx_kept_trials,:);
%     timpoint_start_trial_without_catch = timepoint_start_trial(find(trialinfo(:,2)~= '999'));
%     trialinfo_without_catch = trialinfo(find(trialinfo(:,2)~= '999'),:);
%     
% 
%     for idx=1:size(eyetracking_removed,1)
%         idx_trials_removed(idx) = find(trialinfo_without_catch(:,1)== num2str(eyetracking_removed(idx)));
%     end
%     
%     trials_to_keep = setdiff(str2double(tmp), unique(idx_trials_removed));
% 
%     for idx=1:size(trials_to_keep,1)
%         idx_trials_to_keep(idx) = find(trialinfo_without_catch(:,1)== num2str(trials_to_keep(idx)));
%     end
% 
%     %%% TODO find out how to properly filter out the trials taht we do not need  
%     tmp = trialinfo_without_catch(:,1);
%     trials_to_keep = setdiff(str2double(tmp), unique(idx_trials_removed));
%     
%     timepoint_start_trial_without_eyetracking = timpoint_start_trial_without_catch(idx_trials_to_keep);
%     
 %% create trialand time structures for fieldtrip
    n_trials = size(timepoint_start_kept_trials,1);
    time = cell(1,n_trials);
    trial = cell(1,n_trials);
    %pre and post stimulus in ms (-1 for pre and post as 0 also counts as a timepoint )
    prestim = 199;
    poststim = 999;
    
    for idx =1:n_trials
       
        if idx == n_trials 
            
            start_idx = find(data_eye_csv(:,2) == timepoint_start_kept_trials(idx));
            trial{idx} = [data_eye_csv(start_idx-prestim:start_idx,9)' ,data_eye_csv(start_idx:end,9)';
                          data_eye_csv(start_idx-prestim:start_idx,10)' ,data_eye_csv(start_idx:end,10)'];
            sampleinfo(idx,1) = data_eye_csv(start_idx-prestim, 2);
            sampleinfo(idx,2) = data_eye_csv(start_idx:end, 2);
            time{idx} = -.2:0.001:(length(trial{n_trials})/1000-0.201);
        end 
        
        time{idx} = -.2:0.001:0.999 ;
        start_idx = find(data_eye_csv(:,2) == timepoint_start_kept_trials(idx));
        trial{idx} = [data_eye_csv(start_idx-prestim:start_idx,9)' ,data_eye_csv(start_idx:(start_idx+poststim),9)';
                      data_eye_csv(start_idx-prestim:start_idx,10)' ,data_eye_csv(start_idx:(start_idx+poststim),10)'];
        sampleinfo(idx,1) = data_eye_csv(start_idx-prestim, 2);
        sampleinfo(idx,2) = data_eye_csv(start_idx+poststim, 2);
        
    end
    %% create fieldtrip data structure without fieldtrip reading functions 
    data_eye.label     = {'xp', 'yp'}; % cell-array containing strings, Nchan*1
    data_eye.fsample   = 1000; % double check, it is different in the header file --> why?  % sampling frequency in Hz, single number
    data_eye.trial     = trial;% cell-array containing a data matrix for each
                    % trial (1*Ntrial), each data matrix is a Nchan*Nsamples matrix
    data_eye.time       = time;% cell-array containing a time axis for each
                    % trial (1*Ntrial), each time axis is a 1*Nsamples vector
    data_eye.trialinfo = trialinfo_kept_trials; % this field is optional, but can be used to store
                    % trial-specific information, such as condition numbers,
                    % reaction times, correct responses etc. The dimensionality
                    % is Ntrial*M, where M is an arbitrary number of columns.
    data_eye.sampleinfo = sampleinfo;  % optional array (Ntrial*2) containing the start and end
                    % sample of each trial
    

    cfg=[];
    cfg.resamplefs=200;
    data_eye_resampled = ft_resampledata(cfg,data_eye);
    data_eye_resampled.trialinfo = data_eye.trialinfo;

    cfg = []; 
    cfg.preproc.hpfilter='no';
    cfg.preproc.lpfilter='no';
    cfg.preproc.bsfilter='no';
    cfg.preproc.demean = 'yes';
    cfg.baselinewindow = [-0.2 0];
    data_baseline=ft_preprocessing(cfg, data_eye_resampled);
    
    % transform to timelocked data 
    cfg.keeptrials='yes';
    eye_data_baseline_timelocked=ft_timelockanalysis(cfg,data_baseline);
    eye_data_baseline_timelocked.trialinfo = data_eye.trialinfo;
    
    save([filepath_preprocessed_data 'eyetracking_data_timelocked.mat'], 'eye_data_baseline_timelocked');
end

