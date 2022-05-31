function [] = combine_time_time_all_subjects(decoding)
%% category decoding


if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

out_path = sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/', BASE,decoding);

if ~isfolder(out_path)
    mkdir(out_path);
end
n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
n_timepoints = 240;
methods_flag = ["eeg" "eyetracking"];

for idx = 1:2
    if strcmp(decoding, 'category') == 1
        decodingAcc_standard_all = NaN(n_subs,n_timepoints,n_timepoints);
        decodingAcc_bulls_all = NaN(n_subs,n_timepoints,n_timepoints);
    end
    
    for subj = 1:n_subs
        results_dir = sprintf('%sdata/FixEyeEEG/main/%s/%s_time_time/%s', BASE,methods_flag(idx),decoding,num2str(subs(subj)));
        
        fileToRead1 = fullfile(sprintf('%s/%s_standard_time_time_avg.mat',results_dir, decoding));
        load(fileToRead1);
        fileToRead2 = fullfile(sprintf('%s/%s_bulls_time_time_avg.mat',results_dir,decoding));
        load(fileToRead2);
        
        if strcmp(decoding, 'category') == 1
            decodingAcc_standard_all(subj,:,:) =  decodingAccuracy_avg_standard;
            decodingAcc_bulls_all(subj,:,:) = decodingAccuracy_avg_bulls;
        elseif strcmp(decoding, 'objects') == 1
            decodingAcc_standard_all(subj,:,:,:,:) =  decodingAccuracy_objects_time_time_avg_standard;
            decodingAcc_bulls_all(subj,:,:,:,:) =  decodingAccuracy_objects_time_time_avg_bulls;      
        end
    end
    save(sprintf('%s%s_decodingAcc_standard_%s', out_path, decoding,methods_flag(idx)), 'decodingAcc_standard_all')
    save(sprintf('%s%s_decodingAcc_bulls_%s', out_path, decoding, methods_flag(idx)), 'decodingAcc_bulls_all')
end
end
