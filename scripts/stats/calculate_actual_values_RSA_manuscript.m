function [outputArg1,outputArg2] = calculate_actual_values_RSA_manuscript(eyetracking, noise_ceiling_method, noise_ceiling_fixcross)
   
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
if eyetracking == 1
    path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);

    load(sprintf('%ssignificant_variables_compare_eyetracking_random_effects_eyetracking_pearsson.mat',path_results));
    load(sprintf('%strue_rsa_rdm_compare_eyetracking_random_effects_eyetracking_pearsson.mat',path_results));
    load(sprintf('%snoise_ceiling_%s_%s.mat',path_results, noise_ceiling_method, noise_ceiling_fixcross));
    
    significant_time_points_standard = find(SignificantVariables_category_standard>0);   
    true_rsa_rdm_standard_plot = nanmean(true_rsa_rdm_standard);
    actual_peak = find(true_rsa_rdm_standard_plot==max(true_rsa_rdm_standard_plot));

    disp('%%%%%%%%% RSA %%%%%%%%%%%%')

disp(sprintf('start cluster difference: %d',min(significant_time_points_standard*5-200)))
disp(sprintf('end cluster difference: %d',max(significant_time_points_standard*5-200)))
disp(sprintf('pvalue cluster difference: %d', pValMax_diff_wave))
disp(sprintf('actual value difference peak: %d' ,actual_peak*5-200))
disp(sprintf('lower CI value difference peak: %d' ,CI_95_diff_wave(1,2)*5-200))
disp(sprintf('upper CI value difference peak: %d' ,CI_95_diff_wave(2,2)*5-200))
else
        path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);

    load(sprintf('%ssignificant_variables_standard_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%ssignificant_variables_bulls_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%ssignificant_variables_diff_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    
    load(sprintf('%strue_rsa_rdm_standard_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%strue_rsa_rdm_bulls_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%sdiff_true_rsa_rdm_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    
    load(sprintf('%snoise_ceiling_%s_%s.mat',path_results, noise_ceiling_method, noise_ceiling_fixcross));
    
    
    load(sprintf('%speak_latency_object_eeg_and_eyetracking_standard.mat',path_results));
    peak_latency_standard = peak_latency;
    CI_95_standard = CI_95;
    load(sprintf('%speak_latency_object_eeg_and_eyetracking_bulls.mat',path_results));
    peak_latency_bulls = peak_latency;
    CI_95_bulls = CI_95;
    
    significant_time_points_standard = find(SignificantVariables_category_standard>0);
    
    significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
    
    significant_time_points_diff_wave = find(SignificantVariables_category_diff>0);
        
    true_rsa_rdm_standard_plot = nanmean(true_rsa_rdm_standard);
    true_rsa_rdm_bulls_plot = nanmean(true_rsa_rdm_bulls);
    true_rsa_rdm_diff_plot = nanmean(diff_rsa);
    
    actual_peak_standard = find(true_rsa_rdm_standard_plot==max(true_rsa_rdm_standard_plot));
    actual_peak_bulls = find(true_rsa_rdm_bulls_plot==max(mean(true_rsa_rdm_bulls_plot)));
    actual_peak_difference = find(true_rsa_rdm_diff_plot==max(true_rsa_rdm_diff_plot));
    
disp('%%%%%%%%%standard%%%%%%%%%%%%')
disp(sprintf('start cluster standard: %d',min(significant_time_points_standard)*5-200))
disp(sprintf('end cluster standard: %d',max(significant_time_points_standard)*5-200))
disp(sprintf('pvalue cluster standard: %d', pValMax_standard))
disp(sprintf('actual value standard peak: %d' ,actual_peak_standard*5-200))
disp(sprintf('lower CI value standard peak: %d' ,CI_95_standard(1,2)*5-200))
disp(sprintf('upper CI value standard peak: %d' ,CI_95_standard(2,2)*5-200))

disp('%%%%%%%%%bulls%%%%%%%%%%%%')
disp(sprintf('start cluster bulls: %d',min(significant_time_points_bulls*5-200)))
disp(sprintf('end cluster bulls: %d',max(significant_time_points_bulls*5-200)))
disp(sprintf('pvalue cluster bulls: %d', pValMax_bulls))

disp(sprintf('actual value bulls peak: %d' ,actual_peak_bulls*5-200))
disp(sprintf('lower CI value bulls peak: %d' ,CI_95_bulls(1,2)*5-200))
disp(sprintf('upper CI value bullspeak: %d' ,CI_95_bulls(2,2)*5-200))

disp('%%%%%%%%%difference%%%%%%%%%%%%')

disp(sprintf('start cluster difference: %d',min(significant_time_points_diff_wave*5-200)))
disp(sprintf('end cluster difference: %d',max(significant_time_points_diff_wave*5-200)))
disp(sprintf('pvalue cluster difference: %d', pValMax_diff))
disp(sprintf('actual value difference peak: %d' ,actual_peak_difference*5-200))
%disp(sprintf('lower CI value difference peak: %d' ,CI_95_diff(1,2)*5-200))
%disp(sprintf('upper CI value difference peak: %d' ,CI_95_diff(2,2)*5-200))
    
end 
    

end