function [] = time_time_pearsson_object_decoding(subj, fixation_condition, method)
%{
    - Multivariate Noise Normalisation
    - object decoding for both fixation crosses for animate versus
    inanimate objects
    - decoding on all channels
    - decoding on pseudotrials
    - leave one pseudotrial out cross validation
    - decode with SVM
    - ICA FLAG determines whether decoding is run on ICA or no ICA data
%}


%% set up prereqs
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/decoding');
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/decoding/MEG_SVM_decoding_MVNN/');
    addpath('/Users/ghaeberle/Documents/MATLAB/libsvm/matlab');
    addpath('/Users/ghaeberle/Documents/MATLAB/fieldtrip-20210928/')
    ft_defaults
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/decoding');
    addpath('/home/haebeg19/FixEyeEEG/scripts/decoding/MEG_SVM_decoding_MVNN/');
    addpath('/home/haebeg19/toolbox/libsvm/matlab');
    addpath('/home/haebeg19/toolbox/fieldtrip/')
    BASE = '/scratch/haebeg19/';
    ft_defaults
end

if fixation_condition == 2
    fixation_condition = 'standard';
elseif fixation_condition == 1
    fixation_condition = 'bulls';
end

subj = num2str(subj);

% 1 == EEG, 2 == eyetracking
if method == 1
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/preprocessed_noICA_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/pearsson_time_time/%s/', BASE,subj);
    load(filepath_preprocessed_data)
    preprocessed_data = data_rej_channel_interpolated_timelocked;
elseif method == 2
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eyetracking/pearsson_time_time/%s', BASE,subj);
    load(filepath_preprocessed_data)
    preprocessed_data = eye_data_baseline_timelocked;
end


if ~isfolder(results_dir)
    mkdir(results_dir);
end

%% define required information
n_permutations = 100;
n_pseudotrials = 6;
n_conditions = 40; %objects to decode
time_points = size(preprocessed_data.time,2);
%% split data into standard(2) and bullseye(1) fixation cross

if strcmp(fixation_condition, 'standard') == 1
    % standard
    cfg = [];
    cfg.trials = find(preprocessed_data.trialinfo(:,5)=='2');
    data = ft_selectdata(cfg, preprocessed_data);
elseif strcmp(fixation_condition, 'bulls') == 1
    cfg = [];
    cfg.trials = find(preprocessed_data.trialinfo(:,5)=='1');
    data = ft_selectdata(cfg, preprocessed_data);
end


% minimum number of trials

[min_number_of_trials, individual_objects] = get_min_trial_per_object(data);


for perm = 1:n_permutations
    
    min_num_trials_all_conditions = min(min_number_of_trials);
    data_matrix_MVNN = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data, 'object', individual_objects);
    % get inverted covariance matrix
    [data_objA_objB_MVNN, ~] = multivariate_noise_normalization(data_matrix_MVNN);
    
    num_trials_per_bin = round(min_num_trials_all_conditions/n_pseudotrials);
    pseudo_trials = create_pseudotrials(n_conditions, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN);
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            for time1 = 1:time_points
                for time2=1:time_points
                    for pseudo = 1:n_pseudotrials
                        %% standard
                        rdm_time_time(perm,pseudo, objA,objB,time1,time2) = 1-corr(squeeze(pseudo_trials(objA,pseudo,:,time1)),squeeze(pseudo_trials(objB,pseudo,:,time2)),'type','Pearson');
                    end
                end
            end
        end
    end
end

if strcmp(fixation_condition, 'standard') == 1
    rdm_time_time_avg_standard = squeeze(nanmean(nanmean(rdm_time_time,1),2)); %average over permutations and pseudotrials
    filename = sprintf('objects_%s',fixation_condition);
    save(fullfile(results_dir,sprintf('%s_rdm_avg.mat',filename)),'rdm_time_time_avg_standard');
elseif strcmp(fixation_condition, 'bulls') == 1
    rdm_time_time_avg_bulls = squeeze(mean(mean(rdm_time_time,1),2)); %average over permutations and pseudotrials
    filename = sprintf('objects_%s',fixation_condition);
    save(fullfile(results_dir,sprintf('%s_rdm_avg.mat',filename)),'rdm_time_time_avg_bulls');
end

end
