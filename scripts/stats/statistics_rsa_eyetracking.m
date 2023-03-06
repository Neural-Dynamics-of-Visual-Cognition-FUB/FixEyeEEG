function [] = statistics_rsa_eyetracking()
% calculating statistics for RSA analysis
% split half = 0 or 1
%  if 1 then split hald analysis if performed
%
%
%
n_perm = 10000;

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
decoding = 'object';



dist_measure = 'pearsson';

    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_eyetracking.mat',BASE,decoding,decoding));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_eyetracking.mat',BASE,decoding, decoding));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_rdm_bulls_all',decoding));


    method = 'eyetracking_bulls_standard';
    decodingAcc_standard = decodingAcc_standard_eyetracking;
    decodingAcc_bulls = decodingAcc_bulls_eyetracking;
    subj = 30;


out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);
if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
    true_rsa_rdm_standard = calculate_ground_truth_rsa(decodingAcc_standard,decodingAcc_bulls, subj);
    cluster_thr = 0.05;
    significance_thr = 0.05;
    [SignificantVariables_category_standard,significantVarMax_standard,pValWei_standard,pValMax_standard,clusters_standard] = permutation_cluster_1sample_weight_alld(true_rsa_rdm_standard, n_perm, cluster_thr, significance_thr,'right');
    
    save(sprintf('%ssignificant_variables_compare_eyetracking_random_effects_%s_pearsson.mat',out_path_results, method),'SignificantVariables_category_standard','significantVarMax_standard','pValWei_standard','pValMax_standard','clusters_standard');
    save(sprintf('%strue_rsa_rdm_compare_eyetracking_random_effects_%s_pearsson.mat',out_path_results, method),'true_rsa_rdm_standard');

end

