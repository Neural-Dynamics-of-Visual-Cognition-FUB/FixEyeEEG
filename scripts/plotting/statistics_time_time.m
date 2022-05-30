function [] = statistics_time_time(decoding,fixcross,method,n_perm,q_value)
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';

end
out_path = sprintf('%sdata/FixEyeEEG/main/results/plots/',BASE);
load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_%s_%s.mat', BASE,decoding,decoding,fixcross,method));
data= eval(sprintf('decodingAcc_%s_all',fixcross));
% load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/category_decodingAcc_between_eyetracking.mat', BASE,decoding));
% standard_eyetracking = decodingAcc_standard_all;
% 
% load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/category_decodingAcc_within_eeg.mat', BASE,decoding));
% bulls_EEG = decodingAcc_bulls_all;
% load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/category_decodingAcc_within_eyetracking.mat', BASE,decoding));
% bulls_eyetracking = decodingAcc_bulls_all;

if strcmp(decoding, 'objects')==1
    data = squeeze(mean(data,2));
end

[SignificantVariables, pvalues, crit_p, adjusted_pvalues] = fdr_permutation_cluster_1sample_alld(data,n_perm,'right', q_value);
if strcmp(decoding, 'standard')==1
figure
imagesc(squeeze(mean(data,1)))
hold on
[B,~] = bwboundaries(SignificantVariables);
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end
set(gca,'YDir','normal');
title(sprintf("%s time time %s %s", decoding, method,fixcross))
xlabel('time [ms]')
ylabel('time [ms]')
xticks([0 40 80 120 160 200 240])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yticks([0 40 80 120 160 200 240])
set(gca, 'YTickLabel', [-200 0 200 400 600 800 1000])
colorbar
caxis([25 40])
yline(40,'--w');
xline(40,'--w');
hline = refline([1 0]);
hline.Color = 'w';
hline.LineStyle = '--';
saveas(gca,sprintf( '%s%s_time_time_%s_%s_statistics.png',out_path,decoding, method,fixcross));

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
title(sprintf("%s time time %s %s", decoding, method,fixcross))
xlabel('time [ms]')
ylabel('time [ms]')
xticks([0 10 20 30 40 50 60])
set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
yticks([0 10 20 30 40 50 60])
set(gca, 'YTickLabel', [-200 0 200 400 600 800 1000])
colorbar
%caxis([25 40])
yline(10,'--w');
xline(10,'--w');
hline = refline([1 0]);
hline.Color = 'w';
hline.LineStyle = '--';
saveas(gca,sprintf( '%s%s_time_time_%s_%s_statistics.png',out_path,decoding, method,fixcross));
end
end
