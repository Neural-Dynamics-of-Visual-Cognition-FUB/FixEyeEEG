function [data] = create_data_matrix_MVNN(num_conditions, min_number_of_trials, data_timelock, decoding, individual_objects)
    
    if strcmp(decoding, 'category') == 1
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
    
        elseif strcmp(decoding, 'object') == 1
                                                         
         % preallocate data matrix 
        % NxMxExTP matrix containing EEG data, where N is the
        %   number of conditioins, M is the number of trials, E is the number of
        %   electrodes and TP is the number of timepoints.
        
        data = zeros(num_conditions, min_number_of_trials, size(data_timelock.label,1), size(data_timelock.time,2));
        for idx =1:num_conditions
            data(idx,:,:,:) = idx;
        end
       % individual_objects = unique(data_timelock.trialinfo(:,4));
        
        for idx = 1:size(individual_objects,1)
            cfg = [];
            cfg.trials = find(data_timelock.trialinfo(:,4)==individual_objects(idx));
            data_objects{idx,1} = ft_selectdata(cfg, data_timelock);
            data(idx,:,:,:) = datasample(data_objects{idx,1}.trial,min_number_of_trials, 'Replace', false);
        end 

    end
end

