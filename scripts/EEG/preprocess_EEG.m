function [] = preprocess_EEG(subj)
%{
    - preprocessing of EEG data for one subject
    - Online filtered between: 0.03-100 Hz
    - Resampling to 200Hz
    - Epoching between -200 and 1000ms
    - Baseline correction using 200 ms pre-stimulus
    - Removal of channels and trials with excessive noise
    - interpolation of missing channels
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


filepath_clean_data = sprintf('%sdata/FixEyeEEG/main/eeg/preprocessed/%s/', BASE, subj);
filepath_raw_EEGdata = [sprintf('%sdata/FixEyeEEG/main/eeg/raw/%s/fixeye00%s', BASE, num2str(subj), num2str(subj)) '.eeg'];
filepath_behav_data = sprintf('%sdata/FixEyeEEG/main/behav_data/FixCrossExp_s%scfgdata.mat', BASE, subj);

if ~isfolder(filepath_clean_data)
    mkdir(filepath_clean_data);
end

eyetracking_removed = readmatrix(sprintf('%sdata/FixEyeEEG/main/eyetracking/preprocessed/cleaned/deleted_trial_numbers_sub00%s.csv', BASE,subj), 'Range', 'B2');

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
% only extracat the triggers we are actually interested in
cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue='S 99';
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
cfg.bsfilter = 'yes';
cfg.bsfreq = [49 51];
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
idx_trials_removed = NaN(size(eyetracking_removed,1),1);
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
cfg.layout='acticap-64ch-standard2.mat';
ft_layoutplot(cfg);
data_rej_channel=ft_rejectvisual(cfg,data_all_trials_cleaned);
subjectinfo.reject_channel =setdiff(data_all_trials_cleaned.label,data_rej_channel.label);

for idx = 1:size(data_all_trials_cleaned.trialinfo,1)
    trials_uncleaned{idx,1} = data_all_trials_cleaned.trialinfo{idx,2};
end

for idx = 1:size(data_rej_channel.trialinfo,1)
    trials_cleaned{idx,1} = data_rej_channel.trialinfo{idx,2};
end

rejected_trials = cellfun(@str2num,setdiff(trials_uncleaned, trials_cleaned));
subjectinfo.reject_trials = rejected_trials;
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

cfg=[];
cfg.viewmode = 'vertical';
cfg = ft_databrowser(cfg,data_rej_channel_interpolated_noICA);

% transform to timelocked data
cfg.keeptrials='yes';
data_rej_channel_interpolated_timelocked=ft_timelockanalysis(cfg,data_rej_channel_interpolated_noICA);

% save without ICA
save([filepath_clean_data 'preprocessed_rejected_channels.mat'], 'data_rej_channel');
save([filepath_clean_data 'preprocessed_noICA.mat'], 'data_rej_channel_interpolated_noICA');
save([filepath_clean_data 'preprocessed_noICA_timelocked.mat'], 'data_rej_channel_interpolated_timelocked');
save(sprintf('%sdata/FixEyeEEG/main/behav_data/subject%s_meta_info.mat', BASE, subj), 'subjectinfo');


end

