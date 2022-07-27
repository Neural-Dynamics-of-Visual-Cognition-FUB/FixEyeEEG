function [outputArg1,outputArg2] = plot_statistics(decoding,method, stats)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
if strcmp(stats,'cluster')
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_decoding/',BASE,decoding);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/%s_decoding/',BASE,decoding);
elseif strcmp(stats,'perm')
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_decoding/',BASE,decoding);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/%s_decoding/',BASE,decoding);
end


fixcross = {'standard'; 'bulls'; 'diff_wave'};
for idx=1:3
    load(sprintf('%ssignificant_variables_%s_%s_%s.mat',path_results, fixcross{idx}, method,decoding));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_%s_all_%s.mat', BASE,decoding,decoding,fixcross{idx},method));
end

if ~isfolder(path_plots)
    mkdir(path_plots);
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
    if strcmp(method,'eyetracking')==1
    ys = -2;
    yb=-3;
    yw = -4;
    elseif strcmp(method,'eeg')==1
    ys = -2;
    yb=-3;
    yw = -4;
    end
elseif strcmp(decoding, 'category') == 1
    
    decodingAcc_standard = decodingAcc_standard-50;
    decodingAcc_bulls = decodingAcc_bulls -50;
    decodingAcc_diff_wave = decodingAcc_diff_wave-50;
    ys = -10;
    yb=-11;
    yw=-12;
end

significant_time_points_standard = find(SignificantVariables_standard>0);
y_significants_standard = repmat(ys, size(significant_time_points_standard',2),1)';

significant_time_points_bulls = find(SignificantVariables_bulls>0);
y_significants_bulls = repmat(yb, size(significant_time_points_bulls',2),1)';

significant_time_points_diff_wave = find(SignificantVariables_diff_wave>0);
y_significants_diff_wave = repmat(yw, size(significant_time_points_diff_wave',2),1)';



x = 1:numel(mean(decodingAcc_standard));
x2 = [x, fliplr(x)];
c3 = [73/255 0/255 146/255];
c2 = [146/255 0/255 0/255];
c1 = [0/255 146/255 146/255];


SEM_standard = std(decodingAcc_standard)/sqrt(size(decodingAcc_standard,1));
SEM_bulls = std(decodingAcc_bulls)/sqrt(size(decodingAcc_bulls,1));
SEM_diff = std(decodingAcc_diff_wave)/sqrt(size(decodingAcc_diff_wave,1));

figure
plot(mean(decodingAcc_standard),'Color',c1, 'LineWidth', 1.6)
hold on
plot(mean(decodingAcc_bulls),'Color',c2, 'LineWidth', 1.6)
hold on
plot(mean(decodingAcc_diff_wave),'Color',c3,'LineWidth', 1.6 )
hold on
upper = mean(decodingAcc_standard) + SEM_standard;
lower = mean(decodingAcc_standard) - SEM_standard;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c1, 'FaceAlpha', 0.16, 'LineStyle', 'none');
hold on;
upper = mean(decodingAcc_bulls) + SEM_bulls;
lower = mean(decodingAcc_bulls) - SEM_bulls;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c2, 'FaceAlpha', 0.155, 'LineStyle', 'none');
hold on;
upper = mean(decodingAcc_diff_wave) + SEM_diff;
lower = mean(decodingAcc_diff_wave) - SEM_diff;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c3, 'FaceAlpha', 0.15, 'LineStyle', 'none');
hold on;
plot(significant_time_points_standard, y_significants_standard,'.','Color',c1)
hold on
plot(significant_time_points_bulls, y_significants_bulls,'.', 'Color',c2)
hold on
plot(significant_time_points_diff_wave, y_significants_diff_wave,'.', 'Color',c3)
%title(sprintf("%s decoding accuracy %s", decoding, method))
xlabel('time (ms)')
ylabel('classification accuracy - chance level (%)')
xticks([0 40 80 120 160 200 240])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yline(0,'color', '#808080' ,'LineStyle','--', 'LineWidth', 1.5);
xline(40, 'color', '#808080', 'LineStyle','--', 'LineWidth', 1.5);
xlim([0,240])
ylim([-15,50])
legend({'standard', 'bullseye', 'difference'})
set(gca,'box','off')
legend('boxoff')
saveas(gca,sprintf('%s%s_decoding_%s_statistics.png',path_plots, decoding, method));
end


