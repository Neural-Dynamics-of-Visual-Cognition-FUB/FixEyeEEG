function [] = time_time_object_decoding(subj, method,within)
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
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/EEG');
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/EEG/MEG_SVM_decoding_MVNN/');
    addpath('/Users/ghaeberle/Documents/MATLAB/libsvm/matlab');
    addpath('/Users/ghaeberle/Documents/MATLAB/fieldtrip-20210928/')
    ft_defaults
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/EEG');
    addpath('/home/haebeg19/FixEyeEEG/scripts/EEG/MEG_SVM_decoding_MVNN/');
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
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/pearsson/%s/', BASE,subj);
    load(filepath_preprocessed_data)
    preprocessed_data = data_rej_channel_interpolated_timelocked;
elseif method == 2
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eyetracking/pearsson/%s', BASE,subj);
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

if within == 1
    % standard
    cfg = [];
    cfg.trials = find(preprocessed_data.trialinfo(:,5)=='2');
    data_train = ft_selectdata(cfg, preprocessed_data);
    
    cfg = [];
    cfg.trials = find(preprocessed_data.trialinfo(:,5)=='1');
    data_test = ft_selectdata(cfg, preprocessed_data);
elseif within == 2
    cfg = [];
    cfg.trials = find(preprocessed_data.trialinfo(:,5)=='2');
    data_test = ft_selectdata(cfg, preprocessed_data);
    cfg = [];
    cfg.trials = find(preprocessed_data.trialinfo(:,5)=='1');
    data_train = ft_selectdata(cfg, preprocessed_data);
end


% minimum number of trials

[min_number_of_trials_test, individual_objects_test] = get_min_trial_per_object(data_test);
[min_number_of_trials_train, individual_objects_train] = get_min_trial_per_object(data_train);
min_number_of_trials = min(min_number_of_trials_test,min_number_of_trials_train);
% Preallocate
decodingAccuracy_objects_time_time=NaN(n_permutations, n_conditions, n_conditions, time_points, time_points);

for perm = 1:n_permutations
    %% MVNN 
    min_num_trials_all_conditions = min(min_number_of_trials);
    data_matrix_MVNN_train = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data, 'object', individual_objects_train);
    data_matrix_MVNN_test = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data, 'object', individual_objects_test);
    % get inverted covariance matrix
    [data_objA_objB_MVNN_train, ~] = multivariate_noise_normalization(data_matrix_MVNN_train);
    [data_objA_objB_MVNN_test, ~] = multivariate_noise_normalization(data_matrix_MVNN_test);
    
    num_trials_per_bin = round(min_num_trials_all_conditions/n_pseudotrials);
    pseudo_trials_train = create_pseudotrials(n_conditions, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN_train);
    pseudo_trials_test = create_pseudotrials(n_conditions, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN_test);
    
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            for time = 1:time_points
            training_data =[squeeze(pseudo_trials_train(1,1:end-1,:,time)) ; squeeze(pseudo_trials_train(2,1:end-1,:,time))];
            testing_data  =[squeeze(pseudo_trials_test(1,end,:,time))' ; squeeze(pseudo_trials_test(2,end,:,time))'];
            labels_train  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
            labels_test   = [1 2];

            disp('Train the SVM');
            train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
            model=svmtrain(labels_train',training_data,train_param_str); 

            disp('Test the SVM');
            [~, accuracy, ~] = svmpredict(labels_test',testing_data,model);  
            decodingAccuracy_objects_time_time(perm,objB, objA, time)=accuracy(1);                 
            end
        end
    end
end

if strcmp(fixation_condition, 'standard') == 1
    rdm_avg_standard = squeeze(nanmean(nanmean(decodingAccuracy_objects_time_time,1),2)); %average over permutations and pseudotrials
    filename = sprintf('objects_%s',fixation_condition);
    save(fullfile(results_dir,sprintf('%s_rdm_avg.mat',filename)),'rdm_avg_standard');
elseif strcmp(fixation_condition, 'bulls') == 1
    rdm_avg_bulls = squeeze(mean(mean(decodingAccuracy_objects_time_time,1),2)); %average over permutations and pseudotrials
    filename = sprintf('objects_%s',fixation_condition);
    save(fullfile(results_dir,sprintf('%s_rdm_avg.mat',filename)),'rdm_avg_bulls');
end

end
