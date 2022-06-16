function [outputArg1,outputArg2] = combine_decoding_acc_all_subjects()
%% category decoding 

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
end

out_path = sprintf('%sdata/FixEyeEEG/main/results/category_decoding/',BASE);
n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
n_timepoints = 240;

if ~isfolder(out_path)
    mkdir(out_path);
end

methods_flag = ["eeg" "eyetracking"];
for idx = 1:2
category_decodingAcc_bulls_all = NaN(n_subs,n_timepoints);
category_decodingAcc_standard_all = NaN(n_subs,n_timepoints);

    for subj = 1:n_subs

        results_dir = sprintf('%sdata/FixEyeEEG/main/%s/category_decoding/%s', BASE, methods_flag(idx), num2str(subs(subj)));
        filename = 'animate_inanimate_category';
        fileToRead1 = fullfile(results_dir,sprintf('%s_decodingAccuracy_standard.mat',filename));

    
    if exist(fileToRead1, 'file') == 0
      % File does not exist
      % Skip to bottom of loop and continue with the loop
     continue;
   end

    load(fullfile(results_dir,sprintf('%s_decodingAccuracy_standard.mat',filename)),'decodingAccuracy_avg_standard');
    load(fullfile(results_dir,sprintf('%s_decodingAccuracy_bulls.mat',filename)),'decodingAccuracy_avg_bulls');
    
    category_decodingAcc_bulls_all(subj,:) =  decodingAccuracy_avg_bulls;
    category_decodingAcc_standard_all(subj,:) =  decodingAccuracy_avg_standard;
    
    end
    category_difference_wave = category_decodingAcc_standard_all - category_decodingAcc_bulls_all + 50;
    save(sprintf('%scategory_decodingAcc_bulls_all_%s', out_path, methods_flag(idx)), 'category_decodingAcc_bulls_all')
    save(sprintf('%scategory_decodingAcc_standard_all_%s', out_path, methods_flag(idx)), 'category_decodingAcc_standard_all')
    save(sprintf('%scategory_difference_wave_%s', out_path, methods_flag(idx)), 'category_difference_wave')
end
 %% object decoding
 
out_path = sprintf('%sdata/FixEyeEEG/main/results/object_decoding_all_same_trials/',BASE);

if ~isfolder(out_path)
    mkdir(out_path);
end
n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
n_objects = 40;
n_timepoints = 240;
methods_flag = ["eeg" "eyetracking"];

for idx = 1:2
object_decodingAcc_bulls_all = NaN(n_subs,n_objects,n_objects,n_timepoints);
object_decodingAcc_standard_all = NaN(n_subs,n_objects,n_objects,n_timepoints);

    for subj = 1:n_subs
        
    results_dir = sprintf('%sdata/FixEyeEEG/main/%s/object_decoding_all_same_trials/%s/', BASE, methods_flag(idx), num2str(subs(subj)));
   % filename = 'animate_inanimate_category';
    fileToRead1 = sprintf("%s/objects_bulls_decodingAccuracy.mat", results_dir);
    
    if exist(fileToRead1, 'file') == 0
      % File does not exist
      % Skip to bottom of loop and continue with the loop
     continue;
    end

    load(sprintf("%s/objects_bulls_decodingAccuracy.mat", results_dir));
    object_decodingAcc_bulls_all(subj,:,:,:) =  decodingAccuracy_object_bulls_avg;
    
    load(sprintf("%s/objects_standard_decodingAccuracy.mat", results_dir));
    object_decodingAcc_standard_all(subj,:,:,:) =  decodingAccuracy_object_standard_avg;

    end
    object_difference_wave = object_decodingAcc_standard_all - object_decodingAcc_bulls_all + 50;
    save(sprintf('%sobject_decodingAcc_bulls_all_%s', out_path, methods_flag(idx)), 'object_decodingAcc_bulls_all')
    save(sprintf('%sobject_decodingAcc_standard_all_%s', out_path, methods_flag(idx)), 'object_decodingAcc_standard_all')
    save(sprintf('%sobject_difference_wave_%s', out_path, methods_flag(idx)), 'object_difference_wave')
end
end
