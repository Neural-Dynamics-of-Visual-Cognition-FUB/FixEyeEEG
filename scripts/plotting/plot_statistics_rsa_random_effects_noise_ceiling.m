function [] = plot_statistics_rsa_random_effects_noise_ceiling(eyetracking, stats)
%%
% dist_meausre = decoding or pearsson
% effect = fixed or random
% method = eeg, eyetracking or eeg_and_eyetracking
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

if strcmp(stats,'perm')
    out_path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/rsa/',BASE);
    path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/rsa/',BASE);
    
    if ~isfolder(out_path_plots)
        mkdir(out_path_plots);
    end
elseif strcmp(stats,'cluster')
    out_path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/final/rsa/',BASE);
    path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);
    
    if ~isfolder(out_path_plots)
        mkdir(out_path_plots);
    end
end

if eyetracking == 1
    load(sprintf('%ssignificant_variables_compare_eyetracking_random_effects_eyetracking_pearsson.mat',path_results));
    load(sprintf('%strue_rsa_rdm_compare_eyetracking_random_effects_eyetracking_pearsson.mat',path_results));
    load(sprintf('%snoise_ceiling_eyetracking_standard.mat',path_results));
    
    significant_time_points_standard = find(SignificantVariables_category_standard>0);
    y_significants_standard = repmat(-0.04, size(significant_time_points_standard,1),1)';
    
    x = 1:numel(mean(true_rsa_rdm_standard));
    
    true_rsa_rdm_standard_plot = nanmean(true_rsa_rdm_standard);
    x2 = [x, fliplr(x)];
    c1 = [0/255 146/255 146/255];
    c3 = [128/255 128/255 128/255];
    
    SEM_standard = std(true_rsa_rdm_standard)/sqrt(size(true_rsa_rdm_standard,1));
    
    figure
    plot(true_rsa_rdm_standard_plot,'Color',c1, 'LineWidth', 1.6)
    hold on
    plot(significant_time_points_standard, y_significants_standard,'.','Color',c1)
    hold on
    upper = true_rsa_rdm_standard_plot + SEM_standard;
    lower = true_rsa_rdm_standard_plot - SEM_standard;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c1, 'FaceAlpha', 0.16, 'LineStyle', 'none');
    hold on;
    % add noise ceiling
    inBetween = [noise_ceiling_upper_bound, fliplr(noise_ceiling_lower_bound)];
    fill(x2, inBetween,c3, 'FaceAlpha', 0.16);
    %title(sprintf("RSA %s %s %s", dist_measure,effect, method))
    xlabel('time (ms)')
    ylabel("Spearman's R")
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(0,'color', '#808080' ,'LineStyle','--', 'LineWidth', 1.5);
    xline(40, 'color', '#808080', 'LineStyle','--', 'LineWidth', 1.5);
    xlim([0,240])
    ylim([-0.06 0.28])
    set(gca,'box','off')
    legend('boxoff')
    legend({'standard - bulls'})
    saveas(gca,sprintf( '%sRSA_pearsson_%s_%s_random_effect_noise_ceiling_statistics_eyetracking_comparison.png',out_path_plots, noise_ceiling_method, noise_ceiling_fixcross));
