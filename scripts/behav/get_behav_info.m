function [outputArg1,outputArg2] = get_behav_info()
if ismac
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/decoding');
    addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/decoding/MEG_SVM_decoding_MVNN/');
    addpath('/Users/ghaeberle/Documents/MATLAB/libsvm/matlab');
    addpath('/Users/ghaeberle/Documents/MATLAB/fieldtrip-20210928/')
    ft_defaults
    BASE = '/Users/ghaeberle/scratch/';
elseif isunix
    addpath('/home/haebeg19/FixEyeEEG/scripts/decoding');
    addpath('/home/haebeg19/FixEyeEEG/scripts/decoding/MEG_SVM_decoding_MVNN/');
    addpath('/home/haebeg19/toolbox/libsvm/matlab');
    addpath('/home/haebeg19/toolbox/fieldtrip/')
    BASE = '/scratch/haebeg19/';
    ft_defaults
end

n_subs = 30;
subs = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];

    for subj = 1:n_subs
        load(sprintf('%sdata/FixEyeEEG/main/behav_data/FixCrossExp_s%scfgdata',BASE,num2str(subs(subj))));
        age(subj) = data.age;
        gender(subj) = data.gender;
    end
    mean(age)
    std(age)
    count(gender, 'f')
    count(gender, 'm')
    count(gender, 'd')
    
end

