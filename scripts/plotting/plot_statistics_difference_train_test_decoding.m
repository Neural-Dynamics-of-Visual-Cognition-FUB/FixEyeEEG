function [outputArg1,outputArg2] = plot_statistics_difference_train_test_decoding(decoding,method,fixcross)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_difference_train_test_decoding/',BASE,decoding);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/%s_difference_train_test_decoding/',BASE,decoding);

% load difference wave 
load(sprintf('%ssignificant_variables_%s_%s_%s.mat',path_results, fixcross, method,decoding));
load(sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_difference_train_test_decoding/difference_train_test_%s_%s.mat', BASE,decoding,fixcross,method));


if ~isfolder(path_plots)
    mkdir(path_plots);
end
% load train test to calculate avg
load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_standard_all_%s.mat', BASE,decoding,decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_bulls_all_%s.mat', BASE,decoding,decoding,method));

difference = eval(sprintf('difference_%s',fixcross));
decodingAcc_bulls_standard = eval(sprintf('%s_decodingAcc_bulls_standard',decoding));
decodingAcc_standard_bulls = eval(sprintf('%s_decodingAcc_standard_bulls',decoding));


avg_train_test = (decodingAcc_bulls_standard + decodingAcc_standard_bulls)/2;

% load 'normal decoding'
load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_%s_all_%s.mat', BASE,decoding,decoding,fixcross,method));
decodingAcc = eval(sprintf('%s_decodingAcc_%s_all',decoding, fixcross));

if strcmp(decoding, 'object') == 1
    difference = squeeze(nanmean(squeeze(nanmean(difference,2)),2));
    decodingAcc = squeeze(nanmean(squeeze(nanmean(decodingAcc,2)),2))-50;
    avg_train_test = squeeze(nanmean(squeeze(nanmean(avg_train_test,2)),2))-50;
    ys = -2;
    yb=-3;
    yw = -6;
elseif strcmp(decoding, 'category') == 1
    decodingAcc = decodingAcc-50;
    avg_train_test = avg_train_test-50;
    ys = -10;
    yb=-12;
    yw = -14;
end
SignificantVariables = eval(sprintf('SignificantVariables_%s', fixcross));

significant_time_points = find(SignificantVariables>0);
y_significants = repmat(ys, size(significant_time_points,2),1)';

x = 1:numel(mean(difference));
x2 = [x, fliplr(x)];
c2 = [146/255 0/255 0/255];
c1 = [0/255 146/255 146/255];
c3 = [73/255 0/255 146/255];


SEM_difference = std(difference)/sqrt(size(difference,1));
SEM_decoding = std(decodingAcc)/sqrt(size(decodingAcc,1));
SEM_avg = std(avg_train_test)/sqrt(size(avg_train_test,1));

figure
plot(mean(decodingAcc),'Color',c1, 'LineWidth', 1.6)
hold on
plot(mean(avg_train_test),'Color',c2, 'LineWidth', 1.6)
hold on
plot(mean(difference),'Color',c3, 'LineWidth', 1.6)
upper = mean(decodingAcc) + SEM_decoding;
lower = mean(decodingAcc) - SEM_decoding;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c1, 'FaceAlpha', 0.16, 'LineStyle', 'none');
hold on;
upper = mean(avg_train_test) + SEM_avg;
lower = mean(avg_train_test) - SEM_avg;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c2, 'FaceAlpha', 0.16, 'LineStyle', 'none');
hold on;
upper = mean(difference) + SEM_difference;
lower = mean(difference) - SEM_difference;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c3, 'FaceAlpha', 0.16, 'LineStyle', 'none');
hold on;
plot(significant_time_points, y_significants,'*','Color',c3)
hold on
title(sprintf("%s decoding accuracy %s %s", decoding, method, fixcross))
xlabel('time [ms]')
ylabel('decoding accuracy - 50 [%]')
xticks([0 40 80 120 160 200 240])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yline(0);
xline(40);
xlim([0,240])

legend({'decodingAcc', 'avg', 'difference'})
saveas(gca,sprintf('%s%s_decoding_%s_%s_statistics.png',path_plots, decoding, method, fixcross));
end
