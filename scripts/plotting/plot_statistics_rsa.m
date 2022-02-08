function [outputArg1,outputArg2] = plot_statistics_rsa(split_half)

split_half = 0; 
out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/plots/';
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats/');
methods_flag = ["eeg" "eyetracking"];
decoding = 'object';
%% decoding accuracies 
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(1)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(1)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(1)));
    
    decodingAcc_standard_eeg = object_decodingAcc_standard_all;
    decodingAcc_bulls_eeg = object_decodingAcc_bulls_all;
    decodingAcc_diff_wave_eeg = object_difference_wave;
    
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(2)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(2)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(2)));
    
    decodingAcc_standard_eyetracking = object_decodingAcc_standard_all;
    decodingAcc_bulls_eyetracking = object_decodingAcc_bulls_all;
    decodingAcc_diff_wave_eyetracking = object_difference_wave;
 %% 1-pearsson    
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_decodingAcc_standard_all_%s.mat',decoding,methods_flag(1)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_decodingAcc_bulls_all_%s.mat',decoding, methods_flag(1)));
    %load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_difference_wave_%s.mat',decoding,methods_flag(1)));
    
    decodingAcc_standard_eeg = object_rdm_standard_all;
    decodingAcc_bulls_eeg = object_rdm_bulls_all;
    %decodingAcc_diff_wave_eeg = object_pearsson_difference_wave;
    
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_decodingAcc_standard_all_%s.mat',decoding,methods_flag(2)));
    load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_decodingAcc_bulls_all_%s.mat',decoding, methods_flag(2)));
   % load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/%s_difference_wave_%s.mat',decoding,methods_flag(2)));
    
    decodingAcc_standard_eyetracking = object_rdm_standard_all;
    decodingAcc_bulls_eyetracking = object_rdm_bulls_all;
   % decodingAcc_diff_wave_eyetracking = object_pearsson_difference_wave;
    
    
    decodingAcc_standard_1 = decodingAcc_standard_eeg;
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking;
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg;
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking;
   % decodingAcc_diff_wave_1 = decodingAcc_diff_wave_eeg;
   % decodingAcc_diff_wave_2 = decodingAcc_diff_wave_eyetracking;
    
if split_half == 1 
    if eeg
    decodingAcc_standard_1 = decodingAcc_standard_eeg(1:15,:,:,:);
    decodingAcc_standard_2 = decodingAcc_standard_eeg(16:end,:,:,:);
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg(1:15,:,:,:);
    decodingAcc_bulls_2 = decodingAcc_bulls_eeg(16:end,:,:,:);
   % decodingAcc_diff_wave_1 = decodingAcc_diff_wave_eeg(1:15,:,:,:);
   % decodingAcc_diff_wave_2 = decodingAcc_diff_wave_eeg(16:end,:,:,:);
    
    elseif eyetracking 
    decodingAcc_standard_1 = decodingAcc_standard_eyetracking(1:15,:,:,:);
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking(16:end,:,:,:);
    decodingAcc_bulls_1 = decodingAcc_bulls_eyetracking(1:15,:,:,:);
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking(16:end,:,:,:);
   % decodingAcc_diff_wave_1 = decodingAcc_diff_wave_eyetracking(1:15,:,:,:);
   % decodingAcc_diff_wave_2 = decodingAcc_diff_wave_eyetracking(16:end,:,:,:);
    end
    
end 
n_perm=10;
q_value = 0.05;
[SignificantVariables_category_standard,~,adjusted_pvalues_standard, true_rsa_rdm_standard] = fdr_corrected_perm_test_rsa(decodingAcc_standard_1,decodingAcc_standard_2, n_perm,'right', q_value);
[SignificantVariables_category_bulls,~,adjusted_pvalues_bulls, true_rsa_rdm_bulls] = fdr_corrected_perm_test_rsa(decodingAcc_bulls_1,decodingAcc_bulls_2,n_perm,'right', q_value);
%[SignificantVariables_category_diff_wave,~,adjusted_pvalues_diff_wave, true_rsa_diff_wave] = fdr_corrected_perm_test_rsa(decodingAcc_diff_wave_1,decodingAcc_diff_wave_2, n_perm,'right', q_value);

significant_time_points_standard = find(SignificantVariables_category_standard>0);
y_significants_standard = repmat(70, size(significant_time_points_standard,2),1)';

significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
y_significants_bulls = repmat(72, size(significant_time_points_bulls,2),1)';

%significant_time_points_diff_wave = find(SignificantVariables_category_diff_wave>0);
%y_significants_diff_wave = repmat(70, size(significant_time_points_diff_wave,2),1)';
 
figure
    plot(true_rsa_rdm_standard, 'b')
    hold on 
    plot(significant_time_points_standard, y_significants_standard, 'b.')
    hold on
    plot(true_rsa_rdm_bulls, 'r')
    hold on 
    plot(significant_time_points_bulls, y_significants_bulls, 'r.')
    hold on  
    %plot(true_rsa_diff_wave, 'g')
    %hold on 
    %plot(significant_time_points_diff_wave, y_significants_diff_wave, 'g.')
    title(sprintf("%s EEG eyetracking RDM 1-pearsson averaged over subjects %s", decoding))
    xlabel('time')
    ylabel('correlation')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(0);
    xline(40);
    saveas(gca,sprintf( '%s_rdm_statistics_eeg_eyetracking_pearsson.png',out_path));
end


