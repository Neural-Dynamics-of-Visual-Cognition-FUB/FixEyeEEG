function [] = plot_statistics_time_time(decoding, fixcross,method,train, stats)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';

end

if train == 1
    train = 'time_time';
elseif train == 2
    train = 'time_time_train_test';
end 

if strcmp(stats, 'perm')
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_%s/',BASE,decoding,train);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/%s_%s/',BASE,decoding,train);

if ~isfolder(path_plots)
    mkdir(path_plots);
end
elseif strcmp(stats, 'cluster')
    path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_%s/',BASE,decoding,train);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/%s_%s/',BASE,decoding,train);

if ~isfolder(path_plots)
    mkdir(path_plots);
end
end

if strcmp(fixcross, 'difference') == 1
load(sprintf('%ssignificant_variables_time_time_diff_curve_%s.mat',path_results, method));
load(sprintf('%sadjusted_pvalues_time_time_diff_curve_%s.mat',path_results, method));
load(sprintf('%stime_time_diff_curve_%s.mat',path_results, method));
data = diff_curve;
else 
load(sprintf('%ssignificant_variables_time_time_%s_%s.mat',path_results, fixcross, method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding,train, decoding,fixcross,method));
data= eval(sprintf('decodingAcc_%s_all',fixcross));
if strcmp(decoding, 'objects')==1
data = squeeze(mean(data,2));
data = squeeze(mean(data,2));
end
end
data = data-50;

if strcmp(decoding, 'category')==1
figure
imagesc(squeeze(mean(data,1)))
hold on
[B,~] = bwboundaries(SignificantVariables);
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end
set(gca,'YDir','normal');
%title(sprintf("%s time time %s %s", decoding, method,fixcross))
xlabel(sprintf('training time - %s (ms)',fixcross))
ylabel(sprintf('testing time - %s (ms)',fixcross))
xticks([0 40 80 120 160 200 240])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yticks([0 40 80 120 160 200 240])
set(gca, 'YTickLabel', [-200 0 200 400 600 800 1000])
colorbar
%a = colorbar('Limits', [-6 9]);
a = colorbar
a.Label.String = 'classification accuracy - chance level (%)'
%caxis([25 40])
yline(40,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
xline(40,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
hline = refline([1 0]);
hline.Color = '#FFFFFF';
hline.LineStyle = '--';
hline.LineWidth = 1.5;
set(gca,'box','off')
axis square
saveas(gca,sprintf( '%s%s_time_time_%s_%s_statistics.png',path_plots,decoding, method,fixcross));

elseif strcmp(decoding, 'objects')==1

figure
imagesc(squeeze(mean(data,1)))
hold on
[B,~] = bwboundaries(SignificantVariables);
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end
set(gca,'YDir','normal');
%title(sprintf("%s time time %s %s", decoding, method,fixcross))
xlabel(sprintf('training time - %s (ms)',fixcross))
ylabel(sprintf('testing time - %s (ms)',fixcross))
xticks([0 10 20 30 40 50 60])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yticks([0 10 20 30 40 50 60])
set(gca, 'YTickLabel', [-200 0 200 400 600 800 1000])
a = colorbar('Limits', [-3 4]);
%a = colorbar;
a.Label.String = 'classification accuracy - chance level (%)';
%caxis([25 40])
yline(10,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
xline(10,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
hline = refline([1 0]);
hline.Color = '#FFFFFF';
hline.LineStyle = '--';
hline.LineWidth = 1.5;
set(gca,'box','off')
axis square
saveas(gca,sprintf( '%s%s_time_time_%s_%s_statistics.png',path_plots,decoding, method,fixcross));
end
end

