function [outputArg1,outputArg2] = difference_standard_decoding_and_train_test(decoding,method)
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';
    
end

%% load train test data 
path_results = sprintf('%sdata/FixEyeEEG/main/results/statistic/%s_difference_train_test_decoding/',BASE,decoding);

if ~isfolder(path_results)
    mkdir(path_results);
end

load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_bulls_standard_all_%s.mat', BASE,decoding,decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_train_test/%s_decodingAcc_standard_bulls_all_%s.mat', BASE,decoding,decoding,method));


decodingAcc_bulls_standard = eval(sprintf('%s_decodingAcc_bulls_standard',decoding));
decodingAcc_standard_bulls = eval(sprintf('%s_decodingAcc_standard_bulls',decoding));


avg_train_test = (decodingAcc_bulls_standard + decodingAcc_standard_bulls)/2;
%% load standard decoding 

fixcross = {'standard'; 'bulls'};
for idx=1:2
load(sprintf('%sdata/FixEyeEEG/main/results/%s_decoding/%s_decodingAcc_%s_all_%s.mat', BASE,decoding,decoding,fixcross{idx},method));
end 

decodingAcc_standard_all = eval(sprintf('%s_decodingAcc_standard_all',decoding));
decodingAcc_bulls_all = eval(sprintf('%s_decodingAcc_bulls_all',decoding));

difference_standard = decodingAcc_standard_all - avg_train_test;
difference_bulls = decodingAcc_bulls_all - avg_train_test;

save(sprintf('%sdifference_train_test_standard_%s.mat',path_results,method),'difference_standard');
save(sprintf('%sdifference_train_test_bulls_%s.mat',path_results,method),'difference_bulls');



end

