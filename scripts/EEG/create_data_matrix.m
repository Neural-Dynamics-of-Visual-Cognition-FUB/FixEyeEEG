function [data] = create_data_matrix(num_conditions, min_number_of_trials, data_timelock, objA, objB)
    
   
        % preallocate data matrix 
        % NxMxExTP matrix containing EEG data, where N is the
        %   number of conditioins, M is the number of trials, E is the number of
        %   electrodes and TP is the number of timepoints.
        data = zeros(num_conditions, min_number_of_trials, size(data_timelock.label,1), size(data_timelock.time,2));
        data(1,:,:,:) = 1;
        data(2,:,:,:) = 0;

        individual_objects = unique(data_timelock.trialinfo(:,4));

        cfg = [];
        cfg.trials = find(data_timelock.trialinfo(:,4)==individual_objects(objA));
        data_objA = ft_selectdata(cfg, data_timelock);
        
        cfg = [];
        cfg.trials = find(data_timelock.trialinfo(:,4)==individual_objects(objB));
        data_objB = ft_selectdata(cfg, data_timelock);
        
        data(1,:,:,:) = datasample(data_objA.trial,min_number_of_trials, 'Replace', false);
        data(2,:,:,:) = datasample(data_objB.trial,min_number_of_trials, 'Replace', false);

end

