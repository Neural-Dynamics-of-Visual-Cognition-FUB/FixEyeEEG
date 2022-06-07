function [] = plot_statistics_train_test(decoding, method)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_train_test/',BASE,decoding);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/%s_train_test/',BASE,decoding);

load(sprintf('%ssignificantVariables_bulls_standard_%s_%s.mat',path_results, method,decoding));
load(sprintf('%ssignificantVariables_standard_bulls_%s_%s.mat',path_results, method,decoding));

load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_standard_all_%s.mat', BASE,decoding,decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_bulls_all_%s.mat', BASE,decoding,decoding,method));


decodingAcc_bulls_standard = eval(sprintf('%s_decodingAcc_bulls_standard',decoding));
decodingAcc_standard_bulls = eval(sprintf('%s_decodingAcc_standard_bulls',decoding));

if strcmp(decoding, 'object') == 1
    decodingAcc_bulls = squeeze(nanmean(squeeze(nanmean(decodingAcc_bulls_standard,2)),2));
    decodingAcc_standard = squeeze(nanmean(squeeze(nanmean(decodingAcc_standard_bulls,2)),2));
elseif strcmp(decoding, 'category') == 1
    decodingAcc_bulls = decodingAcc_bulls_standard;
    decodingAcc_standard = decodingAcc_standard_bulls;
end
    

if ~isfolder(path_plots)
    mkdir(path_plots);
end

if strcmp(method,'eeg') ==1
    y_point_standard = 46;
    y_point_bulls = 44;
elseif strcmp(method,'eyetracking')
    y_point_standard = 49.8;
    y_point_bulls = 49.6;
end

significant_time_points_standard = find(SignificantVariables_standard_bulls>0);
y_significants_standard = repmat(y_point_standard, size(significant_time_points_standard,2),1)';

significant_time_points_bulls = find(SignificantVariables_bulls_standard>0);
y_significants_bulls = repmat(y_point_bulls, size(significant_time_points_bulls,2),1)';


x = 1:numel(mean(decodingAcc_standard));
x2 = [x, fliplr(x)];
c2 = [146/255 0/255 0/255];
c1 = [0/255 146/255 146/255];



SEM_standard = std(decodingAcc_standard)/sqrt(size(decodingAcc_standard,1));
SEM_bulls = std(decodingAcc_bulls)/sqrt(size(decodingAcc_bulls,1));

figure
plot(mean(decodingAcc_standard),'Color',c1)
hold on
plot(mean(decodingAcc_bulls),'Color',c2)
hold on
upper = mean(decodingAcc_standard) + SEM_standard;
lower = mean(decodingAcc_standard) - SEM_standard;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c1, 'FaceAlpha', 0.2);
hold on;
upper = mean(decodingAcc_bulls) + SEM_bulls;
lower = mean(decodingAcc_bulls) - SEM_bulls;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c2, 'FaceAlpha', 0.2);
hold on;

plot(significant_time_points_standard, y_significants_standard,'*','Color',c1)
hold on

plot(significant_time_points_bulls, y_significants_bulls,'*', 'Color',c2)
title(sprintf("%s decoding accuracy train test %s", decoding, method))
xlabel('time')
ylabel('accuracy')
xticks([0 40 80 120 160 200 240])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yline(50);
xline(40);
legend({'standard --> bulls','bulls --> standard'})
saveas(gca,sprintf( '%s%s_decoding_train_test_%s_statistics.png',path_plots, decoding, method));
end





