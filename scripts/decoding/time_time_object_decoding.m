function [] = time_time_object_decoding(subj, fixation_condition, method)
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

for perm = 1:n_permutations
    %% MVNN
    
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            min_num_trials_all_conditions = min(min_number_of_trials);
            data_matrix_MVNN = create_data_matrix(2, min_number_of_trials, data, objA, objB, individual_objects);
            % get inverted covariance matrix
            [data_objA_objB_MVNN, ~] = multivariate_noise_normalization(data_matrix_MVNN);
            
            num_trials_per_bin = round(min_num_trials_all_conditions/n_pseudotrials);
            pseudo_trials = create_pseudotrials(2, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN);
            for time1 = 1:time_points
                training_data =[squeeze(pseudo_trials(1,1:end-1,:,time1)) ; squeeze(pseudo_trials(2,1:end-1,:,time1))];
                labels_train  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
                labels_test   = [1 2];
                
                disp('Train the SVM');
                train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
                model=svmtrain(labels_train',training_data,train_param_str);
                for time2 = 1:time_points
                    disp('Test the SVM');
                    testing_data  =[squeeze(pseudo_trials(1,end,:,time2))' ; squeeze(pseudo_trials(2,end,:,time2))'];
                    [~, accuracy, ~] = svmpredict(labels_test',testing_data,model);
                    decodingAccuracy_objects_time_time(perm,objA, objB, time1,time2)=accuracy(1);
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
