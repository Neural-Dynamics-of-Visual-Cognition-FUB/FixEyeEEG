function [] = statistics_decoding(decoding, method)
%{
   - calculates statistics for time-resolved MVPA
   - decoding: "1" or "2"
   - method: "1" or "2"
%}
n_perm = 10000;

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


decodingAcc_standard = decodingAcc_standard -50;
decodingAcc_bulls = decodingAcc_bulls - 50;
decodingAcc_diff_wave = decodingAcc_diff_wave -50;
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/two_tailed/%s_decoding/',BASE, decoding);


if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
cluster_thr = 0.05;
significance_thr = 0.05;
[SignificantVariables_standard,significantVarMax_standard,pValWei_standard,pValMax_standard,clusters_standard] = permutation_cluster_1sample_weight_alld(decodingAcc_standard, n_perm, cluster_thr, significance_thr,'right');
[SignificantVariables_bulls,significantVarMax_bulls,pValWei_bulls,pValMax_bulls,clusters_bulls] = permutation_cluster_1sample_weight_alld(decodingAcc_bulls, n_perm, cluster_thr, significance_thr,'right');
[SignificantVariables_diff_wave,significantVarMax_diff_wave,pValWei_diff_wave,pValMax_diff_wave,clusters_diff_wave] = permutation_cluster_1sample_weight_alld(decodingAcc_diff_wave, n_perm, cluster_thr, significance_thr,'both');

save(sprintf('%ssignificant_variables_standard_%s_%s.mat',out_path_results, method, decoding),'SignificantVariables_standard','significantVarMax_standard','pValWei_standard','pValMax_standard','clusters_standard');
save(sprintf('%ssignificant_variables_bulls_%s_%s.mat',out_path_results, method, decoding),'SignificantVariables_bulls','significantVarMax_bulls','pValWei_bulls','pValMax_bulls','clusters_bulls');
save(sprintf('%ssignificant_variables_diff_wave_%s_%s.mat',out_path_results, method, decoding),'SignificantVariables_diff_wave','significantVarMax_diff_wave','pValWei_diff_wave','pValMax_diff_wave','clusters_diff_wave');


end

