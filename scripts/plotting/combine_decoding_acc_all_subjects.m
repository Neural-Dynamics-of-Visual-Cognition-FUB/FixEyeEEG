function [outputArg1,outputArg2] = combine_decoding_acc_all_subjects(inputArg1,inputArg2)
%% category decoding 

addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/EEG/stdshade/');
out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/category_decoding/';

if ~isfolder(out_path)
    mkdir(out_path);
end

methods_flag = ["eeg" "eyetracking"];
for idx = 1:2
category_decodingAcc_bulls_all = NaN(30,240);
category_decodingAcc_standard_all = NaN(30,240);

    for subj = 1:30

        %if subj == 2 || subj == 4 || subj == 12 
           % cnt = cnt+1
           % continue; 
       % end
    results_dir = sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/%s/category_decoding/%s', methods_flag(idx), num2str(subj));
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
 
out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/object_decoding/';

if ~isfolder(out_path)
    mkdir(out_path);
end
n_subs = 30;
n_objects = 40;
n_timepoints = 240;
methods_flag = ["eeg" "eyetracking"];

for idx = 1:2
object_decodingAcc_bulls_all = NaN(n_subs,n_objects,n_objects,n_timepoints);
object_decodingAcc_standard_all = NaN(n_subs,n_objects,n_objects,n_timepoints);

    for subj = 1:n_subs
        
    results_dir = sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/%s/object_decoding/%s/', methods_flag(idx), num2str(subj));
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
