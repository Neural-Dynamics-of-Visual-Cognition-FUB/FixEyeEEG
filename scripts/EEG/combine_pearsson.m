function [outputArg1,outputArg2] = combine_pearsson(inputArg1,inputArg2)
 %% object decoding
 
out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/pearsson/';

if ~isfolder(out_path)
    mkdir(out_path);
end
n_subs = 30;
n_objects = 40;
n_timepoints = 240;
methods_flag = ["eeg" "eyetracking"];

for idx = 1:2
object_rdm_bulls_all = NaN(n_subs,n_objects,n_objects,n_timepoints);
object_rdm_standard_all = NaN(n_subs,n_objects,n_objects,n_timepoints);

    for subj = 1:n_subs
        
    results_dir = sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/%s/pearsson/%s/', methods_flag(idx), num2str(subj));
   % filename = 'animate_inanimate_category';
    fileToRead1 = sprintf("%s/objects_bulls_rdm_avg.mat", results_dir);
    
    if exist(fileToRead1, 'file') == 0
      % File does not exist
      % Skip to bottom of loop and continue with the loop
     continue;
    end

    load(sprintf("%s/objects_bulls_rdm_avg.mat", results_dir));
    object_rdm_bulls_all(subj,:,:,:) =  rdm_avg_bulls;
    
    load(sprintf("%s/objects_standard_rdm_avg.mat", results_dir));
    object_rdm_standard_all(subj,:,:,:) =  rdm_avg_standard;

    end
    
%     object_difference_wave = object_decodingAcc_standard_all - object_decodingAcc_bulls_all + 50;
%     save(sprintf('%sobject_decodingAcc_bulls_all_%s', out_path, methods_flag(idx)), 'object_decodingAcc_bulls_all')
%     save(sprintf('%sobject_decodingAcc_standard_all_%s', out_path, methods_flag(idx)), 'object_decodingAcc_standard_all')
%     save(sprintf('%sobject_difference_wave_%s', out_path, methods_flag(idx)), 'object_difference_wave')
%     
    
    object_pearsson_difference_wave = object_rdm_standard_all - object_rdm_bulls_all;
    save(sprintf('%sobject_decodingAcc_bulls_all_%s', out_path, methods_flag(idx)), 'object_rdm_bulls_all')
    save(sprintf('%sobject_decodingAcc_standard_all_%s', out_path, methods_flag(idx)), 'object_rdm_standard_all')
    save(sprintf('%sobject_difference_wave_%s', out_path, methods_flag(idx)), 'object_pearsson_difference_wave')
end
end

