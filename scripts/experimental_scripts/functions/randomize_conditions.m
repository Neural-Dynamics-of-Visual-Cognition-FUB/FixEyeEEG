function[block,cond,dat] = randomize_conditions(cfg)
%randomize the conditions (fixcross or bullseye)
tmp = repmat([1,2],1,cfg.blocks/2);
ind = randperm(length(tmp));
order_blocks = (tmp(ind))';

cond = repelem(order_blocks',1,cfg.trial)'; %standard(2) or bullseye(1)

% define blocks
block = repelem(1:cfg.blocks, 1, cfg.trial); %number of blocks and trials

%% randomize catch trials and stimuli

ran = NaN(cfg.catch_per_block,10^6); % a matrix to place random number sets

for i = 1:10^6
    r = randi([4,7],cfg.catch_per_block,1);
    if sum(r) < cfg.trial
       ran(:,i) = r;
    else
        continue
    end
end

% randomly extract 10 columns 

% first get rid of NaN columns
no_nan = find(~isnan(ran(1,:)));
ran = ran(:,no_nan);

% randomly choose 10 sets
x = randperm(size(ran,2),cfg.blocks);
ran = ran(:,x);

% place catch trials and stimuli

stim = NaN(cfg.trial,cfg.blocks); %stimuli and catch trials will be placed here.
nocatch = NaN();

for k = 1:cfg.blocks 
    stop = 0;
    for i = 1:cfg.catch_per_block %catch trials are placed in this loop
        stop = stop+ran(i,k);
        stim(stop, k)=0;
    end
    nocatch = find(stim(:,k)~=0);
    s = repelem(1:cfg.stimuli,cfg.rep_per_block);
    s = Shuffle(s)';
    stim(nocatch, k) = s; %stimuli is placed here
end
dat = reshape(stim,1,cfg.alltrials);

end
