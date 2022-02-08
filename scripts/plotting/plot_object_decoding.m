function [] = plot_object_decoding(inputArg1,inputArg2)
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/EEG/stdshade/');
out_path = '/Users/ghaeberle/scratch/data/FixEyeEEG/main/results/plots/';
methods_flag = ["eeg" "eyetracking"];
n_subs = 30;
n_objects = 40;
n_timepoints = 240;
for idx = 1:2
decodingAcc_bulls_all = NaN(n_subs,n_objects,n_objects,n_timepoints);
decodingAcc_standard_all = NaN(n_subs,n_objects,n_objects,n_timepoints);

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
    decodingAcc_bulls_all(subj,:,:,:) =  decodingAccuracy_object_bulls_avg;
    
    load(sprintf("%s/objects_standard_decodingAccuracy.mat", results_dir));
    decodingAcc_standard_all(subj,:,:,:) =  decodingAccuracy_object_standard_avg;
  
    end
    figure
    for idx_sub=1:27
        plot(decodingAcc_standard_all(idx,:))
        hold on
    end 
    
    figure
    for idx_sub=1:27
        plot(decodingAcc_bulls_all(idx,:))
        hold on
    end 
    
    decodingAccuracy_standard_avg_sub = squeeze(nanmean(nanmean(decodingAcc_standard_all,2),3));
    decodingAccuracy_bulls_avg_sub = squeeze(nanmean(nanmean(decodingAcc_bulls_all,2),3));
    
    
    difference_wave = decodingAcc_standard_all-decodingAcc_bulls_all+ 50;
    difference_wave_avg_sub = squeeze(nanmean(nanmean(difference_wave,2),3));

    figure
    stdshade(decodingAccuracy_standard_avg_sub, 0.2, 'blue')
    hold on 
    stdshade(decodingAccuracy_bulls_avg_sub, 0.2)
    hold on 
    stdshade(difference_wave_avg_sub, 0.2, 'green')
    title(sprintf("object decoding accuracy %s", methods_flag(idx)))
    legend('show')
    xlabel('time')
    ylabel('accuracy')
    xticks([0 40 80 120 160 200 240])
    set(gca, 'XTickLabel', [-200 0 200 400 600 800 1000])
    yline(50);
    xline(40);
   %ylim([40, 100])    
    saveas(gca,sprintf( '%sobject_decoding_%s.png',out_path, methods_flag(idx)));
end

