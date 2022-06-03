function [] = time_time_object_decoding_between_conditions(subj, method,fixation_condition)
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
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/object_time_time/%s/', BASE,subj);
    load(filepath_preprocessed_data)
    preprocessed_data = data_rej_channel_interpolated_timelocked;
elseif method == 2
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eyetracking/object_time_time/%s', BASE,subj);
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
%% split data into standard(2) and bullseye(1) fixation cross

% standard
cfg = [];
cfg.trials = find(preprocessed_data.trialinfo(:,5)=='2');
data_standard = ft_selectdata(cfg, preprocessed_data);

cfg = [];
cfg.trials = find(preprocessed_data.trialinfo(:,5)=='1');
data_bulls = ft_selectdata(cfg, preprocessed_data);

cfg=[];
cfg.resamplefs=50;
data_standard = ft_resampledata(cfg,data_standard);
time_points = size(data_standard.time,2);

cfg=[];
cfg.resamplefs=50;
data_bulls = ft_resampledata(cfg,data_bulls);


% minimum number of trials

[min_number_of_trials_standard, individual_objects_standard] = get_min_trial_per_object(data_standard);
[min_number_of_trials_bulls, individual_objects_bulls] = get_min_trial_per_object(data_bulls);

% Preallocate

for perm = 1:n_permutations
    %% TODO ASK SOMEONE WHETHER THIS WORKS LIKE THIS create data matrix for smallest possible amount of trials
    % the idea: calculate inverse covariance matrix for minimum amount of
    % trials for all conditions and use this matrix to normalize the
    % differing amounts of trials for each image ---> I am not sure whether
    % this is mathematically sound WHO TO ASK?
    min_num_trials_all_conditions = min(min(min_number_of_trials_bulls),min(min_number_of_trials_standard));
    data_matrix_MVNN_standard = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data_standard, 'object', individual_objects_standard);
    % get inverted covariance matrix
    [data_objA_objB_MVNN_standard, ~] = multivariate_noise_normalization(data_matrix_MVNN_standard);
    
    num_trials_per_bin_standard = round(min_num_trials_all_conditions/n_pseudotrials);
    pseudo_trials_standard = create_pseudotrials(n_conditions, num_trials_per_bin_standard, n_pseudotrials, data_objA_objB_MVNN_standard);
    
    data_matrix_MVNN_bulls = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data_bulls, 'object', individual_objects_bulls);
    % get inverted covariance matrix
    [data_objA_objB_MVNN_bulls, ~] = multivariate_noise_normalization(data_matrix_MVNN_bulls);
    
    num_trials_per_bin_bulls = round(min_num_trials_all_conditions/n_pseudotrials);
    pseudo_trials_bulls = create_pseudotrials(n_conditions, num_trials_per_bin_bulls, n_pseudotrials, data_objA_objB_MVNN_bulls);
    
    if train == 1
        pseudo_trial_training_data = pseudo_trials_standard;
        pesudo_trial_testing_data = pseudo_trials_bulls;
        filename = 'standard_bulls_object';
    elseif train == 2
        pseudo_trial_training_data = pseudo_trials_bulls;
        pesudo_trial_testing_data = pseudo_trials_standard;
        filename = 'bulls_standard_object';
    end
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            
            for time1 = 1:time_points
                training_data =[squeeze(pseudo_trial_training_data(objA,1:end-1,:,time1)) ; squeeze(pseudo_trial_training_data(objB,1:end-1,:,time1))];
                labels_train  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
                labels_test   = [1 2];
                
                disp('Train the SVM');
                train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
                model=svmtrain(labels_train',training_data,train_param_str);
                for time2 = 1:time_points
                    disp('Test the SVM');
                    testing_data  =[squeeze(pesudo_trial_testing_data(objA,end,:,time2))' ; squeeze(pesudo_trial_testing_data(objB,end,:,time2))'];
                    [~, accuracy, ~] = svmpredict(labels_test',testing_data,model);
                    decodingAccuracy_objects_time_time(perm,objA, objB, time1,time2)=accuracy(1);
                end
            end
        end
    end
end 

    if strcmp(fixation_condition, 'standard') == 1
        decodingAccuracy_objects_time_time_avg_standard = squeeze(nanmean(decodingAccuracy_objects_time_time,1)); %average over permutations
        filename = sprintf('objects_%s_%s',fixation_condition,filename);
        save(fullfile(results_dir,sprintf('%s_time_time_avg.mat',filename)),'decodingAccuracy_objects_time_time_avg_standard');
    elseif strcmp(fixation_condition, 'bulls') == 1
        decodingAccuracy_objects_time_time_avg_bulls = squeeze(nanmean(decodingAccuracy_objects_time_time,1)); %average over permutations
        filename = sprintf('objects_%s_%s',fixation_condition,filename);
        save(fullfile(results_dir,sprintf('%s_time_time_avg.mat',filename)),'decodingAccuracy_objects_time_time_avg_bulls');
    end
    
end
