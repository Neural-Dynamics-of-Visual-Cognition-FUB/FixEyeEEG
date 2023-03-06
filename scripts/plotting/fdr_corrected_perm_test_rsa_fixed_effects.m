function [SignificantVariables,crit_p,adjusted_pvalues, true_rsa_rdm] = fdr_corrected_perm_test_rsa_fixed_effects(eeg,eyetracking, numPermutations, tail, q_value)
if ismac
    BASE = '/Users/ghaeberle/Documents/PhD/project/';
elseif isunix
    BASE = '/home/haebeg19/';

end
addpath(sprintf('%sFixEyeEEG/scripts/stats/fdr_bh/',BASE));
addpath(sprintf('%sFixEyeEEG/scripts/stats/',BASE));

%%%%% CALCULATING THE GROUND TRUTH AND PERMUTATION SAMPLES P-VALUES %%%%%

%% compute true RSA correlation values 
%%%% TODO ADD FOR BULLS AND DIFFERENCE WAVE ALSO 
%%  Reshape the matrices: take only the upper diagonal, in vector form for the averaged subejcts 
    avg_subject_RDM_eeg = squeeze(nanmean(eeg,1));
    avg_subject_RDM_eyetracking = squeeze(nanmean(eyetracking,1));

%% fill up the whole matrix to be able to permute conditino labels 
    avg_subject_RDM_eeg(isnan(avg_subject_RDM_eeg)) = 0;
    avg_subject_RDM_eyetracking(isnan(avg_subject_RDM_eyetracking)) = 0;
    avg_subject_RDM_eeg = avg_subject_RDM_eeg+permute(avg_subject_RDM_eeg,[2 1 3]);
    avg_subject_RDM_eyetracking = avg_subject_RDM_eyetracking+permute(avg_subject_RDM_eyetracking,[2 1 3]);

%%  Reshape the matrices: take only the upper diagonal, in vector form
%EEG 
if find(isnan(avg_subject_RDM_eeg)) >0 %full matrix version
   numTimepoints_eeg = size(avg_subject_RDM_eeg,3);
    avg_subject_RDM_eeg(isnan(avg_subject_RDM_eeg)) = 0;
    rdm_flattened_cell_eeg = arrayfun(@(x) squareform(avg_subject_RDM_eeg(:,:,x)+(avg_subject_RDM_eeg(:,:,x))'),...
                1:numTimepoints_eeg,'UniformOutput',false);
    rdm_flattened_eeg = reshape(cell2mat(rdm_flattened_cell_eeg),[],numTimepoints_eeg);
else
    numTimepoints_eeg = size(avg_subject_RDM_eeg,2);
    rdm_flattened_eeg = avg_subject_RDM_eeg;
end

%eyetracking
if find(isnan(avg_subject_RDM_eyetracking)) >0 %full matrix version
   numTimepoints_eyetracking = size(avg_subject_RDM_eyetracking,3);
    avg_subject_RDM_eyetracking(isnan(avg_subject_RDM_eyetracking)) = 0;
    rdm_flattened_cell_eyetracking = arrayfun(@(x) squareform(avg_subject_RDM_eyetracking(:,:,x)+(avg_subject_RDM_eyetracking(:,:,x))'),...
                1:numTimepoints_eyetracking,'UniformOutput',false);
    rdm_flattened_eyetracking = reshape(cell2mat(rdm_flattened_cell_eyetracking),[],numTimepoints_eyetracking);
else
    numTimepoints_eyetracking = size(avg_subject_RDM_eyetracking,2);
    rdm_flattened_eyetracking = avg_subject_RDM_eyetracking;
end

%% Perfom RSA at each EEG timepoint
true_rsa_rdm = NaN(1,numTimepoints_eeg);
for time = 1:numTimepoints_eeg
    true_rsa_rdm(time) = corr(rdm_flattened_eeg(:,time),rdm_flattened_eyetracking(:,time),'type','Spearman');
end
%%% DO THE ACTUAL PERMUTATION %%%% 
    %% 1)Permute the subject-level RDMs N times and calculate the Spearman's correlation with the other RDM at each timepoint
    numTimepoints = numTimepoints_eeg;
    all_rsa_rdm = NaN(numPermutations,numTimepoints);
    all_rsa_rdm(1,:) = true_rsa_rdm;
    for perm = 2:numPermutations
        if ~mod(perm,100)
            fprintf('Calculating the correlation %d \n',perm);
        end
        %flatten and permute EEG RDM
        avg_subject_RDM_eeg(isnan(avg_subject_RDM_eeg)) = 0;
        rdm_flattened_cell_1 = arrayfun(@(x) squareform(avg_subject_RDM_eeg(:,:,x)+(avg_subject_RDM_eeg(:,:,x))'),...
            1:numTimepoints,'UniformOutput',false);
        rdm_flattened_1 = reshape(cell2mat(rdm_flattened_cell_1),[],numTimepoints);
        permuted_rdm_1 = rdm_flattened_1(randperm(size(rdm_flattened_1,1)),:);
        
        %RSA
        all_rsa_rdm(perm,:) = rdm_analysis_perm(permuted_rdm_1,rdm_flattened_eyetracking); %modify the RSA function
    end
    
    %% 2) Calculate the p-value of the ground truth and of the permuted samples
    if strcmp(tail,'right')
        p_ground_and_samples = (numPermutations+1 - tiedrank(all_rsa_rdm)) / numPermutations;
    else
        error('Wrong tail');
    end
    
    %% 3) Perform FDR correction
    pvalues = squeeze(p_ground_and_samples(1,:,:));
    [SignificantVariables,crit_p,~,adjusted_pvalues] = fdr_bh(pvalues,q_value,'pdep');
end


