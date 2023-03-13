function [] = plot_statistics_time_time(decoding, fixcross,method)

%{
    - reproduces time-generalized plots
    - Input:
        -decoding: "category" or "object"
        - fixcross: "standard", "bulls" or "difference"
        - method: "eeg" or "eyetracking"
%}

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

train = 'time_time';
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/two_tailed/%s_%s/',BASE,decoding,train);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/final/%s_%s/',BASE,decoding,train);
% load(sprintf('%speak_latency_%s_%s_%s.mat',path_results, method, decoding, fixcross));

if ~isfolder(path_plots)
    mkdir(path_plots);
end


if strcmp(fixcross, 'difference') == 1
    load(sprintf('%ssignificant_variables_time_time_diff_curve_%s.mat',path_results, method));
    %load(sprintf('%sadjusted_pvalues_time_time_diff_curve_%s.mat',path_results, method));
    load(sprintf('%stime_time_diff_curve_%s.mat',path_results, method));
    data = diff_curve;
else
    load(sprintf('%ssignificant_variables_time_time_%s_%s.mat',path_results, fixcross, method));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding,train, decoding,fixcross,method));
    data= eval(sprintf('decodingAcc_%s_all',fixcross));
    if strcmp(decoding, 'objects')==1
        data = squeeze(nanmean(data,2));
        data = squeeze(nanmean(data,2));
    end
end


data = data-50;
[peaks_x, peaks_y] = find(squeeze(mean(data,1))==max(squeeze(mean(data,1)),[],'all'));
actual_peak = [peaks_x, peaks_y];
if strcmp(decoding, 'category')==1
    figure
    imagesc(squeeze(nanmean(data,1)))
    hold on
    
    [B,~] = bwboundaries(SignificantVariables);
    hold on
    
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    end
    %peak latency
    set(gca,'YDir','normal');
    %title(sprintf("%s time time %s %s", decoding, method,fixcross))
    xlabel(sprintf('training time - %s (ms)',fixcross))
    ylabel(sprintf('testing time - %s (ms)',fixcross))
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yticks([0 40 80 120 160 200 240])
    set(gca, 'YTickLabel', [-200 0 200 400 600 800 1000])
    colorbar
    %a = colorbar('Limits', [-6 15]);
    a = colorbar
    a.Label.String = 'classification accuracy - chance level (%)'
    %caxis([25 40])
    yline(40,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
    xline(40,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
    hline = refline([1 0]);
    hline.Color = '#FFFFFF';
    hline.LineStyle = '--';
    hline.LineWidth = 1.5;
    plot(actual_peak(1,1),actual_peak(1,2),'d','MarkerFaceColor','#A2142F','MarkerEdgeColor','#A2142F', 'MarkerSize',4)
    hold on
    set(gca,'box','off')
    axis square
    saveas(gca,sprintf( '%s%s_time_time_%s_%s_statistics_only_sig_peaks.png',path_plots,decoding, method,fixcross));
    
elseif strcmp(decoding, 'objects')==1
    
    figure
    imagesc(squeeze(nanmean(data,1)))
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
    %a = colorbar('Limits', [-0.5 4]);
    a = colorbar;
    a.Label.String = 'classification accuracy - chance level (%)';
    %caxis([25 40])
    yline(10,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
    xline(10,'color', '#FFFFFF' ,'LineStyle','--', 'LineWidth', 1.5);
    hline = refline([1 0]);
    hline.Color = '#FFFFFF';
    hline.LineStyle = '--';
    hline.LineWidth = 1.5;
    plot(actual_peak(1,1),actual_peak(1,2),'d','MarkerFaceColor','#A2142F','MarkerEdgeColor','#A2142F', 'MarkerSize',4)
    hold on
    set(gca,'box','off')
    axis square
    saveas(gca,sprintf( '%s%s_time_time_%s_%s_statistics_only_sig_peaks.png',path_plots,decoding, method,fixcross));
end
end

