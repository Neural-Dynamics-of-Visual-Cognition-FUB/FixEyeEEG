function [] = statistics_difference_train_test_decoding(decoding, method)

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
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_difference_train_test_decoding/',BASE, decoding);

if ~isfolder(path_results)
    mkdir(path_results);
end


load(sprintf('%sdifference_train_test_standard_%s.mat',path_results,method));
load(sprintf('%sdifference_train_test_bulls_%s.mat',path_results,method));


    if strcmp(decoding, 'object') == 1
        difference_standard = squeeze(nanmean(squeeze(nanmean(difference_standard,2)),2));
        difference_bulls = squeeze(nanmean(squeeze(nanmean(difference_bulls,2)),2));
    end
    
difference_bulls = difference_bulls +50;
difference_standard = difference_standard +50;
[SignificantVariables_standard,~,adjusted_pvalues_standard] = fdr_corrected_perm_test(difference_standard, n_perm, q_value);
[SignificantVariables_bulls,~,adjusted_pvalues_bulls] = fdr_corrected_perm_test(difference_bulls, n_perm, q_value);

save(sprintf('%ssignificant_variables_standard_%s_%s.mat',path_results, method, decoding),'SignificantVariables_standard');
save(sprintf('%ssignificant_variables_bulls_%s_%s.mat',path_results, method, decoding),'SignificantVariables_bulls');

save(sprintf('%sadjusted_pvalues_standard%s_%s.mat',path_results, method, decoding),'adjusted_pvalues_standard');
save(sprintf('%sadjusted_pvalues_bulls%s_%s.mat',path_results, method, decoding),'adjusted_pvalues_bulls');

end

