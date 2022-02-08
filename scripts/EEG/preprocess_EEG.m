function [] = preprocess_EEG(subj, ICA)
    %{ 

    - preprocessing of EEG data for one subject 
    - Online filter: 0.03-100 Hz
    - Resampling to 200Hz 
    - Epoching between -200 and 1000ms 
    - Baseline correction using 200 ms pre-stimulus
    - Removal of channels with excessive noise (Fp1, Fp2) 
    - if FLAG_ICA == TRUE 
                ICA to remove blinks, horizontal eye-movements, ECG, movement 
    - Multivariate Noise Normalisation  

    %}

    %% set up prereqs
    if ismac
        addpath('/Users/ghaeberle/Documents/MATLAB/fieldtrip-20210928/')
        ft_defaults
        BASE = '/Users/ghaeberle/scratch/';
    elseif isunix
        addpath('/home/haebeg19/toolbox/fieldtrip/')
        BASE = '/scratch/haebeg19/';
        ft_defaults
    end
    

    filepath_clean_data_noICA = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/noICA/', BASE, subj);
    filepath_clean_data_ICA = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/ICA/',BASE,subj);
    filepath_raw_EEGdata = [sprintf('%sdata/FixEyeEEG/main/eeg/raw/%s/fixeye000%s', BASE, num2str(subj), num2str(subj)) '.eeg'];
    filepath_behav_data = sprintf('%sdata/FixEyeEEG/main/behav_data/FixCrossExp_s%scfgdata.mat', BASE, subj); 
    
    if ICA == 0
        if ~isfolder(filepath_clean_data_noICA)
        mkdir(filepath_clean_data_noICA);
        end

        eyetracking_removed = readmatrix(sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/cleaned/deleted_trial_numbers_sub00%s.csv', BASE,subj), 'Range', 'B2');



        % read in EEG data 
        %filepath_raw_EEGdata = ['/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/tmp/fix_new0' num2str(subj) '.eeg'];
        %filepath_behav_data = ['/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/tmp/FixCrossExp_s' num2str(subj) 'cfgdata.mat']; 

        %load behavioral data 
        behav_dat = load(filepath_behav_data);

        %create path for subject infos
        subjectinfo.reject_channel    = [];
        subjectinfo.reject_comp       = [];
        subjectinfo.reject_trials     = [];
        subjectinfo.lost_conditions   = [];

        %% preprocessing EEG data without ICA 

        cfg=[];
        cfg.dataset = filepath_raw_EEGdata;

        %% epoching 
        cfg.trialdef.eventtype='Stimulus';
        cfg.trialdef.prestim=0.2;
        cfg.trialdef.poststim=1;
        cfg=ft_definetrial(cfg);
        data = ft_preprocessing(cfg);

        %% add additional trialinfos to data 
        % category information
        % add trial,category and condition information and exemplar information to eeg data 
        exemplar = string(behav_dat.data.category)';
        data.trialinfo;
        data.trialinfo = [data.trialinfo (1:4200)' behav_dat.data.catlabel' exemplar behav_dat.data.cond'];
        size(data.trialinfo)
        size((1:3000)')
        size(exemplar)
        size(behav_dat.data.cond')
        %% baseline & filter 
        cfg = []; 
        cfg.hpfilter='no';
        cfg.lpfilter='no';
        cfg.bsfilter='no';
        cfg.demean = 'yes';
        cfg.baselinewindow = [-0.2 0];
        data_baseline=ft_preprocessing(cfg, data);

        %% resampling 
        cfg=[];
        cfg.resamplefs=200;
        data_res = ft_resampledata(cfg,data_baseline);


        %% remove trials that are not needed 
        % remove target trials 
        cfg = [];
        cfg.trials = find(data_res.trialinfo(:,3)~= '999');
        data_wo_target_trials = ft_selectdata(cfg, data_res);

        % remove trials that got rejected during the eyetracking cleaning
        % read csv without indeces
        %eyetracking_removed = readmatrix('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/tmp/trial_n_to_be_deleted.csv', 'Range', 'B2');
        for idx=1:size(eyetracking_removed,1)
            idx_trials_removed(idx) = find(data_wo_target_trials.trialinfo(:,2)== num2str(eyetracking_removed(idx)));
        end
        tmp = data_wo_target_trials.trialinfo(:,2);
        trials_to_keep = str2double(tmp(setdiff(1:length(tmp), idx_trials_removed)));

        for idx=1:size(trials_to_keep,1)
            idx_trials_to_keep(idx) = find(data_wo_target_trials.trialinfo(:,2)== num2str(trials_to_keep(idx)));
        end

        removed_categories = data_wo_target_trials.trialinfo(idx_trials_removed,:);
        subjectinfo.reject_trials = eyetracking_removed;
        subjectinfo.lost_categories = data_wo_target_trials.trialinfo(idx_trials_removed,:);

        cfg = [];
        cfg.trials = idx_trials_to_keep;
        data_all_trials_cleaned = ft_selectdata(cfg, data_wo_target_trials);

        % reject channels with high variance 
        cfg = [];
        cfg.showlabel='yes';
        cfg.method='summary';
        cfg.layout='easycapM1.lay';
        ft_layoutplot(cfg);
        data_rej_channel=ft_rejectvisual(cfg,data_all_trials_cleaned);
        subjectinfo.reject_channel =setdiff(data_all_trials_cleaned.label,data_rej_channel.label);

        %% interpolate missing channels 
        cfg_neighb        = [];
        cfg_neighb.layout = 'easycapM1.mat';
        cfg_neighb.method = 'template';  
        cfg_neighb.channel = {'all'};
        neighbours        = ft_prepare_neighbours(cfg_neighb);

        cfg = [];
        cfg.missingchannel = subjectinfo.reject_channel;
        % weighted neighbours approach cannot be used, because missing channels are
        % lying next to each other! 
        cfg.method = 'average';
        cfg.layout = 'easycapM1.mat';
        cfg.neighbours    = neighbours; 
        data_rej_channel_interpolated_noICA = ft_channelrepair(cfg, data_rej_channel);

        % transform to timelocked data 
        cfg.keeptrials='yes';
        data_rej_channel_interpolated_timelocked=ft_timelockanalysis(cfg,data_rej_channel_interpolated_noICA);

        % save without ICA
        %mkdir([filepath_clean_data_noICA, 'preprocessed']);
        save([filepath_clean_data_noICA 'preprocessed_rejected_channels.mat'], 'data_rej_channel');
        save([filepath_clean_data_noICA 'preprocessed_noICA.mat'], 'data_rej_channel_interpolated_noICA');
        save([filepath_clean_data_noICA 'preprocessed_noICA_timelocked.mat'], 'data_rej_channel_interpolated_timelocked');
        save([filepath_behav_data 'subject_meta_info'], 'subjectinfo');

    elseif ICA == 1
        if ~isfolder(filepath_clean_data_ICA)
            mkdir(filepath_clean_data_ICA);
        end
        
        load([filepath_clean_data_noICA 'preprocessed_rejected_channels.mat']);
        %% ICA
        cfg        = [];
        cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
        comp = ft_componentanalysis(cfg, data_rej_channel);

        %topoplots of n first components
        figure
        cfg = [];
        cfg.component = 1:length(data_rej_channel.label);       % specify the component(s) that should be plotted
        layout = 'easycap-M1.txt';
        cfg.layout    = layout; % specify the layout file that should be used for plotting
        cfg.comment   = 'no';
        ft_topoplotIC(cfg, comp);

        cfg = [];
        cfg.layout = 'easycap-M1.txt'; % specify the layout file that should be used for plotting
        cfg.viewmode = 'component';
        ft_databrowser(cfg, comp)

        % manually select the to be rejected components and backproject the
        % data
        cfg = [];
        cfg.component = input('Which components do you want to remove? '); % fill in the to be removed component(s)
        cfg.demean='no';
        data_rej_channel_trial_comp =ft_rejectcomponent(cfg, comp, data_rej_channel);
        subjectinfo.reject_comp  = cfg.component;


        %% interpolate missing channels 
        cfg_neighb        = [];
        cfg_neighb.layout = 'easycapM1.mat';
        cfg_neighb.method = 'template';  
        cfg_neighb.channel = {'all'};
        neighbours        = ft_prepare_neighbours(cfg_neighb);

        cfg = [];
        cfg.missingchannel = subjectinfo{1,subj}.reject_channel;
        % weighted neighbours approach cannot be used, because missing channels are
        % lying next to each other! 
        cfg.method = 'average';
        cfg.layout = 'easycapM1.mat';
        cfg.neighbours    = neighbours; 
        data_rej_channel_trial_comp_int = ft_channelrepair(cfg, data_rej_channel_trial_comp);

        cfg.keeptrials='yes';
        data_rej_channel_interpolated_timelocked=ft_timelockanalysis(cfg,data_rej_channel_trial_comp_int);

        save([filepath_clean_data_ICA 'preprocessed_ICA.mat'], 'data_rej_channel_trial_comp_int');
        save([filepath_clean_data_ICA 'preprocessed_ICA_timelocked.mat'], 'data_rej_channel_interpolated_timelocked');
        save([filepath_behav_data 'subject_meta_info'], 'subjectinfo');
    end
end

