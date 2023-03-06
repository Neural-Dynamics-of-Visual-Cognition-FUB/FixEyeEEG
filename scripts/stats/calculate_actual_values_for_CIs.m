function [outputArg1,outputArg2] = calculate_actual_values_for_CIs(decoding,method)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

    path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_decoding/',BASE,decoding);
    path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/%s_decoding/',BASE,decoding);


fixcross = {'standard'; 'bulls'; 'diff_wave'};
for idx=1:3
    load(sprintf('%ssignificant_variables_%s_%s_%s.mat',path_results, fixcross{idx}, method,decoding));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_%s_all_%s.mat', BASE,decoding,decoding,fixcross{idx},method));
    load(sprintf('%speak_latency_%s_%s_%s.mat',path_results, method, decoding, fixcross{idx}));
    if idx == 1
        peak_latency_standard = peak_latency;
        CI_95_standard = CI_95;
    elseif idx == 2
        peak_latency_bulls = peak_latency;
        CI_95_bulls = CI_95;
    else 
        peak_latency_diff_wave = peak_latency;
        CI_95_diff_wave = CI_95;
    end
end



decodingAcc_standard = eval(sprintf('%s_decodingAcc_standard_all',decoding));
decodingAcc_bulls = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
decodingAcc_diff_wave = eval(sprintf('%s_decodingAcc_diff_wave_all',decoding));

if strcmp(decoding, 'object') == 1
    decodingAcc_standard = squeeze(nanmean(squeeze(nanmean(decodingAcc_standard,2)),2));
    decodingAcc_bulls = squeeze(nanmean(squeeze(nanmean(decodingAcc_bulls,2)),2));
    decodingAcc_diff_wave = squeeze(nanmean(squeeze(nanmean(decodingAcc_diff_wave,2)),2));
    decodingAcc_standard = decodingAcc_standard-50;
    decodingAcc_bulls = decodingAcc_bulls -50;
    decodingAcc_diff_wave = decodingAcc_diff_wave-50;
elseif strcmp(decoding, 'category') == 1  
    decodingAcc_standard = decodingAcc_standard-50;
    decodingAcc_bulls = decodingAcc_bulls -50;
    decodingAcc_diff_wave = decodingAcc_diff_wave-50;
end

significant_time_points_standard = find(SignificantVariables_standard>0);

significant_time_points_bulls = find(SignificantVariables_bulls>0);

significant_time_points_diff_wave = find(SignificantVariables_diff_wave>0);

SEM_standard = std(decodingAcc_standard)/sqrt(size(decodingAcc_standard,1));
SEM_bulls = std(decodingAcc_bulls)/sqrt(size(decodingAcc_bulls,1));
SEM_diff = std(decodingAcc_diff_wave)/sqrt(size(decodingAcc_diff_wave,1));

actual_peak_standard = find(mean(decodingAcc_standard)==max(mean(decodingAcc_standard)));
actual_peak_bulls = find(mean(decodingAcc_bulls)==max(mean(decodingAcc_bulls)));
actual_peak_difference = find(mean(decodingAcc_diff_wave)==max(mean(decodingAcc_diff_wave)));

disp(sprintf('decoding: %s, method: %s', decoding,method))

disp('%%%%%%%%%standard%%%%%%%%%%%%')
disp(sprintf('start cluster standard: %d',min(significant_time_points_standard)*5-200))
disp(sprintf('end cluster standard: %d',max(significant_time_points_standard)*5-200))
disp(sprintf('pvalue cluster standard: %d', pValMax_standard))
disp(sprintf('actual value standard peak: %d' ,actual_peak_standard*5-200))
disp(sprintf('lower CI value standard peak: %d' ,CI_95_standard(1)*5-200))
disp(sprintf('upper CI value standard peak: %d' ,CI_95_standard(2)*5-200))

disp('%%%%%%%%%bulls%%%%%%%%%%%%')
disp(sprintf('start cluster bulls: %d',min(significant_time_points_bulls*5-200)))
disp(sprintf('end cluster bulls: %d',max(significant_time_points_bulls*5-200)))
disp(sprintf('pvalue cluster bulls: %d', pValMax_bulls))

disp(sprintf('actual value bulls peak: %d' ,actual_peak_bulls*5-200))
disp(sprintf('lower CI value bulls peak: %d' ,CI_95_bulls(1)*5-200))
disp(sprintf('upper CI value bullspeak: %d' ,CI_95_bulls(2)*5-200))

disp('%%%%%%%%%difference%%%%%%%%%%%%')

disp(sprintf('start cluster difference: %d',min(significant_time_points_diff_wave*5-200)))
disp(sprintf('end cluster difference: %d',max(significant_time_points_diff_wave*5-200)))
disp(sprintf('pvalue cluster difference: %d', pValMax_diff_wave))
disp(sprintf('actual value difference peak: %d' ,actual_peak_difference*5-200))
%disp(sprintf('lower CI value difference peak: %d' ,CI_95_diff_wave(1,2)*5-200))
%disp(sprintf('upper CI value difference peak: %d' ,CI_95_diff_wave(2,2)*5-200))

mean_standard = max(mean(decodingAcc_standard));
disp('%%%%%%%%%actual peak values%%%%%%%%%%%%')
disp(sprintf('actual peak value standard : %d', max(mean(decodingAcc_standard))))
disp(sprintf('actual peak value bulls : %d', max(mean(decodingAcc_bulls))))
disp(sprintf('actual peak value diff_wave:  %d', max(mean(decodingAcc_diff_wave))))


end