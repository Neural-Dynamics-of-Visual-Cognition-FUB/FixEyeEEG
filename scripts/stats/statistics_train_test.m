function [] = statistics_train_test(decoding,method)
n_perm = 100000;
q_value = 0.05;
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
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

out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_train_test_decoding/',BASE, decoding);


if ~isfolder(out_path_results)
    mkdir(out_path_results);
end


load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_standard_all_%s.mat',BASE, decoding,decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_bulls_all_%s.mat',BASE, decoding,decoding, method));

decodingAcc_bulls_standard = eval(sprintf('%s_decodingAcc_bulls_standard',decoding));
decodingAcc_standard_bulls = eval(sprintf('%s_decodingAcc_standard_bulls',decoding));

[SignificantVariables_bulls_standard,~,adjusted_pvalues_bulls_standard] = fdr_corrected_perm_test(decodingAcc_bulls_standard, n_perm, q_value);
[SignificantVariables_standard_bulls,~,adjusted_pvalues_standard_bulls] = fdr_corrected_perm_test(decodingAcc_standard_bulls, n_perm, q_value);

save(sprintf('%ssignificantVariables_bulls_standard_%s_%s.m',out_path_results, method, decoding),'SignificantVariables_bulls_standard');
save(sprintf('%ssignificantVariables_standard_bulls_%s_%s.m',out_path_results, method, decoding),'SignificantVariables_standard_bulls');

save(sprintf('%sadjusted_pvalues_bulls_standard%s_%s.m',out_path_results, method, decoding),'adjusted_pvalues_bulls_standard');
save(sprintf('%sadjusted_pvalues_standard_bulls%s_%s.m',out_path_results, method, decoding),'adjusted_pvalues_standard_bulls');


end

