function [outputArg1,outputArg2] = rdm_analysis_SVM_decoding(decoding,distance_measure)

out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/plots/';
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats/');
methods_flag = ["eeg" "eyetracking"];
decoding = 'object'
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(1)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(1)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(1)));
    
    decodingAcc_standard_eeg_raw = object_decodingAcc_standard_all;
    decodingAcc_bulls_eeg_raw = object_decodingAcc_bulls_all;
    decodingAcc_diff_wave_eeg_raw = object_difference_wave;
    
    decodingAcc_standard_eeg = squeeze(nanmean(nanmean(object_decodingAcc_standard_all,2),3));
    decodingAcc_bulls_eeg = squeeze(nanmean(nanmean(object_decodingAcc_bulls_all,2),3));
    decodingAcc_diff_wave_eeg = squeeze(nanmean(nanmean(object_difference_wave,2),3));
    
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(2)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(2)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(2)));
    
    decodingAcc_standard_eyetracking_raw = object_decodingAcc_standard_all;
    decodingAcc_bulls_eyetracking_raw = object_decodingAcc_bulls_all;
    decodingAcc_diff_wave_eyetracking_raw = object_difference_wave;
    
    decodingAcc_standard_eyetracking = squeeze(nanmean(nanmean(object_decodingAcc_standard_all,2),3));
    decodingAcc_bulls_eyetracking = squeeze(nanmean(nanmean(object_decodingAcc_bulls_all,2),3));
    decodingAcc_diff_wave_eyetracking = squeeze(nanmean(nanmean(object_difference_wave,2),3));
    
%     
%     load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(1)));
%     load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(1)));
%     load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(1)));
%     
%     decodingAcc_standard_eeg_raw = object_decodingAcc_standard_all;
%     decodingAcc_bulls_eeg_raw = object_decodingAcc_bulls_all;
%     decodingAcc_diff_wave_eeg_raw = object_difference_wave;
%     
%     decodingAcc_standard_eeg = squeeze(nanmean(nanmean(object_decodingAcc_standard_all,2),3));
%     decodingAcc_bulls_eeg = squeeze(nanmean(nanmean(object_decodingAcc_bulls_all,2),3));
%     decodingAcc_diff_wave_eeg = squeeze(nanmean(nanmean(object_difference_wave,2),3));
%     
%     load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(2)));
%     load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(2)));
%     load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(2)));
%     
%     decodingAcc_standard_eyetracking_raw = object_decodingAcc_standard_all;
%     decodingAcc_bulls_eyetracking_raw = object_decodingAcc_bulls_all;
%     decodingAcc_diff_wave_eyetracking_raw = object_difference_wave;
%     
%     decodingAcc_standard_eyetracking = squeeze(nanmean(nanmean(object_decodingAcc_standard_all,2),3));
%     decodingAcc_bulls_eyetracking = squeeze(nanmean(nanmean(object_decodingAcc_bulls_all,2),3));
%     decodingAcc_diff_wave_eyetracking = squeeze(nanmean(nanmean(object_difference_wave,2),3));
    
   
% size object decoding = [n_participants, objA, objB, time]

% first do the average and check for all subjects, but then you cannot
% generalize the findings to other people 
%%  Reshape the matrices: take only the upper diagonal, in vector form for the averaged subejcts 
avg_subject_RDM_eeg = squeeze(nanmean(decodingAcc_standard_eeg_raw,1));
avg_subject_RDM_eyetracking = squeeze(nanmean(decodingAcc_standard_eyetracking_raw,1));

%%  Reshape the matrices: take only the upper diagonal, in vector form
%EEG 
if find(isnan(avg_subject_RDM_eeg)) >0 %full matrix version
    numTimepoints_eeg = size(avg_subject_RDM_eeg,3);
    avg_subject_RDM_eeg(isnan(avg_subject_RDM_eeg)) = 0;
    rdm_flattened_cell_eeg = arrayfun(@(x) squareform(avg_subject_RDM_eeg(:,:,x)+(avg_subject_RDM_eeg(:,:,x))'),...
                1:numTimepoints_eeg,'UniformOutput',false);
    rdm_flattened_eeg = reshape(cell2mat(rdm_flattened_cell_eeg),[],numTimepoints_eeg);
else
    numTimepoints_eeg = size(avg_subject_RDM_eeg,2);
    rdm_flattened_eeg = avg_subject_RDM_eeg;
end

%eyetracking
if find(isnan(avg_subject_RDM_eyetracking)) >0 %full matrix version
    numTimepoints_eyetracking = size(avg_subject_RDM_eyetracking,3);
    avg_subject_RDM_eyetracking(isnan(avg_subject_RDM_eyetracking)) = 0;
    rdm_flattened_cell_eyetracking = arrayfun(@(x) squareform(avg_subject_RDM_eyetracking(:,:,x)+(avg_subject_RDM_eyetracking(:,:,x))'),...
                1:numTimepoints_eyetracking,'UniformOutput',false);
    rdm_flattened_eyetracking = reshape(cell2mat(rdm_flattened_cell_eyetracking),[],numTimepoints_eyetracking);
else
    numTimepoints_eyetracking = size(avg_subject_RDM_eyetracking,2);
    rdm_flattened_eyetracking = avg_subject_RDM_eyetracking;
end

%% Perfom RSA at each EEG timepoint
rdm_rsa = NaN(1,numTimepoints_eeg);
for time = 1:numTimepoints_eeg
    rdm_rsa(time) = corr(rdm_flattened_eeg(:,time),rdm_flattened_eyetracking(:,time),'type','Spearman');
end
plot(rdm_rsa)

end

