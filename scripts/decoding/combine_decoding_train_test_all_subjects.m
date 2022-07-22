function [outputArg1,outputArg2] = combine_decoding_train_test_all_subjects()
%% category decoding 


if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

out_path = sprintf('%sdata/FixEyeEEG/main/results/category_train_test/',BASE);
n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
n_timepoints = 240;

if ~isfolder(out_path)
    mkdir(out_path);
end

methods_flag = ["eeg" "eyetracking"];
for idx = 1
category_decodingAcc_bulls_standard = NaN(n_subs,n_timepoints);
category_decodingAcc_standard_bulls = NaN(n_subs,n_timepoints);

    for subj = 1:n_subs
        results_dir = sprintf('%sdata/FixEyeEEG/main/%s/category_train_test/%s/',BASE, methods_flag(idx), num2str(subs(subj)));
        
        load(sprintf("%s/animate_inanimate_bulls_standard_category_decodingAccuracy_train_standard.mat", results_dir));
        category_decodingAcc_bulls_standard(subj,:) =  decodingAccuracy_avg;
        
        load(sprintf("%s/animate_inanimate_standard_bulls_category_decodingAccuracy_train_standard.mat", results_dir));
        category_decodingAcc_standard_bulls(subj,:) =  decodingAccuracy_avg;
    
    end
    save(sprintf('%scategory_decodingAcc_bulls_standard_all_%s', out_path, methods_flag(idx)), 'category_decodingAcc_bulls_standard')
    save(sprintf('%scategory_decodingAcc_standard_bulls_all_%s', out_path, methods_flag(idx)), 'category_decodingAcc_standard_bulls')
end
 %% object decoding
 
out_path = sprintf('%sdata/FixEyeEEG/main/results/object_train_test/',BASE);

if ~isfolder(out_path)
    mkdir(out_path);
end
n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
n_objects = 40;
n_timepoints = 240;
methods_flag = ["eeg" "eyetracking"];

for idx = 1
object_decodingAcc_bulls_standard = NaN(n_subs,n_objects,n_objects,n_timepoints);
object_decodingAcc_standard_bulls = NaN(n_subs,n_objects,n_objects,n_timepoints);

    for subj = 1:n_subs
        
    results_dir = sprintf('%sdata/FixEyeEEG/main/%s/object_train_test/%s/', BASE, methods_flag(idx), num2str(subs(subj)));
   % filename = 'animate_inanimate_category';
    fileToRead1 = sprintf("%s/objects_bulls_decodingAccuracy.mat", results_dir);

    load(sprintf("%s/bulls_standard_object_decodingAccuracy_train_standard.mat", results_dir));
    object_decodingAcc_bulls_standard(subj,:,:,:) =  decodingAccuracy_object_avg;
    
    load(sprintf("%s/standard_bulls_object_decodingAccuracy_train_standard.mat", results_dir));
    object_decodingAcc_standard_bulls(subj,:,:,:) =  decodingAccuracy_object_avg;

    end
    save(sprintf('%sobject_decodingAcc_bulls_standard_all_%s', out_path, methods_flag(idx)), 'object_decodingAcc_bulls_standard')
    save(sprintf('%sobject_decodingAcc_standard_bulls_all_%s', out_path, methods_flag(idx)), 'object_decodingAcc_standard_bulls')
end
end
