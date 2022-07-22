
function [] = statistics_time_time(decoding,fixcross,method, train, stats)
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
end

if method == 1
    method = 'eeg';
elseif method == 2
    method = 'eyetracking';
end

if train == 1
    train = 'time_time';
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding, train, decoding,fixcross,method));
    data= eval(sprintf('decodingAcc_%s_all',fixcross));
elseif train == 2
    train = 'time_time_train_test';
    % average over training and testing 
     load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding, train, decoding,'standard',method));
     load(sprintf('%sdata/FixEyeEEG/main/results/%s_%s/%s_decodingAcc_%s_%s.mat', BASE,decoding, train, decoding,'bulls',method));
    if strcmp(decoding,'category')
        data = NaN(30,240,240);
        for idx=1:30
            tmp_standard=squeeze(decodingAcc_standard_all(idx,:,:));
            tmp_bulls = squeeze(decodingAcc_bulls_all(idx,:,:));
         data(idx,:,:)= (tmp_standard+permute(tmp_bulls,[2 1]))/2; 
        end
    elseif strcmp(decoding,'object')
         data = NaN(30,40,40,60,60);
        for idx=1:30
            tmp_standard=squeeze(decodingAcc_standard_all(idx,:,:,:,:));
            tmp_bulls = squeeze(decodingAcc_bulls_all(idx,:,:,:,:));
         data(idx,:,:,:,:)= (tmp_standard+permute(tmp_bulls,[1 2 3 4]))/2; 
        end
    end
end 

n_perm = 10000;
q_value = 0.05;




if strcmp(decoding, 'object')==1
     data = squeeze(mean(data,2));
     data = squeeze(mean(data,2));
end

if strcmp(stats, 'perm')
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_%s/',BASE, decoding,train);

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
    [SignificantVariables, pvalues, crit_p, adjusted_pvalues] = fdr_permutation_cluster_1sample_alld(data,n_perm,'right', q_value);
    save(sprintf('%ssignificant_variables_time_time_%s_%s.mat',out_path_results, fixcross, method),'SignificantVariables');
    save(sprintf('%sadjusted_pvalues_time_time_%s_%s.mat',out_path_results, fixcross, method),'adjusted_pvalues');
elseif strcmp(stats,'cluster')
    data = data-50;
    out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/%s_%s/',BASE, decoding,train);

if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
    cluster_thr = 0.05;
    significance_thr = 0.05;
    [SignificantVariables,significantVarMax,pValWei,pValMax,clusters_standard] = permutation_cluster_1sample_weight_alld(data, n_perm, cluster_thr, significance_thr,'right');
    
    save(sprintf('%ssignificant_variables_time_time_%s_%s.mat',out_path_results, fixcross, method),'SignificantVariables','significantVarMax','pValWei','pValMax','clusters_standard');
    
end
end

