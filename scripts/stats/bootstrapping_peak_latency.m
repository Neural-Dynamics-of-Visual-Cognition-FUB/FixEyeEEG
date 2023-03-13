function [] = bootstrapping_peak_latency(decoding,fixcross, method, time)
%{
Bootstrapping to calculate peak latencies
- decoding : 1 or 2
- fixcross: 1 or 2
- method: 1 or 2
- time : 1 or 2
%}
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

if decoding == 1
    decoding = 'category';
elseif decoding == 2
    decoding = 'object';
end

if fixcross == 1
    fixcross = 'standard';
elseif fixcross == 2
    fixcross = 'bulls';
elseif fixcross == 3
    fixcross = 'difference';
end

if method == 1
    method = 'eeg';
elseif method == 2
    method = 'eyetracking';
end


if time == 1
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_%s_all_%s.mat', BASE,decoding,decoding,fixcross,method));
    data = eval(sprintf('%s_decodingAcc_%s_all',decoding,fixcross));
    out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_decoding/',BASE, decoding);
elseif time == 2
    train = 'time_time';
    if strcmp(fixcross,'difference') == 1
        load(sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_time_time/time_time_diff_curve_%s.mat',BASE, decoding, method));
        data = diff_curve;
    else
        load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding, train, decoding,fixcross,method));
        data= eval(sprintf('decodingAcc_%s_all',fixcross));
    end
    out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_%s/',BASE, decoding,train);
end

if strcmp(decoding, 'object')
    data = squeeze(nanmean(data,2));
    data = squeeze(nanmean(data,2));
end

bootstrap_samples = 10000;
peak_latency_samples = NaN(bootstrap_samples,2);

rng('shuffle')
for bs = 1:bootstrap_samples
    bootstrapped_datasets = datasample(data,30,1);
    avg_datasets = squeeze(mean(bootstrapped_datasets,1));
    [peaks_x, peaks_y,v] = find(avg_datasets==max(avg_datasets,[],'all'));
    if size(peaks_x,1) > 1
        peaks_x = round(mean(peaks_x));
        peaks_y = round(mean(peaks_y));
    end
    peak_latency_samples(bs,1)=peaks_x;
    peak_latency_samples(bs,2)=peaks_y;
end
peak_latency = round(mean(peak_latency_samples,1));

CI_95 = NaN(2,2);
CI_95(1,:) = prctile(peak_latency_samples,2.5);
CI_95(2,:) = prctile(peak_latency_samples,97.5);


save(sprintf('%speak_latency_%s_%s_%s.mat',out_path_results, method, decoding, fixcross),'peak_latency','CI_95','peak_latency_samples');

end

