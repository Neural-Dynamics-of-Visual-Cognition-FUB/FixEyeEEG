function [outputArg1,outputArg2] = bootrstrapp_peak_latency_difference(decoding, method)
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

    path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_decoding/',BASE,decoding);
    path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/cluster_based_perm/final/%s_decoding/',BASE,decoding);


    load(sprintf('%speak_latency_%s_%s_standard.mat',path_results, method, decoding));
        peak_latency_standard = peak_latency_samples;
        CI_95_standard = CI_95;

    load(sprintf('%speak_latency_%s_%s_bulls.mat',path_results, method, decoding));
        peak_latency_bulls = peak_latency_samples;
        CI_95_bulls = CI_95;

        % calculate the difference between the peak latencies 
        peak_latency_difference = abs(squeeze(peak_latency_bulls(:,1))-squeeze(peak_latency_standard(:,1)));
        CI_peak_difference(1)=prctile(peak_latency_difference,2.5)
        CI_peak_difference(2)=prctile(peak_latency_difference,97.5);
end

