 function [] = statistics_time_time(decoding,fixcross,method)
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
    decoding = 'objects';
end

if fixcross == 1 
    fixcross = 'standard';
elseif fixcross == 2
    fixcross = 'bulls';
end

if method == 1
    method = 'eeg';
elseif method == 2
    method = 'eyetracking';
end

n_perm = 10000;
q_value = 0.05;
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_time_time/',BASE, decoding);
load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_%s_%s.mat', BASE,decoding,decoding,fixcross,method));
data= eval(sprintf('decodingAcc_%s_all',fixcross));

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end

if strcmp(decoding, 'objects')==1
     data = squeeze(mean(data,2));
     data = squeeze(mean(data,2));
end

[SignificantVariables, pvalues, crit_p, adjusted_pvalues] = fdr_permutation_cluster_1sample_alld(data,n_perm,'right', q_value);
save(sprintf('%ssignificant_variables_time_time_%s_%s.m',out_path_results, fixcross, method),'SignificantVariables');
save(sprintf('%sadjusted_pvalues_time_time_%s_%s.m',out_path_results, fixcross, method),'adjusted_pvalues');
end

