function [SignificantVariables,crit_p,adjusted_pvalues] = fdr_corrected_perm_test(data, n_perm, q_value,tail)
addpath('/Users/ghaeberle/Documents/PhD/project/FixEyeEEG/scripts/stats/fdr_bh/');
   
    if (size(size(data),2)>2)
        data([2 12],:,:,:) = [];   %valid
    else
        data = rmmissing(data);
    end
    
    data = data -50;   
    N = ndims(data);
    nobservations = size(data,1);
    for n = 2:N
        nvariable(n-1) = size(data,n);
    end
    if ~exist('tail') || strcmp(tail,'right') %if two tail t-test
    func = '';
        else %if two-sided t-test
    func = 'abs';
    end
    
    cln = repmat({':'},1,N-1);
    
    %create permutation samples and convert them to pvalues (perms x variable1 x variable2 x ...)
    if ~exist('StatMapPermPV') %if pvalues have not been precomputed     
        StatMapPerm = single(zeros([n_perm nvariable]));

        %first permutation sample is original data
        StatMapPerm(1,cln{:}) = mean(data,1) ./ std(data);    

        %perform permutations for n-1 permutations as the first permutation
        %is the orginal data 
        for i = 2:n_perm %par
            if ~rem(i,100)
                disp(['Create permutation samples: ' num2str(i) ' out of ' num2str(n_perm)]);
            end
            perm = single(sign(rand(nobservations,1)-0.5));
            data_perm = repmat(perm,1,nvariable(1)) .* data; 
            StatMapPerm(i,cln{:}) = mean(data_perm,1) ./ std(data_perm);         
        end    

        %convert to pvalues
        eval([ 'StatMapPermPV = (n_perm+1 - tiedrank(' func '(StatMapPerm)))/n_perm;' ]);    
    end

    clear StatMapPerm;

    %Perform fdr
    pvalues = squeeze(StatMapPermPV(1,cln{:}));
    [SignificantVariables,crit_p,~,adjusted_pvalues] = fdr_bh(pvalues,q_value,'pdep');

end

