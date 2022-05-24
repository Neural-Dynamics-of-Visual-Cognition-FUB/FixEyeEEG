function [outputArg1,outputArg2] = plot_statistics_train_test(decoding, n_permutations, q_value)

out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/plots/';
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats/');
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats/stdshade');

methods_flag = ["eeg" "eyetracking"];

if ~isfolder(out_path)
    mkdir(out_path);
end

for idx = 1:2
    
    if strcmp(decoding, 'category')
        load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_standard_all_%s.mat', decoding,decoding,methods_flag(idx)));
        load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_bulls_all_%s.mat', decoding,decoding, methods_flag(idx)));
        
        decodingAcc_standard = category_decodingAcc_bulls_standard;
        decodingAcc_bulls = category_decodingAcc_standard_bulls;
        
    elseif strcmp(decoding, 'object')
        load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_all_%s.mat', decoding,decoding,methods_flag(idx)));
        load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_all_%s.mat', decoding,decoding, methods_flag(idx)));
        load(sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/%s_train_test/%s_difference_wave_%s.mat', decoding,decoding,methods_flag(idx)));
        
        decodingAcc_standard = squeeze(nanmean(nanmean(object_decodingAcc_standard_all,2),3));
        decodingAcc_bulls = squeeze(nanmean(nanmean(object_decodingAcc_bulls_all,2),3));
        decodingAcc_diff_wave = squeeze(nanmean(nanmean(object_difference_wave,2),3));
    end
    
    n_perm=n_permutations;
    q_value = q_value;
    [SignificantVariables_category_standard,~,adjusted_pvalues_standard] = fdr_corrected_perm_test(decodingAcc_standard, n_perm, q_value);
    [SignificantVariables_category_bulls,~,adjusted_pvalues_bulls] = fdr_corrected_perm_test(decodingAcc_bulls, n_perm, q_value);
    
    significant_time_points_standard = find(SignificantVariables_category_standard>0);
    y_significants_standard = repmat(46, size(significant_time_points_standard,2),1)';
    
    significant_time_points_bulls = find(SignificantVariables_category_bulls>0);
    y_significants_bulls = repmat(44, size(significant_time_points_bulls,2),1)';
    
    
    
    x = 1:numel(mean(decodingAcc_standard));
    x2 = [x, fliplr(x)];
    c3 = [73/255 0/255 146/255];
    c2 = [146/255 0/255 0/255];
    c1 = [0/255 146/255 146/255];
    
    SEM_standard = std(decodingAcc_standard)/sqrt(size(decodingAcc_standard,1));
    SEM_bulls = std(decodingAcc_bulls)/sqrt(size(decodingAcc_bulls,1));
    
    figure
    plot(mean(decodingAcc_standard),'Color',c1)
    hold on
    plot(mean(decodingAcc_bulls),'Color',c2)
    hold on
    upper = mean(decodingAcc_standard) + SEM_standard;
    lower = mean(decodingAcc_standard) - SEM_standard;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c1, 'FaceAlpha', 0.2);
    hold on;
    upper = mean(decodingAcc_bulls) + SEM_bulls;
    lower = mean(decodingAcc_bulls) - SEM_bulls;
    inBetween = [upper, fliplr(lower)];
    fill(x2, inBetween, c2, 'FaceAlpha', 0.2);
    hold on;
    
    plot(significant_time_points_standard, y_significants_standard,'*','Color',c1)
    hold on
    
    plot(significant_time_points_bulls, y_significants_bulls,'*', 'Color',c2)
    title(sprintf("%s decoding accuracy train test %s", decoding, methods_flag(idx)))
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
    legend({'standard','bullseye'})
    saveas(gca,sprintf( '%s%s_decoding_train_test_%s_statistics.png',out_path, decoding, methods_flag(idx)));
end
end




