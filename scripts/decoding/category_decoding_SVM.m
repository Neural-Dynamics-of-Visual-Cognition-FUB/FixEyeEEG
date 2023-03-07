function [] = category_decoding_SVM(subj, method)
%{
    - Multivariate Noise Normalisation
    - category decoding for both fixation crosses for animate versus
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



%% load data
subj = num2str(subj);
n_permutations = 100;
n_pseudotrials = 6;
num_conditions = 2; %categories to decode

% 1 = EEG, 2 = Eyetracking
if method == 1
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/preprocessed_noICA_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/category_decoding/%s', BASE,subj);
    load(filepath_preprocessed_data)
    data = data_rej_channel_interpolated_timelocked;
elseif method == 2
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eyetracking/category_decoding/%s', BASE,subj);
    load(filepath_preprocessed_data)
    data = eye_data_baseline_timelocked;
end

if ~isfolder(results_dir)
    mkdir(results_dir);
end

%% define required information
time_points = size(data.time,2);

%% split data into standard(2) and bullseye(1) fixation cross
% standard
cfg = [];
cfg.trials = find(data.trialinfo(:,5)=='2');
data_standard = ft_selectdata(cfg, data);

% bullseye
cfg = [];
cfg.trials = find(data.trialinfo(:,5)=='1');
data_bulls = ft_selectdata(cfg, data);

% minimum number of trials standard
number_of_trial_animate_standard = sum(data_standard.trialinfo(:,3)=='1','all');
number_of_trial_inanimate_standard = sum(data_standard.trialinfo(:,3)=='0','all');

number_of_trial_animate_bulls = sum(data_bulls.trialinfo(:,3)=='1','all');
number_of_trial_inanimate_bulls = sum(data_bulls.trialinfo(:,3)=='0','all');

min_number_of_trials = min([number_of_trial_animate_standard,number_of_trial_inanimate_standard, number_of_trial_animate_bulls,number_of_trial_inanimate_bulls] );

% Preallocate
decodingAccuracy_standard=NaN(n_permutations,time_points);
decodingAccuracy_bulls=NaN(n_permutations,time_points);

%% do the actual decoding
for perm = 1:n_permutations
    
    
    %%  MVNN
    %   create NxMxExTP matrix containing EEG data, where N is the
    %   number of conditioins, M is the number of trials, E is the number of
    %   electrodes and TP is the number of timepoints.
    
    data_MVNN_standard = create_data_matrix_MVNN(num_conditions, min_number_of_trials, data_standard, 'category');
    data_MVNN_bulls = create_data_matrix_MVNN(num_conditions, min_number_of_trials, data_bulls, 'category');
    
    % actually do the MVNN
    [data_MVNN_standard, ~] = multivariate_noise_normalization(data_MVNN_standard);
    [data_MVNN_bulls, ~] = multivariate_noise_normalization(data_MVNN_bulls);
    %% split data into animate and inanimate trials
    data_animate_standard = data_MVNN_standard(1,:,:,:);
    data_inanimate_standard = data_MVNN_standard(2,:,:,:);
    
    data_animate_bulls = data_MVNN_bulls(1,:,:,:);
    data_inanimate_bulls = data_MVNN_bulls(2,:,:,:);
    %% create pseudotrials standard
    disp('Permute the trials')
    data_animate_standard_permuted = data_animate_standard(:, randperm(size(data_animate_standard,2)),:,:);
    data_inanimate_standard_permuted = data_inanimate_standard(:,randperm(size(data_inanimate_standard,2)),:,:);
    
    disp('Put both categories into one matrix');
    data_both_categories_standard = NaN([size(data_animate_standard_permuted)]);
    data_both_categories_standard(1,:,:,:) = data_animate_standard_permuted;
    data_both_categories_standard(2,:,:,:) = data_inanimate_standard_permuted;
    
    disp('Split into pseudotrials');
    num_trials_per_bin = round(min_number_of_trials/n_pseudotrials);
    pseudo_trials_standard = create_pseudotrials(num_conditions, num_trials_per_bin, n_pseudotrials, data_both_categories_standard);
    
    %% create pseudotrials bulls
    disp('Permute the trials')
    data_animate_bulls_permuted = data_animate_bulls(:, randperm(size(data_animate_bulls,2)),:,:);
    data_inanimate_bulls_permuted = data_inanimate_bulls(:,randperm(size(data_inanimate_bulls,2)),:,:);
    
    disp('Put both categories into one matrix');
    data_both_categories_bulls = NaN([size(data_animate_bulls_permuted)]);
    data_both_categories_bulls(1,:,:,:) = data_animate_bulls_permuted;
    data_both_categories_bulls(2,:,:,:) = data_inanimate_bulls_permuted;
    
    disp('Split into pseudotrials');
    num_trials_per_bin = round(min_number_of_trials/n_pseudotrials);
    pseudo_trials_bulls = create_pseudotrials(num_conditions, num_trials_per_bin, n_pseudotrials, data_both_categories_bulls);
    
    %% do the actual decoding
    for time = 1:time_points
        
        %% standard
        % split into trainung and testing
        training_data_standard=[squeeze(pseudo_trials_standard(1,1:end-1,:,time)) ; squeeze(pseudo_trials_standard(2,1:end-1,:,time))];
        testing_data_standard=[squeeze(pseudo_trials_standard(1,end,:,time))' ; squeeze(pseudo_trials_standard(2,end,:,time))'];
        
        % create labels for the SVM
        labels_train_standard  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
        labels_test_standard   = [1 2];
        
        disp('Train the SVM');
        train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
        model_standard=svmtrain(labels_train_standard',training_data_standard,train_param_str);
        
        disp('Test the SVM');
        [~, accuracy_standard, ~] = svmpredict(labels_test_standard',testing_data_standard,model_standard);
        decodingAccuracy_standard(perm,time)=accuracy_standard(1);
        
        %% bulls
        % split into trainung and testing
        training_data_bulls=[squeeze(pseudo_trials_bulls(1,1:end-1,:,time)) ; squeeze(pseudo_trials_bulls(2,1:end-1,:,time))];
        testing_data_bulls=[squeeze(pseudo_trials_bulls(1,end,:,time))' ; squeeze(pseudo_trials_bulls(2,end,:,time))'];
        
        % create labels for the SVM
        labels_train_bulls  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
        labels_test_bulls   = [1 2];
        
        disp('Train the SVM');
        train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
        model_bulls=svmtrain(labels_train_bulls',training_data_bulls,train_param_str);
        
        disp('Test the SVM');
        [~, accuracy_bulls, decision_values_bulls] = svmpredict(labels_test_bulls',testing_data_bulls,model_bulls);
        decodingAccuracy_bulls(perm,time)=accuracy_bulls(1);
        
    end
end

%% Save the decision values + decoding accuracy
decodingAccuracy_avg_standard = squeeze(mean(decodingAccuracy_standard,1));
decodingAccuracy_avg_bulls = squeeze(mean(decodingAccuracy_bulls,1));
filename = 'animate_inanimate_category';
save(fullfile(results_dir,sprintf('%s_decodingAccuracy_standard.mat',filename)),'decodingAccuracy_avg_standard');
save(fullfile(results_dir,sprintf('%s_decodingAccuracy_bulls.mat',filename)),'decodingAccuracy_avg_bulls');
save(fullfile(results_dir,sprintf('%s_decodingAccuracy_min_number_trials.mat',filename)),'min_number_of_trials');

end

