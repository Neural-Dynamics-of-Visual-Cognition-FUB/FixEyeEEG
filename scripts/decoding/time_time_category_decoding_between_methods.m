function [] = time_time_category_decoding_between_methods(subj, fixation_condition, method)
%{
    - Multivariate Noise Normalisation
    - category decoding for both fixation crosses for animate versus
    inanimate objects
    - decoding on all channels
    - decoding on pseudotrials
    - leave one pseudotrial out cross validation
    - decode with SVM
    - within 0 = train on standard test on bulls
    - within 1 = train on bulls test on standard
    - within 2 = within standard
    - within 3 = within bulls
    
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
%%%%TODO add the subject information for the loop here

subj = num2str(subj);
n_permutations = 100;
n_pseudotrials = 6;
num_conditions = 2; %categories to decode

if fixation_condition == 2
    fixation_condition = 'standard';
elseif fixation_condition == 1
    fixation_condition = 'bulls';
end

if method == 2
    order = 'eyetracking_EEG';
elseif method == 1
    order = 'EEG_eyetracking';
end

    filepath_preprocessed_data_EEG = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/preprocessed_noICA_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg_eyetracking/category_time_time/%s', BASE,subj);
    load(filepath_preprocessed_data_EEG)
    preprocessed_data_EEG = data_rej_channel_interpolated_timelocked;
    filepath_preprocessed_data_eyetracking = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    load(filepath_preprocessed_data_eyetracking)
    filepath_preprocessed_data_eyetracking = eye_data_baseline_timelocked;

if ~isfolder(results_dir)
    mkdir(results_dir);
end


%% define required information

time_points = size(preprocessed_data.time,2);
%% split data into standard(2) and bullseye(1) fixation cross
    if strcmp(fixation_condition, 'standard') == 1
        cfg = [];
        cfg.trials = find(preprocessed_data_EEG.trialinfo(:,5)=='2');
        data_EEG = ft_selectdata(cfg, preprocessed_data_EEG);
        cfg = [];
        cfg.trials = find(preprocessed_data_eyetracking.trialinfo(:,5)=='2');
        data_eyetracking = ft_selectdata(cfg, preprocessed_data_eyetracking);
    elseif strcmp(fixation_condition, 'bulls') == 1
        cfg = [];
        cfg.trials = find(preprocessed_data_EEG.trialinfo(:,5)=='1');
        data_EEG = ft_selectdata(cfg, preprocessed_data_EEG);
        cfg = [];
        cfg.trials = find(preprocessed_data_eyetracking.trialinfo(:,5)=='1');
        data_eyetracking = ft_selectdata(cfg, preprocessed_data_eyetracking);
    end

% minimum number of trials standard
number_of_trial_animate_EEG = sum(data_EEG.trialinfo(:,3)=='1','all');
number_of_trial_inanimate_EEG = sum(data_EEG.trialinfo(:,3)=='0','all');

min_number_of_trials_EEG = min([number_of_trial_animate_EEG,number_of_trial_inanimate_EEG] );

number_of_trial_animate_eyetracking = sum(data_eyetracking.trialinfo(:,3)=='1','all');
number_of_trial_inanimate_eyetracking = sum(data_eyetracking.trialinfo(:,3)=='0','all');

min_number_of_trials_eyetracking = min([number_of_trial_animate_eyetracking,number_of_trial_inanimate_eyetracking] );

% Preallocate
decodingAccuracy=NaN(n_permutations,time_points,time_points);

%% do the actual decoding
for perm = 1:n_permutations
    
    
    %%  MVNN
    %   create NxMxExTP matrix containing EEG data, where N is the
    %   number of conditioins, M is the number of trials, E is the number of
    %   electrodes and TP is the number of timepoints.
    
    data_MVNN_EEG = create_data_matrix_MVNN(num_conditions, min_number_of_trials_EEG, data_EEG, 'category');
    data_MVNN_eyetracking = create_data_matrix_MVNN(num_conditions, min_number_of_trials_eyetracking, data_eyetracking, 'category');

    % actually do the MVNN
    [data_MVNN_EEG, ~] = multivariate_noise_normalization(data_MVNN_EEG);
    %% split data into animate and inanimate trials
    data_animate_EEG = data_MVNN_EEG(1,:,:,:);
    data_inanimate_EEG = data_MVNN_EEG(2,:,:,:);
    
    [data_MVNN_eyetracking, ~] = multivariate_noise_normalization(data_MVNN_eyetracking);
    %% split data into animate and inanimate trials
    data_animate_eyetracking = data_MVNN_eyetracking(1,:,:,:);
    data_inanimate_eyetracking = data_MVNN_eyetracking(2,:,:,:);    
    
    %% create pseudotrials standard
    disp('Permute the trials')
    data_animate_permuted_EEG = data_animate_EEG(:, randperm(size(data_animate_EEG,2)),:,:);
    data_inanimate_permuted_EEG = data_inanimate_EEG(:,randperm(size(data_inanimate_EEG,2)),:,:);
    
    data_animate_permuted_eyetracking = data_animate_eyetracking(:, randperm(size(data_animate_eyetracking,2)),:,:);
    data_inanimate_permuted_eyetracking = data_inanimate_eyetracking(:,randperm(size(data_inanimate_eyetracking,2)),:,:);
    
    disp('Put both categories into one matrix');
    data_both_categories_EEG = NaN(size(data_animate_permuted_EEG));
    data_both_categories_EEG(1,:,:,:) = data_animate_permuted_EEG;
    data_both_categories_EEG(2,:,:,:) = data_inanimate_permuted_EEG;
    
    data_both_categories_eyetracking = NaN(size(data_animate_permuted_eyetracking));
    data_both_categories_eyetracking(1,:,:,:) = data_animate_permuted_eyetracking;
    data_both_categories_eyetracking(2,:,:,:) = data_inanimate_permuted_eyetracking;   
    
    disp('Split into pseudotrials');
    num_trials_per_bin_EEG = round(min_number_of_trials_EEG/n_pseudotrials);
    pseudo_trials_EEG = create_pseudotrials(num_conditions, num_trials_per_bin_EEG, n_pseudotrials, data_both_categories_EEG);
    
    num_trials_per_bin_eyetracking = round(min_number_of_trials_eyetracking/n_pseudotrials);
    pseudo_trials_eyetracking = create_pseudotrials(num_conditions, num_trials_per_bin_eyetracking, n_pseudotrials, data_both_categories_eyetracking);
    %% do the actual decoding
    if method == 1 
        pseudo_trials_training = pseudo_trials_EEG;
        pseudo_trials_testing = pseudo_trials_eyetracking;
    elseif method == 2
        pseudo_trials_training = pseudo_trials_eyetracking;
        pseudo_trials_testing = pseudo_trials_EEG;
    end 
    for time1 = 1:time_points
        
        %% standard
        % split into trainung and testing
        training_data=[squeeze(pseudo_trials_training(1,1:end-1,:,time1)) ; squeeze(pseudo_trials_training(2,1:end-1,:,time1))];
        % create labels for the SVM
        labels_train = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
        
        disp('Train the SVM');
        train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
        model = svmtrain(labels_train',training_data,train_param_str);
        for time2 = 1:time_points
            testing_data=[squeeze(pseudo_trials_testing(1,end,:,time2))' ; squeeze(pseudo_trials_testing(2,end,:,time2))'];
            labels_test   = [1 2];
            
            disp('Test the SVM');
            [~, accuracy, ~] = svmpredict(labels_test',testing_data,model);
            decodingAccuracy(perm,time1,time2)=accuracy(1);
        end
    end
end

%% Save the decision values + decoding accuracy
if strcmp(fixation_condition, 'standard') == 1
    decodingAccuracy_avg_standard = squeeze(mean(decodingAccuracy,1));
    filename = sprintf('category_%s_%s',fixation_condition,order);
    save(fullfile(results_dir,sprintf('%s_time_time_avg.mat',filename)),'decodingAccuracy_avg_standard');
elseif strcmp(fixation_condition, 'bulls') == 1
    decodingAccuracy_avg_bulls = squeeze(mean(decodingAccuracy,1));
    filename = sprintf('category_%s_%s',fixation_condition,order);
    save(fullfile(results_dir,sprintf('%s_time_time_avg.mat',filename)),'decodingAccuracy_avg_bulls');
end
end


