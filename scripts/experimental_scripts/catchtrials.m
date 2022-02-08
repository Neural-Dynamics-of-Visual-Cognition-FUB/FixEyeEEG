function[block,cond,dat] = randomize_conditions(cfg)
%randomize the conditions (fixcross or bullseye)
tmp = repmat([1:2],1,cfg.blocks/2);
ind = randperm(length(tmp));
order_blocks = (tmp(ind))';

cond = repelem(order_blocks',1,cfg.trial)'; %standard(2) or bullseye(1)

% define blocks
block = repelem(1:cfg.blocks, 1, cfg.trial); %number of blocks and trials

% randomize stimuli, add catch trial every 4-5 trials
% there are 30 catch trials in each block, but no catch trials in the last
% ~15 trials

stim = NaN(150,10);
for k = 1:10
    stop = 0;
    s = repelem(1:cfg.stimuli,2);
    s = Shuffle(s)';
    for i = 1:30
    stop = stop + randi([4,5]);
    s = [s(1:stop); 0; s(stop+1:end)];
    end
    stim(:,k) = s;
end

dat = reshape(stim,1,cfg.alltrials);
end
