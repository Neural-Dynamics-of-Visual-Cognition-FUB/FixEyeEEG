function [] = object_decoding_train_test(subj, method, train)
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


subj = num2str(subj);

% 1 == EEG, 2 == eyetracking
if method == 1
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/preprocessed_noICA_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/object_train_test/%s/', BASE,subj);
    load(filepath_preprocessed_data)
    preprocessed_data = data_rej_channel_interpolated_timelocked;
elseif method == 2
    filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/%s/timelocked/eyetracking_data_timelocked.mat',BASE,subj);
    results_dir = sprintf('%sdata/FixEyeEEG/main/eyetracking/object_train_test/%s', BASE,subj);
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

% standard
cfg = [];
cfg.trials = find(preprocessed_data.trialinfo(:,5)=='2');
data_standard = ft_selectdata(cfg, preprocessed_data);

cfg = [];
cfg.trials = find(preprocessed_data.trialinfo(:,5)=='1');
data_bulls = ft_selectdata(cfg, preprocessed_data);



% minimum number of trials

[min_number_of_trials_standard, individual_objects_standard] = get_min_trial_per_object(data_standard);
[min_number_of_trials_bulls, individual_objects_bulls] = get_min_trial_per_object(data_bulls);

% Preallocate
decodingAccuracy_objects=NaN(n_permutations, n_conditions, n_conditions, time_points);

for perm = 1:n_permutations
    %% TODO ASK SOMEONE WHETHER THIS WORKS LIKE THIS create data matrix for smallest possible amount of trials
    % the idea: calculate inverse covariance matrix for minimum amount of
    % trials for all conditions and use this matrix to normalize the
    % differing amounts of trials for each image ---> I am not sure whether
    % this is mathematically sound WHO TO ASK?
    min_num_trials_all_conditions = min(min(min_number_of_trials_bulls),min(min_number_of_trials_standard));
    data_matrix_MVNN_standard = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data_standard, 'object', individual_objects_standard);
    % get inverted covariance matrix
    [~, inverted_sigma_standard] = multivariate_noise_normalization(data_matrix_MVNN_standard);
    
    data_matrix_MVNN_bulls = create_data_matrix_MVNN(n_conditions, min_num_trials_all_conditions, data_bulls, 'object', individual_objects_bulls);
    % get inverted covariance matrix
    [~, inverted_sigma_bulls] = multivariate_noise_normalization(data_matrix_MVNN_bulls);
    %%
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            %calculate minimum number of trials possible for this specific
            %pair
            
            %% standard
            min_num_trial_standard = min(min_number_of_trials_standard(objA),min_number_of_trials_standard(objB));
            min_num_trial_bulls = min(min_number_of_trials_bulls(objA),min_number_of_trials_bulls(objB));
            min_num_trial=min(min_num_trial_standard,min_num_trial_bulls);
            data_objA_objB_standard= create_data_matrix(2, min_num_trial, data_standard, objA, objB, individual_objects_standard);
            data_objA_objB_bulls= create_data_matrix(2, min_num_trial, data_bulls, objA, objB, individual_objects_bulls);
            
            %% TODO ASK SOMEONE WHETHER THIS WORKS LIKE THIS normalise data matrix with inverted covariance matrix (MVNN)
            data_objA_objB_MVNN_standard = NaN(size(data_objA_objB_standard));
            for t = 1:time_points %and for each condition
                for c = 1:2
                    for tr = 1:min_num_trial
                        X = squeeze(data_objA_objB_standard(c,tr,:,t))';
                        data_objA_objB_MVNN_standard(c,tr,:,t) = X*inverted_sigma_standard;
                    end
                end
            end
            %%
            num_trials_per_bin = round(min_num_trial/n_pseudotrials);
            %pseudo_trials = create_pseudotrials(2, num_trials_per_bin, n_pseudotrials, data_objA_objB);
            pseudo_trials_standard = create_pseudotrials(2, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN_standard);
            
            %% bulls
            data_objA_objB_MVNN_bulls = NaN(size(data_objA_objB_bulls));
            for t = 1:time_points %and for each condition
                for c = 1:2
                    for tr = 1:min_num_trial
                        X = squeeze(data_objA_objB_bulls(c,tr,:,t))';
                        data_objA_objB_MVNN_standard(c,tr,:,t) = X*inverted_sigma_bulls;
                    end
                end
            end
            %%
            num_trials_per_bin = round(min_num_trial/n_pseudotrials);
            %pseudo_trials = create_pseudotrials(2, num_trials_per_bin, n_pseudotrials, data_objA_objB);
            pseudo_trials_bulls = create_pseudotrials(2, num_trials_per_bin, n_pseudotrials, data_objA_objB_MVNN_bulls);
            
            if train == 1
                pseudo_trial_training_data = pseudo_trials_standard;
                pesudo_trial_testing_data = pseudo_trials_bulls;
                filename = 'standard_bulls_object';
            elseif train == 2
                pseudo_trial_training_data = pseudo_trials_bulls;
                pesudo_trial_testing_data = pseudo_trials_standard;
                filename = 'bulls_standard_object';
            end
            for time = 1:time_points
                %% standard
                training_data =[squeeze(pseudo_trial_training_data(1,1:end-1,:,time)) ; squeeze(pseudo_trial_training_data(2,1:end-1,:,time))];
                testing_data  =[squeeze(pesudo_trial_testing_data(1,end,:,time))' ; squeeze(pesudo_trial_testing_data(2,end,:,time))'];
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
    decodingAccuracy_object_avg = squeeze(nanmean(decodingAccuracy_objects,1));
    save(fullfile(results_dir,sprintf('%s_decodingAccuracy_train_standard.mat',filename)),'decodingAccuracy_object_avg');

end