function [outputArg1,outputArg2] = noise_ceiling(fixcross, method)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end
n_subs = 30;
timepoints =240;
out_path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/cluster_based_perm/rsa/',BASE);
if ~isfolder(out_path_results)
    mkdir(out_path_results);
end
decoding = 'object';
load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_%s_all_%s.mat',BASE,decoding,decoding, fixcross,method));

object_pearsson = eval(sprintf('%s_rdm_%s_all',decoding,fixcross));


%average over all but one subject to calculate upper and lower bounds 
for subj = 1:n_subs
    RDM_all_subj = squeeze(nanmean(object_pearsson,1));
    RDM_left_out_subject = squeeze(object_pearsson(subj,:,:,:));
    RDM_other_subjects = squeeze(nanmean(object_pearsson(1:end~=subj,:,:,:),1));
    
    RDM_all_subj(isnan(RDM_all_subj)) = 0;
    rdm_flattened_all_subj_cell = arrayfun(@(x) squareform(RDM_all_subj(:,:,x)+(RDM_all_subj(:,:,x))'),...
                1:timepoints,'UniformOutput',false);
    RDM_all_subjects_flattened = reshape(cell2mat(rdm_flattened_all_subj_cell),[],timepoints);
    
    RDM_left_out_subject(isnan(RDM_left_out_subject)) = 0;
    rdm_flattened_left_out_subjects_cell = arrayfun(@(x) squareform(RDM_left_out_subject(:,:,x)+(RDM_left_out_subject(:,:,x))'),...
                1:timepoints,'UniformOutput',false);
    RDM_left_out_subject_flattend = reshape(cell2mat(rdm_flattened_left_out_subjects_cell),[],timepoints);
    
    RDM_other_subjects(isnan(RDM_other_subjects)) = 0;
    rdm_flattened_other_subjects_cell = arrayfun(@(x) squareform(RDM_other_subjects(:,:,x)+(RDM_other_subjects(:,:,x))'),...
                1:timepoints,'UniformOutput',false);
    RDM_other_subjects_flattened= reshape(cell2mat(rdm_flattened_other_subjects_cell),[],timepoints); 
    
    
    for time = 1:timepoints
    lower_bound(subj,time) = corr(RDM_left_out_subject_flattend(:,time),RDM_other_subjects_flattened(:,time),'type','Spearman');
    upper_bound(subj,time) = corr(RDM_left_out_subject_flattend(:,time),RDM_all_subjects_flattened(:,time),'type','Spearman');
    end 
end

    noise_ceiling_lower_bound = mean(lower_bound,1);
    noise_ceiling_upper_bound = mean(upper_bound,1);

    save(sprintf('%snoise_ceiling_%s_%s.mat',out_path_results, method, fixcross),'noise_ceiling_lower_bound','noise_ceiling_upper_bound');

end

