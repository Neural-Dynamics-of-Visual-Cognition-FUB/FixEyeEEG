function [] = calculate_actual_values_CI_time_time(decoding, fixcross,method)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
    train = 'time_time'
     path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_%s/',BASE,decoding,train);
    path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/%s_%s/',BASE,decoding,train);
    load(sprintf('%speak_latency_%s_%s_%s.mat',path_results, method, decoding, fixcross));
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
if strcmp(decoding,'category')
    time_constant = 5;
else
    time_constant = 20;
end
[peaks_x, peaks_y] = find(squeeze(mean(data,1))==max(squeeze(mean(data,1)),[],'all'));
actual_peak = [peaks_x, peaks_y];
[significant_time_points_standard_x,significant_time_points_standard_y]  = find(SignificantVariables>0);
disp(sprintf('decoding: %s, method: %s', decoding,method));

disp(sprintf('###########%s###########', fixcross));
disp(sprintf('start cluster standard x: %d',min(significant_time_points_standard_x)*time_constant-200));
disp(sprintf('start cluster standard y: %d',min(significant_time_points_standard_y)*time_constant-200));
disp(sprintf('actual value standard peak: %d' ,actual_peak*time_constant-200))
disp(sprintf('lower CI value standard peak: %d' ,CI_95(1)*time_constant-200))
disp(sprintf('upper CI value standard peak: %d' ,CI_95(2)*time_constant-200))



end