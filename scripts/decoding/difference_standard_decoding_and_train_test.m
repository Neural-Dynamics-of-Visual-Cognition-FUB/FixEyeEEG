function [outputArg1,outputArg2] = difference_standard_decoding_and_train_test(decoding,method)
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

%% load train test data 
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_train_test/',BASE,decoding);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/%s_train_test/',BASE,decoding);

load(sprintf('%ssignificantVariables_bulls_standard_%s_%s.mat',path_results, method,decoding));
load(sprintf('%ssignificantVariables_standard_bulls_%s_%s.mat',path_results, method,decoding));

load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_standard_all_%s.mat', BASE,decoding,decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_bulls_all_%s.mat', BASE,decoding,decoding,method));


decodingAcc_bulls_standard = eval(sprintf('%s_decodingAcc_bulls_standard',decoding));
decodingAcc_standard_bulls = eval(sprintf('%s_decodingAcc_standard_bulls',decoding));

if strcmp(decoding, 'object') == 1
    decodingAcc_bulls = squeeze(nanmean(squeeze(nanmean(decodingAcc_bulls_standard,2)),2));
    decodingAcc_standard = squeeze(nanmean(squeeze(nanmean(decodingAcc_standard_bulls,2)),2));
elseif strcmp(decoding, 'category') == 1
    decodingAcc_bulls = decodingAcc_bulls_standard;
    decodingAcc_standard = decodingAcc_standard_bulls;
end

%% load standard decoding 

path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_decoding/',BASE,decoding);
path_plots = sprintf('%sdata/FixEyeEEG/main/results/plots/%s_decoding/',BASE,decoding);

fixcross = {'standard'; 'bulls'; 'diff_wave'};
for idx=1:3
load(sprintf('%ssignificant_variables_%s_%s_%s.mat',path_results, fixcross{idx}, method,decoding));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_%s_all_%s.mat', BASE,decoding,decoding,fixcross{idx},method));
end 
end

