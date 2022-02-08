clear all
%% randomize catch trials and stimuli
% for the distribution of catch trials I choose [4,7] interval, because we
% need:

% to have 30 catch trials in each 150 trials, 
% to have the catch trials properly distributed until the end of the block, 
% not to make participants fixate for too long.
%% 

% a vector containing numbers between 4-7 should have a length of exactly
% 30, and its sum should not exceed 150. 

% this loop chooses random number sets in which the sum of the set is 
% smaller than 150.

% i do 10^6 iterations hoping that the sum of at least 10 of the sets will 
% be smaller than 150.
% i want 4 numbers to be randomly distributed in a vector which has a length
% of 30. In principle there will be 4^30 different combinations in which these 
% numbers can be distributed. To make %100 sure, that my 10 sets in which 
% the sum is smaller than 150 are there, i should do 4^30 iterations, but 
% the program doesn't let it. The chances shouldn't be bad with 10^6 iterations, 
% and when it does not work(if it happens), I can just re-run the script.
% This is done before the beginning of the experiment, so it won't harm anything. 

ran = NaN(30,10^6); % a matrix to place random number sets

for i = 1:10^6
    r = randi([4,7],30,1);
    if sum(r) < 150
       ran(:,i) = r;
    else
        continue
    end
end

% i need 10 sets for 10 blocks, so i randomly extract 10 columns 

% first get rid of NaN columns
no_nan = find(~isnan(ran(1,:)));
ran = ran(:,no_nan);

% randomly choose 10 sets
x = randperm(size(ran,2),10);
ran = ran(:,x);

% place catch trials and stimuli

stim = NaN(150,10); %stimuli and catch trials will be placed here.
nocatch = NaN();

for k = 1:10 
    stop = 0;
    for i = 1:30 %catch trials are placed in this loop
        stop = stop+ran(i,k);
        stim(stop, k)=0;
    end
    nocatch = find(stim(:,k)~=0);
    s = repelem(1:60,2);
    s = Shuffle(s)';
    stim(nocatch, k) = s; %stimuli is placed here
end

dat = reshape(stim,1,1500);
