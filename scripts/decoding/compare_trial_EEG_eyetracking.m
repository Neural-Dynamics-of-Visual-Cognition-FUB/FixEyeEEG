function [outputArg1,outputArg2] = compare_trial_EEG_eyetracking(subj)
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

    subj = num2str(subj);
    filepath_clean_data_noICA = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/', BASE, subj);
    filepath_preprocessed_data_eeg = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/preprocessed_noICA_timelocked.mat',BASE,subj);
    load(filepath_preprocessed_data_eeg)

    filepath_preprocessed_data_eyetracking = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    load(filepath_preprocessed_data_eyetracking)
    eyetracking_data = eye_data_baseline_timelocked;
    
    filepath_trial_to_keep = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/trials_to_keep.mat',BASE,subj);
    load(filepath_trial_to_keep)
    
    eeg_trials = cellfun(@str2num,data_rej_channel_interpolated_timelocked.trialinfo(:,2));
    not_in_eye = setdiff(eeg_trials,trials_to_keep);
    idx_not_in_eye = find(ismember(eeg_trials,not_in_eye));
    eeg_trials(idx_not_in_eye) = [];
    
    eeg_trials = find(ismember(eeg_trials,trials_to_keep));
    
    save([filepath_clean_data_noICA 'preprocessed_noICA_timelocked_with_not_included_eyetrackting_trials.mat'], 'data_rej_channel_interpolated_timelocked');

    cfg = [];
    cfg.trials = eeg_trials;
    data_rej_channel_interpolated_timelocked = ft_preprocessing(cfg, data_rej_channel_interpolated_timelocked);
    save([filepath_clean_data_noICA 'preprocessed_noICA_timelocked.mat'], 'data_rej_channel_interpolated_timelocked');

end

