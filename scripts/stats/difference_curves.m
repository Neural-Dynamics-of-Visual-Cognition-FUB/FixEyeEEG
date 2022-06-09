function [outputArg1,outputArg2] = difference_curves(decoding, method)

if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats');
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/stats');
    BASE = '/scratch/haebeg19/';

end
load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_standard_%s.mat', BASE,decoding, decoding,method));
load(sprintf('%sdata/FixEyeEEG/main/results/%s_time_time/%s_decodingAcc_bulls_%s.mat', BASE,decoding, decoding,method));

diff_curve = decodingAcc_standard_all - decodingAcc_bulls_all;

end

