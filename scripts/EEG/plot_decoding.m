function [] = plot_category_decoding()
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/EEG/stdshade/');
methods = ["eeg" "eyetracking"];
for idx = 1:2
decodingAcc_bulls_all = NaN(30,240);
decodingAcc_standard_all = NaN(30,240);
    for subj = 1:30

        %if subj == 2 || subj == 4 || subj == 12 
           % cnt = cnt+1
           % continue; 
       % end
    results_dir = sprintf('/Users/ghaeberle/scratch/data/FixEyeEEG/main/%s/decoding/%s', methods(idx), num2str(subj));
    filename = 'animate_inanimate_category';
    %fileToRead1 = fullfile(results_dir,sprintf('%s_decodingAccuracy_standard.mat',filename));
    
    %if exist(fileToRead1, 'file') == 0
      % File does not exist
      % Skip to bottom of loop and continue with the loop
     %continue;
    %end

    load(fullfile(results_dir,sprintf('%s_decodingAccuracy_standard.mat',filename)),'decodingAccuracy_avg_standard');
    load(fullfile(results_dir,sprintf('%s_decodingAccuracy_bulls.mat',filename)),'decodingAccuracy_avg_bulls');
    load(fullfile(results_dir,sprintf('%s_decodingAccuracy_min_number_trials.mat',filename)),'min_number_of_trials')
    
    decodingAcc_bulls_all(subj,:) =  decodingAccuracy_avg_bulls;
    decodingAcc_standard_all(subj,:) =  decodingAccuracy_avg_standard;
    
    end
    figure
    for idx=1:27
        plot(decodingAcc_standard_all(idx,:))
        hold on
    end 
    
    figure
    for idx=1:27
        plot(decodingAcc_bulls_all(idx,:))
        hold on
    end 
    
    
   stdDM_buls = std(decodingAcc_bulls_all);
   stdM_standard = std(~isnan(decodingAcc_standard_all));
   err = stdDM_buls/sqrt(size(decodingAcc_bulls_all,1));
    

    figure
    stdshade(decodingAcc_bulls_all, 0.2)
    title(sprintf("decodingAccuracy avg bulls s%", methods(idx)))
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
    ylim([40, 100])    
    
    
    figure
    stdshade(decodingAcc_standard_all,0.2, 'blue')
    title(sprintf("decodingAccuracy avg standard %s", methods(idx)))
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
    ylim([40, 100])
    
    figure
    stdshade(decodingAcc_standard_all,0.2, 'blue')
    hold on 
    stdshade(decodingAcc_bulls_all, 0.2)
    title(sprintf("decodingAccuracy avg standard %s", methods(idx)))
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
end
end 


