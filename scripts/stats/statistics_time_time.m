
function [] = statistics_time_time(decoding,fixcross,method)
%{
   - calculates cluster-based permutation statistics for time-generalized MVPA
   - decoding: "1" or "2"
   - fixcross: "1" or "2"
   - method: "1" or "2"
%}

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


train = 'time_time';
load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding, train, decoding,fixcross,method));
data= eval(sprintf('decodingAcc_%s_all',fixcross));



n_perm = 10000;

if strcmp(decoding, 'object')==1
    data = squeeze(nanmean(data,2));
    data = squeeze(nanmean(data,2));
end

data = data-50;
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_%s/',BASE, decoding,train);

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
cluster_thr = 0.05;
significance_thr = 0.05;
[SignificantVariables,significantVarMax,pValWei,pValMax,clusters_standard] = permutation_cluster_1sample_weight_alld(data, n_perm, cluster_thr, significance_thr,'right');

save(sprintf('%ssignificant_variables_time_time_%s_%s.mat',out_path_results, fixcross, method),'SignificantVariables','significantVarMax','pValWei','pValMax','clusters_standard');

end


