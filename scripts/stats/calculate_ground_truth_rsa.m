function [true_rsa_rdm] = calculate_ground_truth_rsa(rsa1,rsa2, subs)
%EEG 
n_subs = subs;
true_rsa_rdm = NaN(n_subs,240);
for subj = 1:n_subs
    single_subject_RDM1 = squeeze(rsa1(subj,:,:,:));
if find(isnan(single_subject_RDM1)) >0 %full matrix version
   numTimepoints_RDM1 = size(single_subject_RDM1,3);
    single_subject_RDM1(isnan(single_subject_RDM1)) = 0;
    rdm_flattened_cell_RDM1 = arrayfun(@(x) squareform(single_subject_RDM1(:,:,x)+(single_subject_RDM1(:,:,x))'),...
                1:numTimepoints_RDM1,'UniformOutput',false);
    rdm_flattened_RDM1 = reshape(cell2mat(rdm_flattened_cell_RDM1),[],numTimepoints_RDM1);
else
    numTimepoints_RDM1 = size(single_subject_RDM1,2);
    rdm_flattened_RDM1 = single_subject_RDM1;
end

%eyetracking
single_subject_RDM2 = squeeze(rsa2(subj,:,:,:));
if find(isnan(single_subject_RDM2)) >0 %full matrix version
   numTimepoints_eyetracking = size(single_subject_RDM2,3);
    single_subject_RDM2(isnan(single_subject_RDM2)) = 0;
    rdm_flattened_cell_RDM2 = arrayfun(@(x) squareform(single_subject_RDM2(:,:,x)+(single_subject_RDM2(:,:,x))'),...
                1:numTimepoints_eyetracking,'UniformOutput',false);
    rdm_flattened_RDM2 = reshape(cell2mat(rdm_flattened_cell_RDM2),[],numTimepoints_eyetracking);
else
    rdm_flattened_RDM2 = single_subject_RDM2;
end

%% Perfom RSA at each EEG timepoint
for time = 1:numTimepoints_RDM1
    true_rsa_rdm(subj,time) = corr(rdm_flattened_RDM1(:,time),rdm_flattened_RDM2(:,time),'type','Spearman');
end
end 
end

