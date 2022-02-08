function [outputArg1,outputArg2] = plot_statistics(decoding)

out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/plots/';
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats/');
methods_flag = ["eeg" "eyetracking"];
for idx = 1:2

if strcmp(decoding, 'category')
load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(idx)));
load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(idx)));
load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(idx)));
decodingAcc_standard = category_decodingAcc_standard_all;
decodingAcc_bulls = category_decodingAcc_bulls_all;
decodingAcc_diff_wave = category_difference_wave;
elseif strcmp(decoding, 'object')
load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(idx)));
load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(idx)));
load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_decoding/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(idx)));

decodingAcc_standard = squeeze(nanmean(nanmean(object_decodingAcc_standard_all,2),3));
decodingAcc_bulls = squeeze(nanmean(nanmean(object_decodingAcc_bulls_all,2),3));
decodingAcc_diff_wave = squeeze(nanmean(nanmean(object_difference_wave,2),3));
end
n_perm=1000;
q_value = 0.01;
[SignificantVariables_category_standard,~,adjusted_pvalues_standard] = fdr_corrected_perm_test(decodingAcc_standard, n_perm, q_value);
[SignificantVariables_category_bulls,~,adjusted_pvalues_bulls] = fdr_corrected_perm_test(decodingAcc_bulls, n_perm, q_value);
[SignificantVariables_category_diff_wave,~,adjusted_pvalues_diff_wave] = fdr_corrected_perm_test(decodingAcc_diff_wave, n_perm, q_value);

significant_time_points_standard = find(SignificantVariables_category_standard>0);
y_significants_standard = repmat(70, size(significant_time_points_standard,2),1)';

significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
y_significants_bulls = repmat(72, size(significant_time_points_bulls,2),1)';

significant_time_points_diff_wave = find(SignificantVariables_category_diff_wave>0);
y_significants_diff_wave = repmat(70, size(significant_time_points_diff_wave,2),1)';
 
figure
    stdshade(decodingAcc_standard,0.2, 'blue')
    hold on 
    plot(significant_time_points_standard, y_significants_standard, 'b.')
    hold on 
    stdshade(decodingAcc_bulls, 0.2)
    hold on 
    plot(significant_time_points_bulls, y_significants_bulls, 'r.')
    hold on  
    stdshade(decodingAcc_diff_wave, 0.2, 'green')
    hold on 
    plot(significant_time_points_diff_wave, y_significants_diff_wave, 'g.')
    title(sprintf("%s decoding accuracy %s", decoding, methods_flag(idx)))
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
    saveas(gca,sprintf( '%s%s_decoding_%s_statistics.png',out_path, decoding, methods_flag(idx)));
end
end

