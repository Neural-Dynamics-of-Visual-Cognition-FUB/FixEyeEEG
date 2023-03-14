function [] = statistics_time_time_difference_curves(decoding, method)
%{
   - calculates cluster-based permutation statistics for differences
   between time-generalized MVPA conditions
   - decoding: "1" or "2"
   - method: "1" or "2"
%}
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

n_perm = 10000;

load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_standard_%s.mat', BASE,decoding, decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_bulls_%s.mat', BASE,decoding, decoding,method));

if strcmp(decoding, 'object')==1
    decodingAcc_standard_all = squeeze(nanmean(decodingAcc_standard_all,2));
    decodingAcc_standard_all = squeeze(nanmean(decodingAcc_standard_all,2));
    
    decodingAcc_bulls_all = squeeze(nanmean(decodingAcc_bulls_all,2));
    decodingAcc_bulls_all = squeeze(nanmean(decodingAcc_bulls_all,2));
end


diff_curve = decodingAcc_standard_all - decodingAcc_bulls_all;
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/two_tailed/%s_time_time/',BASE, decoding);

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end

cluster_thr = 0.05;
significance_thr = 0.05;
[SignificantVariables,significantVarMax,pValWei_standard,pValMax_standard,clusters_standard] = permutation_cluster_1sample_weight_alld(diff_curve, n_perm, cluster_thr, significance_thr,'both');

save(sprintf('%ssignificant_variables_time_time_diff_curve_%s.mat',out_path_results, method),'SignificantVariables','significantVarMax','pValWei_standard','pValMax_standard','clusters_standard');
save(sprintf('%stime_time_diff_curve_%s.mat',out_path_results, method),'diff_curve');



end