else
    
    load(sprintf('%ssignificant_variables_standard_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%ssignificant_variables_bulls_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%ssignificant_variables_diff_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    
    load(sprintf('%strue_rsa_rdm_standard_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%strue_rsa_rdm_bulls_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    load(sprintf('%sdiff_true_rsa_rdm_random_effects_eeg_and_eyetracking_pearsson.mat',path_results));
    
    load(sprintf('%snoise_ceiling_eyetracking_standard.mat',path_results));
    eyetracking_noise_ceiling_upper_bounds = noise_ceiling_upper_bound;
    eyetracking_noise_ceiling_lower_bounds = noise_ceiling_lower_bound;
    load(sprintf('%snoise_ceiling_eeg_standard.mat',path_results));
    eeg_noise_ceiling_upper_bounds = noise_ceiling_upper_bound;
    eeg_noise_ceiling_lower_bounds = noise_ceiling_lower_bound;
    
    load(sprintf('%speak_latency_object_eeg_and_eyetracking_standard.mat',path_results));
    peak_latency_standard = peak_latency;
    CI_95_standard = CI_95;
    load(sprintf('%speak_latency_object_eeg_and_eyetracking_bulls.mat',path_results));
    peak_latency_bulls = peak_latency;
    CI_95_bulls = CI_95;
    
    significant_time_points_standard = find(SignificantVariables_category_standard>0);
    y_significants_standard = repmat(-0.04, size(significant_time_points_standard,1),1)';
    
    significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
    y_significants_bulls = repmat(-0.045, size(significant_time_points_bulls,1),1)';
    
    significant_time_points_diff = find(SignificantVariables_category_diff>0);
    y_significants_diff_wave = repmat(70, size(significant_time_points_diff,1),1)';
    
    x = 1:numel(mean(true_rsa_rdm_standard));
    
    true_rsa_rdm_standard_plot = nanmean(true_rsa_rdm_standard);
    true_rsa_rdm_bulls_plot = nanmean(true_rsa_rdm_bulls);
    true_rsa_rdm_diff_plot = nanmean(diff_rsa);
    x2 = [x, fliplr(x)];
    c2 = [146/255 0/255 0/255];
    c1 = [0/255 146/255 146/255];
    c4 = [128/255 128/255 128/255];
    c5 = [105/255 105/255 105/255];
    c3 = [73/255 0/255 146/255];
    
    
    SEM_standard = std(true_rsa_rdm_standard)/sqrt(size(true_rsa_rdm_standard,1));
    SEM_bulls = std(true_rsa_rdm_bulls)/sqrt(size(true_rsa_rdm_bulls,1));
    SEM_diff = std(diff_rsa)/sqrt(size(diff_rsa,1));
    
    actual_peak_standard = find(true_rsa_rdm_standard_plot==max(true_rsa_rdm_standard_plot));
    actual_peak_bulls = find(true_rsa_rdm_bulls_plot==max(mean(true_rsa_rdm_bulls_plot)));
    actual_peak_difference = find(true_rsa_rdm_diff_plot==max(true_rsa_rdm_diff_plot));
    
    figure
    plot(true_rsa_rdm_standard_plot,'Color',c1, 'LineWidth', 1.6)
    hold on
    plot(true_rsa_rdm_bulls_plot,'Color',c2, 'LineWidth', 1.6)
    hold on
%     plot(true_rsa_rdm_diff_plot,'Color',c3,'LineWidth',1.6)
%     hold on
    plot(significant_time_points_bulls, y_significants_bulls,'.', 'Color',c2)
    hold on
    plot(significant_time_points_standard, y_significants_standard,'.','Color',c1)
    hold on
    %plot(significant_time_points_diff, y_significants_diff_wave,'.','Color',c3)
    %hold on
    upper = true_rsa_rdm_standard_plot + SEM_standard;
    lower = true_rsa_rdm_standard_plot - SEM_standard;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c1, 'FaceAlpha', 0.16, 'LineStyle', 'none');
    hold on;
    upper = true_rsa_rdm_bulls_plot + SEM_bulls;
    lower = true_rsa_rdm_bulls_plot - SEM_bulls;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c2, 'FaceAlpha', 0.16, 'LineStyle', 'none');
    hold on;
%     upper = true_rsa_rdm_diff_plot + SEM_diff;
%     lower = true_rsa_rdm_diff_plot - SEM_diff;
%     inBetween = [upper, fliplr(lower)];
%     fill(x2, inBetween, c3, 'FaceAlpha', 0.16, 'LineStyle', 'none');
%     hold on
    % add noise ceiling
    inBetween = [eyetracking_noise_ceiling_upper_bounds, fliplr(eyetracking_noise_ceiling_lower_bounds)];
    fill(x2, inBetween,c4, 'FaceAlpha', 0.16);
    hold on
    inBetween = [eeg_noise_ceiling_upper_bounds, fliplr(eeg_noise_ceiling_lower_bounds)];
    fill(x2, inBetween,c5, 'FaceAlpha', 0.16);
    %add peak latency 
    %errorbar(actual_peak_standard,0.22,(CI_95_standard(2,2)-CI_95_standard(2,1))/2,'d','horizontal','Color',c1, 'LineWidth',1.3)
    plot(actual_peak_standard,-0.07,'d', 'Color',c1, 'MarkerFaceColor',c1)
    plot(CI_95_standard,[-0.07 -0.07],'Color',c1, 'LineWidth', 1.4, 'LineStyle','--')
    plot(CI_95_standard(1,2),-0.07,'|','Color',c1)
    plot(CI_95_standard(2,2),-0.07,'|','Color',c1)
    hold on
    % hold on
    %errorbar(peak_latency_bulls(2),0.2,(CI_95_bulls(2,2)-CI_95_bulls(2,1))/2,'horizontal','d','Color',c2)
    hold on 
    %title(sprintf("RSA %s %s %s", dist_measure,effect, method))
    xlabel('time (ms)')
    ylabel("Spearman's R")
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(0,'color', '#808080' ,'LineStyle','--', 'LineWidth', 1.5);
    xline(40, 'color', '#808080', 'LineStyle','--', 'LineWidth', 1.5);
    xlim([0,240])
    %ylim([-0.06 0.28])
    set(gca,'box','off')
    legend('boxoff')
    legend({'standard', 'bullseye'})
    
    saveas(gca,sprintf( '%sRSA_pearsson_eyetracking_eeg_random_effect_noise_ceiling_statistics_only_significant_peak.png',out_path_plots));
end
end


