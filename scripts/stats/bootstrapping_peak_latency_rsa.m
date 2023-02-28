function [outputArg1,outputArg2] = bootstrapping_peak_latency_rsa(fixcross)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);
if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
decoding = 'object';

if fixcross == 1
    fixcross = 'standard';
elseif fixcross == 2
    fixcross = 'bulls';
end

load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_%s_all_eeg.mat',BASE,decoding,decoding, fixcross));

decodingAcc_eeg = eval(sprintf('%s_rdm_%s_all',decoding,fixcross));

load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_%s_all_eyetracking.mat',BASE,decoding,decoding, fixcross));


decodingAcc_eyetracking = eval(sprintf('%s_rdm_%s_all',decoding,fixcross));


%true_rsa_rdm = calculate_ground_truth_rsa(decodingAcc_standard_1,decodingAcc_standard_2, subj);

bootstrap_samples = 10000;
peak_latency_samples = NaN(bootstrap_samples,2);


rng(0,'twister')
for bs = 1:bootstrap_samples
    if ~rem(bs,100)
        disp(['Create bootstrapping samples: ' num2str(bs) ' out of ' num2str(bootstrap_samples)]);
    end
    [bootstrapped_datasets_eeg,idx] = datasample(decodingAcc_eeg,30,1);
    bootstrapped_dataset_eyetracking = decodingAcc_eyetracking(idx,:,:,:);
    bootstrapped_rsa_rdm = calculate_ground_truth_rsa(bootstrapped_datasets_eeg,bootstrapped_dataset_eyetracking, 30);
    avg_datasets = squeeze(mean(bootstrapped_rsa_rdm,1));
    [peaks_x, peaks_y] = find(avg_datasets==max(avg_datasets,[],'all'));
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


save(sprintf('%speak_latency_%s_eeg_and_eyetracking_%s.mat',out_path_results, decoding, fixcross),'peak_latency','CI_95','peak_latency_samples');

end

