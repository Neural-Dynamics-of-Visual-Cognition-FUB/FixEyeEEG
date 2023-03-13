function [] = statistics_rsa()
%{
   - calculates cluster-based permutation statistics for RSA
%}

n_perm = 10000;
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
decoding = 'object';

methods_flag = ["eeg" "eyetracking"];
dist_measure = 'pearson';
%% 1-pearson
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


decodingAcc_standard_1 = decodingAcc_standard_eeg;
decodingAcc_standard_2 = decodingAcc_standard_eyetracking;
decodingAcc_bulls_1 = decodingAcc_bulls_eeg;
decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking;
method = 'eeg_and_eyetracking';
subj = 30;

out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);
if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
true_rsa_rdm_standard = calculate_ground_truth_rsa(decodingAcc_standard_1,decodingAcc_standard_2, subj);
true_rsa_rdm_bulls = calculate_ground_truth_rsa(decodingAcc_bulls_1,decodingAcc_bulls_2,subj);
diff_rsa = true_rsa_rdm_standard-true_rsa_rdm_bulls;
cluster_thr = 0.05;
significance_thr = 0.05;
[SignificantVariables_category_standard,significantVarMax_standard,pValWei_standard,pValMax_standard,clusters_standard] = permutation_cluster_1sample_weight_alld(true_rsa_rdm_standard, n_perm, cluster_thr, significance_thr,'right');
[SignificantVariables_category_bulls,significantVarMax_bulls,pValWei_bulls,pValMax_bulls,clusters_bulls] = permutation_cluster_1sample_weight_alld(true_rsa_rdm_bulls, n_perm, cluster_thr, significance_thr,'right');
[SignificantVariables_category_diff,significantVarMax_diff,pValWei_diff,pValMax_diff,clusters_diff] = permutation_cluster_1sample_weight_alld(diff_rsa, n_perm, cluster_thr, significance_thr,'right');

save(sprintf('%ssignificant_variables_standard_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_standard','significantVarMax_standard','pValWei_standard','pValMax_standard','clusters_standard');
save(sprintf('%ssignificant_variables_bulls_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_bulls','significantVarMax_bulls','pValWei_bulls','pValMax_bulls','clusters_bulls');
save(sprintf('%strue_rsa_rdm_standard_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_standard');
save(sprintf('%strue_rsa_rdm_bulls_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'true_rsa_rdm_bulls');
save(sprintf('%ssignificant_variables_diff_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'SignificantVariables_category_diff','significantVarMax_diff','pValWei_diff','pValMax_diff','clusters_diff');
save(sprintf('%sdiff_true_rsa_rdm_random_effects_%s_%s.mat',out_path_results, method, dist_measure),'diff_rsa');


end


