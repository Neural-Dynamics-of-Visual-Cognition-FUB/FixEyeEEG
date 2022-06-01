function [] = plot_statistics_rsa(split_half, distance_measure,random)
% calculating statistics for RSA analysis
% split half = 0 or 1
%  if 1 then split hald analysis if performed
%
%
%
n_perm = 100000;
q_value = 0.05;
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
decoding = 'object';
out_path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/',BASE);
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/rsa/',BASE);
methods_flag = ["eeg" "eyetracking"];

if ~isfolder(out_path_plots)
    mkdir(out_path_plots);
end

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
%% decoding accuracies
if  distance_measure == 1
    dist_measure = 'decoding';
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,methods_flag(1)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, methods_flag(1)));
    
    decodingAcc_standard_eeg = eval(sprintf('%s_decodingAcc_standard_all',decoding));
    decodingAcc_bulls_eeg = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,methods_flag(2)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, methods_flag(2)));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_decodingAcc_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
elseif distance_measure == 2
    dist_measure = 'pearsson';
    %% 1-pearsson
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_%s.mat',BASE,decoding,decoding,methods_flag(1)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_%s.mat',BASE,decoding, decoding,methods_flag(1)));
    
    decodingAcc_standard_eeg = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eeg = eval(sprintf('%s_rdm_bulls_all',decoding));
    tmp = squeeze(nanmean(decodingAcc_standard_eeg,2));
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_%s.mat',BASE,decoding,decoding,methods_flag(2)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_%s.mat',BASE,decoding, decoding,methods_flag(2)));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_rdm_bulls_all',decoding));
    tmp = squeeze(nanmean(decodingAcc_standard_eyetracking,2));
end
if split_half == 1
    decodingAcc_standard_1 = decodingAcc_standard_eeg;
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking;
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg;
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking;
    method = 'eeg_and_eyetracking';
elseif split_half == 2
    method = 'eeg';
    decodingAcc_standard_1 = decodingAcc_standard_eeg(1:15,:,:,:);
    decodingAcc_standard_2 = decodingAcc_standard_eeg(16:end,:,:,:);
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg(1:15,:,:,:);
    decodingAcc_bulls_2 = decodingAcc_bulls_eeg(16:end,:,:,:);
elseif split_half == 3
    method = 'eyetracking';
    decodingAcc_standard_1 = decodingAcc_standard_eyetracking(1:15,:,:,:);
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking(16:end,:,:,:);
    decodingAcc_bulls_1 = decodingAcc_bulls_eyetracking(1:15,:,:,:);
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking(16:end,:,:,:);
end


% averaged over subjects
if random == 1
    effect = 'fixed_effect';
    [SignificantVariables_category_standard,~,adjusted_pvalues_standard, true_rsa_rdm_standard] = fdr_corrected_perm_test_rsa(decodingAcc_standard_1,decodingAcc_standard_2, n_perm,'right', q_value);
    [SignificantVariables_category_bulls,~,adjusted_pvalues_bulls, true_rsa_rdm_bulls] = fdr_corrected_perm_test_rsa(decodingAcc_bulls_1,decodingAcc_bulls_2,n_perm,'right', q_value);
    save(sprintf('%ssignificant_variables_standard_%s_%s.m',out_path_results, method, dist_measure),'SignificantVariables_category_standard');
    save(sprintf('%ssignificant_variables_bulls_%s_%s.m',out_path_results, method, dist_measure),'SignificantVariables_category_bulls');
    save(sprintf('%strue_rsa_rdm_standard_%s_%s.m',out_path_results, method, dist_measure),'true_rsa_rdm_standard');
    save(sprintf('%strue_rsa_rdm_bulls_%s_%s.m',out_path_results, method, dist_measure),'true_rsa_rdm_bulls');
elseif random == 2
    effect = 'random_effects';
    [SignificantVariables_category_standard,~,adjusted_pvalues_standard, true_rsa_rdm_standard] = fdr_rsa_random_effects_stats(decodingAcc_standard_1,decodingAcc_standard_2, n_perm,'right', q_value);
    [SignificantVariables_category_bulls,~,adjusted_pvalues_bulls, true_rsa_rdm_bulls] = fdr_rsa_random_effects_stats(decodingAcc_bulls_1,decodingAcc_bulls_2,n_perm,'right', q_value);
    
    save(sprintf('%ssignificant_variables_standard_random_effects_%s_%s.m',out_path_results, method, dist_measure),'SignificantVariables_category_standard');
    save(sprintf('%ssignificant_variables_bulls_random_effects_%s_%s.m',out_path_results, method, dist_measure),'SignificantVariables_category_bulls');
    save(sprintf('%strue_rsa_rdm_standard_random_effects_%s_%s.m',out_path_results, method, dist_measure),'true_rsa_rdm_standard');
    save(sprintf('%strue_rsa_rdm_bulls_random_effects_%s_%s.m',out_path_results, method, dist_measure),'true_rsa_rdm_bulls');
    
end

significant_time_points_standard = find(SignificantVariables_category_standard>0);
y_significants_standard = repmat(-0.4, size(significant_time_points_standard,2),1)';

significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
y_significants_bulls = repmat(-0.5, size(significant_time_points_bulls,2),1)';

%significant_time_points_diff_wave = find(SignificantVariables_category_diff_wave>0);
%y_significants_diff_wave = repmat(70, size(significant_time_points_diff_wave,2),1)';
if random == 2
     x = 1:numel(mean(true_rsa_rdm_standard));
     true_rsa_rdm_standard_plot = mean(true_rsa_rdm_standard);
     true_rsa_rdm_bulls_plot = mean(true_rsa_rdm_bulls);
     
elseif random == 1
x = 1:numel(true_rsa_rdm_standard);
     true_rsa_rdm_standard_plot = true_rsa_rdm_standard;
     true_rsa_rdm_bulls_plot = true_rsa_rdm_bulls;
end
x2 = [x, fliplr(x)];
c2 = [146/255 0/255 0/255];
c1 = [0/255 146/255 146/255];

SEM_standard = std(true_rsa_rdm_standard)/sqrt(size(true_rsa_rdm_standard,1));
SEM_bulls = std(true_rsa_rdm_bulls)/sqrt(size(true_rsa_rdm_bulls,1));

figure
upper = true_rsa_rdm_standard_plot + SEM_standard;
lower = true_rsa_rdm_standard_plot - SEM_standard;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c1, 'FaceAlpha', 0.2);
hold on;
upper = true_rsa_rdm_bulls_plot + SEM_bulls;
lower = true_rsa_rdm_bulls_plot - SEM_bulls;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c2, 'FaceAlpha', 0.2);
hold on;
plot(true_rsa_rdm_standard_plot,'Color',c1)
hold on
plot(significant_time_points_standard, y_significants_standard,'*','Color',c1)
hold on
plot(true_rsa_rdm_bulls_plot,'Color',c2)
hold on
plot(significant_time_points_bulls, y_significants_bulls,'*', 'Color',c2)
title(sprintf("RSA %s %s %s", dist_measure,decoding, method))
xlabel('time')
ylabel('correlation')
xticks([0 40 80 120 160 200 240])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yline(0);
xline(40);
saveas(gca,sprintf( '%sRSA_%s_%s_%s_%s_statistics.png',out_path_plots, dist_measure,decoding, method, effect));
end


