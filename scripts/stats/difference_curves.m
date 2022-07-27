function [outputArg1,outputArg2] = difference_curves(decoding, method, stats)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';

end

n_perm = 10000;
q_value = 0.05;
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_time_time/',BASE, decoding);

load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_standard_%s.mat', BASE,decoding, decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_bulls_%s.mat', BASE,decoding, decoding,method));



if strcmp(decoding, 'objects')==1
     decodingAcc_standard_all = squeeze(mean(decodingAcc_standard_all,2));
     decodingAcc_standard_all = squeeze(mean(decodingAcc_standard_all,2));
     
     decodingAcc_bulls_all = squeeze(mean(decodingAcc_bulls_all,2));
     decodingAcc_bulls_all = squeeze(mean(decodingAcc_bulls_all,2));
end

if strcmp(stats,'perm')
    
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_time_time/',BASE, decoding);

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end

diff_curve = decodingAcc_standard_all - decodingAcc_bulls_all +50;
[SignificantVariables, pvalues, crit_p, adjusted_pvalues] = fdr_permutation_cluster_1sample_alld(diff_curve,n_perm,'right', q_value);
save(sprintf('%ssignificant_variables_time_time_diff_curve_%s.mat',out_path_results, method),'SignificantVariables');
save(sprintf('%sadjusted_pvalues_time_time_diff_curve_%s.mat',out_path_results, method),'adjusted_pvalues');
save(sprintf('%stime_time_diff_curve_%s.mat',out_path_results, method),'diff_curve');

elseif strcmp(stats,'cluster')
diff_curve = decodingAcc_standard_all - decodingAcc_bulls_all;
  out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_time_time/',BASE, decoding);



if ~isfolder(out_path_results)
    mkdir(out_path_results);
end

    cluster_thr = 0.05;
    significance_thr = 0.05;
    [SignificantVariables_standard,significantVarMax_standard,pValWei_standard,pValMax_standard,clusters_standard] = permutation_cluster_1sample_weight_alld(diff_curve, n_perm, cluster_thr, significance_thr,'right');
    
    save(sprintf('%ssignificant_variables_time_time_diff_curve_%s_%s.mat',out_path_results, method),'SignificantVariables_standard','significantVarMax_standard','pValWei_standard','pValMax_standard','clusters_standard');
   
end

end

