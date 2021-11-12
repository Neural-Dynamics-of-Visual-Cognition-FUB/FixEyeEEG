function [data] = create_data_matrix_MVNN(num_conditions, min_number_of_trials, data_timelock)
    %UNTITLED3 Summary of this function goes here
    %   Detailed explanation goes here

    % preallocate data matrix 
    % NxMxExTP matrix containing EEG data, where N is the
    %   number of conditioins, M is the number of trials, E is the number of
    %   electrodes and TP is the number of timepoints.
    data = zeros(num_conditions, min_number_of_trials, size(data_timelock.label,1), size(data_timelock.time,2));
    data(1,:,:,:) = 1;
    data(2,:,:,:) = 0;
    % animate
    cfg = [];
    cfg.trials = find(data_timelock.trialinfo(:,3)=='1');
    data_animate = ft_selectdata(cfg, data_timelock);
    
    % inanimate
    cfg = [];
    cfg.trials = find(data_timelock.trialinfo(:,3)=='0');
    data_inanimate = ft_selectdata(cfg, data_timelock);
    
    rand_data_animate = datasample(data_animate.trial,min_number_of_trials, 'Replace', false);
    rand_data_inanimate = datasample(data_inanimate.trial,min_number_of_trials, 'Replace', false);
    
    data(1,:,:,:) = rand_data_animate;
    data(2,:,:,:) = rand_data_inanimate;
end

