function [] = combine_pearsson()
%% object decoding


if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end


out_path = sprintf('%sdata/FixEyeEEG/main/results/object_pearsson/', BASE);

if ~isfolder(out_path)
    mkdir(out_path);
end
n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
n_objects = 40;
n_timepoints = 240;
methods_flag = ["eeg" "eyetracking"];

for idx = 1:2
    object_rdm_bulls_all = NaN(n_subs,n_objects,n_objects,n_timepoints);
    object_rdm_standard_all = NaN(n_subs,n_objects,n_objects,n_timepoints);
    
    for subj = 1:n_subs
        
        results_dir = sprintf('%sdata/FixEyeEEG/main/%s/object_pearsson/%s/',BASE, methods_flag(idx), num2str(subs(subj)));
        
        load(sprintf("%s/objects_bulls_rdm_avg.mat", results_dir));
        object_rdm_bulls_all(subj,:,:,:) =  rdm_avg_bulls;
        
        load(sprintf("%s/objects_standard_rdm_avg.mat", results_dir));
        object_rdm_standard_all(subj,:,:,:) =  rdm_avg_standard;
        
    end
    tmp = squeeze(nanmean(object_rdm_standard_all,2));
    tmp = squeeze(nanmean(tmp,2));
    object_pearsson_difference_wave = object_rdm_standard_all - object_rdm_bulls_all;
    save(sprintf('%sobject_decodingAcc_bulls_all_%s', out_path, methods_flag(idx)), 'object_rdm_bulls_all')
    save(sprintf('%sobject_decodingAcc_standard_all_%s', out_path, methods_flag(idx)), 'object_rdm_standard_all')
    save(sprintf('%sobject_difference_wave_%s', out_path, methods_flag(idx)), 'object_pearsson_difference_wave')
end
end

