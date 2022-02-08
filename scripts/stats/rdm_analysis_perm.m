function [rdm_rsa,rdm_flattened_eeg,rdm_flattened_eyetracking] = rdm_analysis_perm(rdm_eeg,rdm_eyetracking)
if find(isnan(rdm_eeg)) >0 %full matrix version
    numTimepoints_eeg = size(rdm_eeg,3);
    rdm_eeg(isnan(rdm_eeg)) = 0;
    rdm_flattened_cell_eeg = arrayfun(@(x) squareform(rdm_eeg(:,:,x)+(rdm_eeg(:,:,x))'),...
                1:numTimepoints_eeg,'UniformOutput',false);
    rdm_flattened_eeg = reshape(cell2mat(rdm_flattened_cell_eeg),[],numTimepoints_eeg);
else
    numTimepoints_eeg = size(rdm_eeg,2);
    rdm_flattened_eeg = rdm_eeg;
end

if find(isnan(rdm_eyetracking)) >0 %full matrix version
    numTimepoints_eeg = size(rdm_eyetracking,3);
    rdm_eyetracking(isnan(rdm_eyetracking)) = 0;
    rdm_flattened_cell_eyetracking = arrayfun(@(x) squareform(rdm_eyetracking(:,:,x)+(rdm_eyetracking(:,:,x))'),...
                1:numTimepoints_rdm_eyetracking,'UniformOutput',false);
    rdm_flattened_eyetracking = reshape(cell2mat(rdm_flattened_cell_eyetracking),[],numTimepoints_eyetracking);
else
    numTimepoints_eeg = size(rdm_eeg,2);
    rdm_flattened_eyetracking = rdm_eeg;
end

%% Perfom RSA at each EEG timepoint
rdm_rsa = NaN(1,numTimepoints_eeg);
for tp = 1:numTimepoints_eeg
    rdm_rsa(tp) = corr(rdm_flattened_eeg(:,tp),rdm_flattened_eyetracking(:,tp),'type','Spearman');
end
end

