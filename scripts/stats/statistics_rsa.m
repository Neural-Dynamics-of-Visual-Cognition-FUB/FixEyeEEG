function [] = statistics_rsa(split_half, distance_measure,random, stats)
% calculating statistics for RSA analysis
% split half = 0 or 1
%  if 1 then split hald analysis if performed
%
%
%
n_perm = 10000;
q_value = 0.05;
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
decoding = 'object';

methods_flag = ["eeg" "eyetracking"];


%% decoding accuracies
if  distance_measure == 1
    dist_measure = 'decoding';
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,methods_flag(1)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, methods_flag(1)));
    
    decodingAcc_standard_eeg = eval(sprintf('%s_decodingAcc_standard_all',decoding));
    decodingAcc_bulls_eeg = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,methods_flag(2)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, methods_flag(2)));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_decodingAcc_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
elseif distance_measure == 2
    dist_measure = 'pearsson';
    %% 1-pearsson
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_%s.mat',BASE,decoding,decoding,methods_flag(1)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_%s.mat',BASE,decoding, decoding,methods_flag(1)));
    
    decodingAcc_standard_eeg = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eeg = eval(sprintf('%s_rdm_bulls_all',decoding));
    tmp = squeeze(nanmean(decodingAcc_standard_eeg,2));
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_%s.mat',BASE,decoding,decoding,methods_flag(2)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_%s.mat',BASE,decoding, decoding,methods_flag(2)));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_rdm_bulls_all',decoding));
    tmp = squeeze(nanmean(decodingAcc_standard_eyetracking,2));
end
if split_half == 1
    decodingAcc_standard_1 = decodingAcc_standard_eeg;
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking;
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg;
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking;
    method = 'eeg_and_eyetracking';
    subj = 30;
elseif split_half == 2
    method = 'eeg';
    
    [decodingAcc_standard_1,idx] = datasample(decodingAcc_standard_eeg,15, 'Replace', false);
    decodingAcc_standard_2 = decodingAcc_standard_eeg;
    decodingAcc_standard_2(idx,:,:,:) = [];
    [decodingAcc_bulls_1,idx] = datasample(decodingAcc_bulls_eeg,15, 'Replace', false);
    decodingAcc_bulls_2 = decodingAcc_bulls_eeg;
    decodingAcc_bulls_2(idx,:,:,:) = [];
    subj = 15;
elseif split_half == 3
    method = 'eyetracking';
    
    [decodingAcc_standard_1,idx] = datasample(decodingAcc_standard_eyetracking,15, 'Replace', false);
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking;
    decodingAcc_standard_2(idx,:,:,:) = [];
    [decodingAcc_bulls_1,idx] = datasample(decodingAcc_bulls_eyetracking,15, 'Replace', false);
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking;
    decodingAcc_bulls_2(idx,:,:,:) = [];
    subj = 15;
end

if strcmp(stats, 'perm') == 1
    out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/rsa/',BASE);
if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
% averaged over subjects
if random == 1
    effect = 'fixed_effect';
    [SignificantVariables_category_standard,~,adjusted_pvalues_standard, true_rsa_rdm_standard] = fdr_corrected_perm_test_rsa_fixed_effects(decodingAcc_standard_1,decodingAcc_standard_2, n_perm,'right', q_value);
    [SignificantVariables_category_bulls,~,adjusted_pvalues_bulls, true_rsa_rdm_bulls] = fdr_corrected_perm_test_rsa_fixed_effects(decodingAcc_bulls_1,decodingAcc_bulls_2,n_perm,'right', q_value);
    save(sprintf('%ssignificant_variables_standard_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_standard');
    save(sprintf('%ssignificant_variables_bulls_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_bulls');
    save(sprintf('%strue_rsa_rdm_standard_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_standard');
    save(sprintf('%strue_rsa_rdm_bulls_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_bulls');
elseif random == 2
    effect = 'random_effects';
    [SignificantVariables_category_standard,~,adjusted_pvalues_standard, true_rsa_rdm_standard] = fdr_rsa_random_effects_stats(decodingAcc_standard_1,decodingAcc_standard_2, n_perm,'right', q_value,subj);
    [SignificantVariables_category_bulls,~,adjusted_pvalues_bulls, true_rsa_rdm_bulls] = fdr_rsa_random_effects_stats(decodingAcc_bulls_1,decodingAcc_bulls_2,n_perm,'right', q_value, subj);
    
    save(sprintf('%ssignificant_variables_standard_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_standard');
    save(sprintf('%ssignificant_variables_bulls_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_bulls');
    save(sprintf('%strue_rsa_rdm_standard_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_standard');
    save(sprintf('%strue_rsa_rdm_bulls_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_bulls');
   
end
elseif strcmp(stats,'cluster')
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);
if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
    true_rsa_rdm_standard = calculate_ground_truth_rsa(decodingAcc_standard_1,decodingAcc_standard_2, subj);
    true_rsa_rdm_bulls = calculate_ground_truth_rsa(decodingAcc_bulls_1,decodingAcc_bulls_2,subj);
    cluster_thr = 0.05;
    significance_thr = 0.05;
    [SignificantVariables_category_standard,significantVarMax_standard,pValWei_standard,pValMax_standard,clusters_standard] = permutation_cluster_1sample_weight_alld(true_rsa_rdm_standard, n_perm, cluster_thr, significance_thr,'right');
    [SignificantVariables_category_bulls,significantVarMax_bulls,pValWei_bulls,pValMax_bulls,clusters_bulls] = permutation_cluster_1sample_weight_alld(true_rsa_rdm_bulls, n_perm, cluster_thr, significance_thr,'right');
    save(sprintf('%ssignificant_variables_standard_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_standard','significantVarMax_standard','pValWei_standard','pValMax_standard','clusters_standard');
    save(sprintf('%ssignificant_variables_bulls_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_bulls','significantVarMax_bulls','pValWei_bulls','pValMax_bulls','clusters_bulls');
    save(sprintf('%strue_rsa_rdm_standard_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_standard');
    save(sprintf('%strue_rsa_rdm_bulls_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_bulls');
   

end
end

