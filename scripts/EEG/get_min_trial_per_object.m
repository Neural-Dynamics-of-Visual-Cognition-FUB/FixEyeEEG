function [min_number_of_trials] = get_min_trial_per_object(data)

    individual_objects = unique(data.trialinfo(:,4));
    min_number_of_trials = NaN(size(individual_objects,1),1);
    
    
    for idx = 1:size(individual_objects,1)
        min_number_of_trials(idx) = sum(data.trialinfo(:,4)==individual_objects(idx),'all');
    end

end

