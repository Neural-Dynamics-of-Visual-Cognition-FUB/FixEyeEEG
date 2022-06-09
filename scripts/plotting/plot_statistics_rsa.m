function [] = plot_statistics_rsa(dist_measure,method,effect)
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
out_path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/rsa/',BASE);
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/rsa/',BASE);

if ~isfolder(out_path_plots)
    mkdir(out_path_plots);
end


% averaged over subjects
if strcmpr(effect, 'fixed') == 1       
    load(sprintf('%ssignificant_variables_standard_%s_%s.m',path_results, method, dist_measure),'SignificantVariables_category_standard');
    load(sprintf('%ssignificant_variables_bulls_%s_%s.m',path_results, method, dist_measure),'SignificantVariables_category_bulls');
    load(sprintf('%strue_rsa_rdm_standard_%s_%s.m',path_results, method, dist_measure),'true_rsa_rdm_standard');
    load(sprintf('%strue_rsa_rdm_bulls_%s_%s.m',path_results, method, dist_measure),'true_rsa_rdm_bulls');
elseif strcmpr(effect, 'random_effects') == 1   
    load(sprintf('%ssignificant_variables_standard_random_effects_%s_%s.m',path_results, method, dist_measure),'SignificantVariables_category_standard');
    load(sprintf('%ssignificant_variables_bulls_random_effects_%s_%s.m',path_results, method, dist_measure),'SignificantVariables_category_bulls');
    load(sprintf('%strue_rsa_rdm_standard_random_effects_%s_%s.m',path_results, method, dist_measure),'true_rsa_rdm_standard');
    load(sprintf('%strue_rsa_rdm_bulls_random_effects_%s_%s.m',path_results, method, dist_measure),'true_rsa_rdm_bulls');    
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
saveas(gca,sprintf( '%sRSA_%s_%s_%s_%s_effect_statistics.png',out_path_plots, dist_measure,decoding, method, effect));
end


