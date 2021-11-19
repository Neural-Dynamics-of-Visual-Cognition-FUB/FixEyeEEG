function [] = object_decoding_SVM(subj)
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


subj = num2str(subj);
filepath_preprocessed_data = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/preprocessed_noICA_timelocked.mat',BASE,subj);
%end
results_dir = sprintf('%sdata/FixEyeEEG/main/eeg/decoding/%s', BASE,subj);

if ~isfolder(results_dir)
    mkdir(results_dir);
end

% load eeg data 
load(filepath_preprocessed_data);

%% define required information 
n_permutations = 100;
n_pseudotrials = 6;
n_conditions = 40; %objects to decode
time_points = size(data_rej_channel_interpolated_timelocked.time,2);
%% split data into standard(2) and bullseye(1) fixation cross
% standard 
cfg = [];
cfg.trials = find(data_rej_channel_interpolated_timelocked.trialinfo(:,5)=='2');
data_standard = ft_selectdata(cfg, data_rej_channel_interpolated_timelocked);
    
% bullseye 
cfg = [];
cfg.trials = find(data_rej_channel_interpolated_timelocked.trialinfo(:,5)=='1');
data_bulls = ft_selectdata(cfg, data_rej_channel_interpolated_timelocked);
    
% minimum number of trials

min_number_of_trials_standard = get_min_trial_per_object(data_standard);
min_number_of_trials_bulls = get_min_trial_per_object(data_bulls);


% Preallocate 
decodingAccuracy_standard_object=NaN(n_permutations, n_conditions, n_conditions, time_points);
decodingAccuracy_bulls_object=NaN(n_permutations, n_conditions, n_conditions, time_points);

for perm = 1:n_permutations
    for objA = 1:n_conditions - 1
        for objB = objA+1:n_conditions
            %calculate minimum number of trials possible for this specific
            %pair 
            
            %% standard 
            min_num_trial_standard = min(min_number_of_trials_standard(objA),min_number_of_trials_standard(objB));
            data_objA_objB_standard= create_data_matrix(2, min_num_trial_standard, data_standard, objA, objB);
            
            num_trials_per_bin_standard = round(min_number_of_trials_standard/n_pseudotrials);
            pseudo_trials_standard = create_pseudotrials(2, num_trials_per_bin_standard, n_pseudotrials, data_objA_objB_standard);
            
            %% bulls eye 
            
            min_num_trial_bulls = min(min_number_of_trials_bulls(objA),min_number_of_trials_bulls(objB));
            data_objA_objB_bulls= create_data_matrix(2, min_num_trial_bulls, data_bulls, objA, objB);
            
            num_trials_per_bin_bulls = round(min_number_of_trials_bulls/n_pseudotrials);
            pseudo_trials_bulls = create_pseudotrials(2, num_trials_per_bin_bulls, n_pseudotrials, data_objA_objB_bulls);
            
            
            for time = 1:time_points
            %% standard    
            training_data_standard=[squeeze(pseudo_trials_standard(1,1:end-1,:,time)) ; squeeze(pseudo_trials_standard(2,1:end-1,:,time))];
            testing_data_standard=[squeeze(pseudo_trials_standard(1,end,:,time))' ; squeeze(pseudo_trials_standard(2,end,:,time))'];
            labels_train_standard  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
            labels_test_standard   = [1 2];

            disp('Train the SVM');
            train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
            model_standard=svmtrain(labels_train_standard',training_data_standard,train_param_str); 

            disp('Test the SVM');
            [~, accuracy_standard, ~] = svmpredict(labels_test_standard',testing_data_standard,model_standard);  
            decodingAccuracy_standard_object(perm,objA, objB, time)=accuracy_standard(1); 
            
            %% bullseye 
            
            training_data_bulls=[squeeze(pseudo_trials_bulls(1,1:end-1,:,time)) ; squeeze(pseudo_trials_bulls(2,1:end-1,:,time))];
            testing_data_bulls=[squeeze(pseudo_trials_bulls(1,end,:,time))' ; squeeze(pseudo_trials_bulls(2,end,:,time))'];
            labels_train_bulls  = [ones(1,n_pseudotrials-1) 2*ones(1,n_pseudotrials-1)];
            labels_test_bulls   = [1 2];

            disp('Train the SVM');
            train_param_str=  '-s 0 -t 0 -b 0 -c 1 -q';
            model_bulls=svmtrain(labels_train_bulls',training_data_bulls,train_param_str); 

            disp('Test the SVM');
            [~, accuracy_bulls, ~] = svmpredict(labels_test_bulls',testing_data_bulls,model_bulls);  
            decodingAccuracy_bulls_object(perm,objA, objB, time)=accuracy_bulls(1); 
            
            end
        end
    end
end
 %% Save the decision values + decoding accuracy
    decodingAccuracy_standard_object_avg = squeeze(mean(decodingAccuracy_standard_object,1)); 
    decodingAccuracy_avg_bulls_avg = squeeze(mean(decodingAccuracy_bulls_object,1));
    filename = 'animate_inanimate_category';
    save(fullfile(results_dir,sprintf('%s_decodingAccuracy_objects_standard.mat',filename)),'decodingAccuracy_standard_object_avg');
    save(fullfile(results_dir,sprintf('%s_decodingAccuracy_objects_bulls.mat',filename)),'decodingAccuracy_avg_bulls_avg');
    %save(fullfile(results_dir,sprintf('%s_decodingAccuracy_objects_min_number_trials.mat',filename)),'min_number_of_trials');  
end

