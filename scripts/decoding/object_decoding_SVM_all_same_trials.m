function [] = object_decoding_SVM_all_same_trials(subj, fixation_condition, method)
%{
    - Multivariate Noise Normalisation
    - object decoding for both fixation crosses for animate versus
    inanimate objects
    - decoding on all channels
    - decoding on pseudotrials
    - leave one pseudotrial out cross validation
    - decode with SVM
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
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/preprocessed_noICA_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/object_decoding_all_same_trials/%s/', BASE,subj);
    load(filepath_preprocessed_data)
    preprocessed_data = data_rej_channel_interpolated_timelocked;
elseif method == 2
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/eyetracking_data_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eyetracking/object_decoding_all_same_trials/%s', BASE,subj);
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

% Preallocate
decodingAccuracy_objects=NaN(n_permutations, n_conditions, n_conditions, time_points);

for perm = 1:n_permutations
    %% TODO ASK SOMEONE WHETHER THIS WORKS LIKE THIS create data matrix for smallest possible amount of trials
    % the idea: calculate inverse covariance matrix for minimum amount of
    % trials for all conditions and use this matrix to normalize the
    % differing amounts of trials for each image ---> I am not sure whether
    % this is mathematically sound WHO TO ASK?
    min_num_trials_all_conditions = min(min_number_of_trials);
    data_matrix_MVNN = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data, 'object', individual_objects);
    % get inverted covariance matrix
    [data_objA_objB_MVNN, ~] = multivariate_noise_normalization(data_matrix_MVNN);
    num_trials_per_bin = round(min_num_trials_all_conditions/n_pseudotrials);
    pseudo_trials = create_pseudotrials(n_conditions, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN);
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            for time = 1:time_points
                %% standard
                training_data =[squeeze(pseudo_trials(objA,1:end-1,:,time)) ; squeeze(pseudo_trials(objB,1:end-1,:,time))];
                testing_data  =[squeeze(pseudo_trials(objA,end,:,time))' ; squeeze(pseudo_trials(objB,end,:,time))'];
                labels_train  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
                labels_test   = [1 2];
                
                disp('Train the SVM');
                train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
                model=svmtrain(labels_train',training_data,train_param_str);
                
                disp('Test the SVM');
                [~, accuracy, ~] = svmpredict(labels_test',testing_data,model);
                decodingAccuracy_objects(perm,objA, objB, time)=accuracy(1);
                
            end
        end
    end
end
%% Save the decision values + decoding accuracy
if strcmp(fixation_condition, 'standard') == 1
    decodingAccuracy_object_standard_avg = squeeze(mean(decodingAccuracy_objects,1));
    filename = sprintf('objects_%s',fixation_condition);
    save(fullfile(results_dir,sprintf('%s_decodingAccuracy.mat',filename)),'decodingAccuracy_object_standard_avg');
elseif strcmp(fixation_condition, 'bulls') == 1
    decodingAccuracy_object_bulls_avg = squeeze(mean(decodingAccuracy_objects,1));
    filename = sprintf('objects_%s',fixation_condition);
    save(fullfile(results_dir,sprintf('%s_decodingAccuracy.mat',filename)),'decodingAccuracy_object_bulls_avg');
end



end