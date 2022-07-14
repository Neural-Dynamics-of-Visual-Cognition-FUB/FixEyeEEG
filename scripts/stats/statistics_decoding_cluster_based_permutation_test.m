function [] = statistics_decoding_cluster_based_permutation_test(decoding, method)

%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
n_perm = 10000;
q_value = 0.05;
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
     addpath('/home/haebeg19/FixEyeEEG/scripts/stats/fdr_bh');
   
    BASE = '/scratch/haebeg19/';
end

if decoding == 1 
    decoding = 'category';
elseif decoding == 2
    decoding = 'object';
end

if method == 1 
    method = 'eeg';
elseif method == 2
    method = 'eyetracking';
end
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_decoding/',BASE, decoding);


if ~isfolder(out_path_results)
    mkdir(out_path_results);
end


load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_diff_wave_all_%s.mat',BASE, decoding,decoding,method));

decodingAcc_standard = eval(sprintf('%s_decodingAcc_standard_all',decoding));
decodingAcc_bulls = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
decodingAcc_diff_wave = eval(sprintf('%s_decodingAcc_diff_wave_all',decoding));

    if strcmp(decoding, 'object') == 1
        decodingAcc_standard = squeeze(nanmean(squeeze(nanmean(decodingAcc_standard,2)),2));
        decodingAcc_bulls = squeeze(nanmean(squeeze(nanmean(decodingAcc_bulls,2)),2));
        decodingAcc_diff_wave = squeeze(nanmean(squeeze(nanmean(decodingAcc_diff_wave,2)),2));
    end

[SignificantVariables_standard,~,adjusted_pvalues_standard] = find_clusters_alld(decodingAcc_standard, n_perm, q_value);
[SignificantVariables_bulls,~,adjusted_pvalues_bulls] = find_clusters_alld(decodingAcc_bulls, n_perm, q_value);
[SignificantVariables_diff_wave,~,adjusted_pvalues_diff_wave] = find_clusters_alld(decodingAcc_diff_wave, n_perm, q_value);

%[SignificantVariables_bulls,~,adjusted_pvalues_bulls] = fdr_permutation_cluster_1sample_alld(decodingAcc_bulls, n_perm, 'right',q_value);

%[SignificantVariables_diff_wave,~,adjusted_pvalues_diff_wave] = fdr_permutation_cluster_1sample_alld(decodingAcc_diff_wave, n_perm,'right', q_value);

save(sprintf('%ssignificant_variables_standard_%s_%s.mat',out_path_results, method, decoding),'SignificantVariables_standard');
save(sprintf('%ssignificant_variables_bulls_%s_%s.mat',out_path_results, method, decoding),'SignificantVariables_bulls');
save(sprintf('%ssignificant_variables_diff_wave_%s_%s.mat',out_path_results, method, decoding),'SignificantVariables_diff_wave');

save(sprintf('%sadjusted_pvalues_standard%s_%s.mat',out_path_results, method, decoding),'adjusted_pvalues_standard');
save(sprintf('%sadjusted_pvalues_bulls%s_%s.mat',out_path_results, method, decoding),'adjusted_pvalues_bulls');
save(sprintf('%sadjusted_pvalues_diff_wave%s_%s.mat',out_path_results, method, decoding),'adjusted_pvalues_diff_wave');

end