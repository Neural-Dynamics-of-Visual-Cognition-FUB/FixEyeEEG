function [] = plot_statistics_rsa(split_half, distance_measure,decoding,n_perm,q_value, method)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';

end

    out_path = sprintf('%sdata/FixEyeEEG/main/results/plots/',BASE);
    methods_flag = ["eeg" "eyetracking"];

%% decoding accuracies 
if strcmp(distance_measure, 'decoding') == 1
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,methods_flag(1)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, methods_flag(1)));
    
    decodingAcc_standard_eeg = eval(sprintf('%s_decodingAcc_standard_all',decoding));
    decodingAcc_bulls_eeg = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_standard_all_%s.mat',BASE, decoding,decoding,methods_flag(2)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_bulls_all_%s.mat',BASE, decoding,decoding, methods_flag(2)));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_decodingAcc_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_decodingAcc_bulls_all',decoding));
elseif strcmp(distance_measure, 'pearsson') == 1
 %% 1-pearsson    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_%s.mat',BASE,decoding,decoding,methods_flag(1)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_%s.mat',BASE,decoding, decoding,methods_flag(1)));
    
    decodingAcc_standard_eeg = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eeg = eval(sprintf('%s_rdm_bulls_all',decoding));
    tmp = squeeze(nanmean(decodingAcc_standard_eeg,2));
    tmp = squeeze(nanmean(tmp,2));
    
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_standard_all_%s.mat',BASE,decoding,decoding,methods_flag(2)));
    load(sprintf('%sdata/FixEyeEEG/main/results/%s_pearsson/%s_decodingAcc_bulls_all_%s.mat',BASE,decoding, decoding,methods_flag(2)));
    
    decodingAcc_standard_eyetracking = eval(sprintf('%s_rdm_standard_all',decoding));
    decodingAcc_bulls_eyetracking = eval(sprintf('%s_rdm_bulls_all',decoding));    
      tmp = squeeze(nanmean(decodingAcc_standard_eyetracking,2));
    tmp = squeeze(nanmean(tmp,2));
end  
    decodingAcc_standard_1 = decodingAcc_standard_eeg;
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking;
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg;
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking;

if split_half == 1 
    if strcmp(method, 'eeg')==1
    decodingAcc_standard_1 = decodingAcc_standard_eeg(1:15,:,:,:);
    decodingAcc_standard_2 = decodingAcc_standard_eeg(16:end,:,:,:);
    decodingAcc_bulls_1 = decodingAcc_bulls_eeg(1:15,:,:,:);
    decodingAcc_bulls_2 = decodingAcc_bulls_eeg(16:end,:,:,:);
   % decodingAcc_diff_wave_1 = decodingAcc_diff_wave_eeg(1:15,:,:,:);
   % decodingAcc_diff_wave_2 = decodingAcc_diff_wave_eeg(16:end,:,:,:);
    elseif strcmp(method, 'eyetracking')==1
    decodingAcc_standard_1 = decodingAcc_standard_eyetracking(1:15,:,:,:);
    decodingAcc_standard_2 = decodingAcc_standard_eyetracking(16:end,:,:,:);
    decodingAcc_bulls_1 = decodingAcc_bulls_eyetracking(1:15,:,:,:);
    decodingAcc_bulls_2 = decodingAcc_bulls_eyetracking(16:end,:,:,:);
   % decodingAcc_diff_wave_1 = decodingAcc_diff_wave_eyetracking(1:15,:,:,:);
   % decodingAcc_diff_wave_2 = decodingAcc_diff_wave_eyetracking(16:end,:,:,:);
    end 
else
        method = 'eeg and eyetracking';
end 
[SignificantVariables_category_standard,~,adjusted_pvalues_standard, true_rsa_rdm_standard] = fdr_corrected_perm_test_rsa(decodingAcc_standard_1,decodingAcc_standard_2, n_perm,'right', q_value);
[SignificantVariables_category_bulls,~,adjusted_pvalues_bulls, true_rsa_rdm_bulls] = fdr_corrected_perm_test_rsa(decodingAcc_bulls_1,decodingAcc_bulls_2,n_perm,'right', q_value);
%[SignificantVariables_category_diff_wave,~,adjusted_pvalues_diff_wave, true_rsa_diff_wave] = fdr_corrected_perm_test_rsa(decodingAcc_diff_wave_1,decodingAcc_diff_wave_2, n_perm,'right', q_value);

significant_time_points_standard = find(SignificantVariables_category_standard>0);
y_significants_standard = repmat(-0.4, size(significant_time_points_standard,2),1)';

significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
y_significants_bulls = repmat(-0.5, size(significant_time_points_bulls,2),1)';

%significant_time_points_diff_wave = find(SignificantVariables_category_diff_wave>0);
%y_significants_diff_wave = repmat(70, size(significant_time_points_diff_wave,2),1)';
 x = 1:numel(true_rsa_rdm_standard);
    x2 = [x, fliplr(x)];
    c2 = [146/255 0/255 0/255];
    c1 = [0/255 146/255 146/255];
    
    SEM_standard = std(true_rsa_rdm_standard)/sqrt(size(true_rsa_rdm_standard,1));
    SEM_bulls = std(true_rsa_rdm_bulls)/sqrt(size(true_rsa_rdm_bulls,1));
    
figure
    upper = true_rsa_rdm_standard + SEM_standard;
    lower = true_rsa_rdm_standard - SEM_standard;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c1, 'FaceAlpha', 0.2);
    hold on;
    upper = true_rsa_rdm_bulls + SEM_bulls;
    lower = true_rsa_rdm_bulls - SEM_bulls;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c2, 'FaceAlpha', 0.2);
    hold on;
    plot(true_rsa_rdm_standard,'Color',c1)
    hold on
    plot(significant_time_points_standard, y_significants_standard,'*','Color',c1)
    hold on
    plot(true_rsa_rdm_bulls,'Color',c2)
    hold on
    plot(significant_time_points_bulls, y_significants_bulls,'*', 'Color',c2)
    title(sprintf("RSA %s %s %s", distance_measure,decoding, method))
    xlabel('time')
    ylabel('correlation')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(0);
    xline(40);
    saveas(gca,sprintf( '%sRSA_%s_%s_%s_statistics.png',out_path, distance_measure,decoding, method));
end


