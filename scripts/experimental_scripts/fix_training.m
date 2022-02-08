%{
Fixation training after: 
Guzman-Martinez, E., Leung, P., Franceroni, S., Grabowecky, M., & Suzuki, S. (2009).
Rapid eye-fixation training without eye tracking. Psychonomic Bulletin & Review, 16(3).
%}

clc  
clear  
close all  
%closes all windows  
sca 

% add psychtoolbox to path 
% change to your psychtoolbox path
addpath('/Users/greta/Applications/Psychtoolbox/')


rng('shuffle') % sets random numbers to be truly random 
KbName('UnifyKeyNames');

% set these parameters to the ones necessary for your experiment
cfg.dia_pattern = 10  ;% diameter of pattern in dva 
cfg.nInt = 60; % number of intervals    
cfg.length_nInt = 5; % length of the different intervals in seconds 
cfg.dotDiaDeg = 1;% Dot diameter in degree
% index of to be used screen
screen_ind = 0;
cfg.width = 54; % width of screen in cm
cfg.dist = 60; %distance from screen in cm
% define black and white 
cfg.white = WhiteIndex(screen_ind);
cfg.black = BlackIndex(screen_ind);

% THE TIMING DOES NOT WORK PROPERLY ON OSX - seems to be fine on windows 
%Screen('Preference', 'SkipSyncTests', 1);
% get screen properties in pixels
w=Screen('Resolution', screen_ind);
% for mac retina displays screen properties of the actual window are different than
% the values created fom Screen('Resolution')
% to fix this we divide the resolution from the actual screen by 2 
% (this is NOT necessary for non retina non mac displays)
cfg.screensize = [w.width w.height];
cfg.ppd = pi * cfg.screensize(1)/atan(cfg.width/cfg.dist/2)/360;    % pixels per degree
cfg.dia_pattern_pixel = cfg.dia_pattern*cfg.ppd;
cfg.waitframes = 1; % how many frames do we wait before the flip is applied 
%% open the screen 
[window, windowRect] = Screen('OpenWindow', screen_ind, cfg.black);
[screenXpix, screenYpix] = Screen('WindowSize', window);
% get flipinterval for the respective screen 
cfg.ifi = Screen('GetFlipInterval', window);
% calculate how many frames are needed for the whole run and per break
% get center coordinates of screen 
length_exp = cfg.nInt * cfg.length_nInt;
cfg.nFrames = length_exp/cfg.ifi;
cfg.framesInt = cfg.length_nInt/cfg.ifi;
[xCenter, yCenter] = RectCenter(windowRect);
% Retrieve maximum priority number
topPriorityLevel = MaxPriority(window);
% set priority level to maximum 
Priority(topPriorityLevel);

%% define positions for each dot 

 rmax = cfg.dia_pattern_pixel;
 
% get position of all pixels inside square 
% the pixel we need are (x-xCenter)^2 + (y-yCenter)^2 <= r^2
idx = 1;
for xCoord = 1:cfg.screensize(1)
    for yCoord = 1:cfg.screensize(2)
        dx = xCoord - xCenter;
        dy = yCoord - yCenter;
        distanceSquared = dx * dx + dy * dy;
        
        if distanceSquared <= rmax^2
            cfg.dotPositionMatrix(1,idx) = xCoord;
            cfg.dotPositionMatrix(2,idx) = yCoord;
            idx = idx+1; 
        end
    end
end


% randomly assign color for each pixel (either black or white!)
if mod(length(cfg.dotPositionMatrix),2) == 0
    cfg.colorVec = [repmat([cfg.black, cfg.white], 1, length(cfg.dotPositionMatrix)/2); ...
        repmat([cfg.black, cfg.white], 1, length(cfg.dotPositionMatrix)/2); ...
        repmat([cfg.black, cfg.white], 1, length(cfg.dotPositionMatrix)/2)];
else
    cfg.colorVec = [repmat([cfg.black, cfg.white], 1, floor(length(cfg.dotPositionMatrix)/2)),cfg.black; ...
    repmat([cfg.black, cfg.white], 1, floor(length(cfg.dotPositionMatrix)/2)), cfg.black; ...
    repmat([cfg.black, cfg.white], 1, floor(length(cfg.dotPositionMatrix)/2)),cfg.black];
end
cfg.colorVec = cfg.colorVec(:, randperm(size(cfg.colorVec,2)));

% define color matrix where the color for each pixel is switched (black becomes white and white black )
ind_white = find(cfg.colorVec == 0); 
ind_black = find(cfg.colorVec == 255);

cfg.colorVec_opposite = cfg.colorVec;
cfg.colorVec_opposite(ind_white) = 255;
cfg.colorVec_opposite(ind_black) = 0;

%% run animation
vbl = Screen('Flip', window); 
for frames = 1:floor(cfg.nFrames)   
    [~,~, keyCode] = KbCheck;
    thisResp=KbName(keyCode);
    if strcmp(thisResp,'ESCAPE') % Escape key
            Screen('CloseAll')
             ListenChar(0);  
            sca
    end
    if mod(frames, floor(cfg.framesInt)) == 0
        text = 'This is a pause. Press any button if you want to continue. \n Take as long as you need.';
        DrawFormattedText(window,text,'center','center',cfg.white    );
        Screen('Flip',window);
        [~ ,keyCode] = KbWait;
        thisResp=KbName(keyCode);
        if strcmp(thisResp,'ESCAPE') % Escape key
            Screen('CloseAll')
             ListenChar(0);  
            sca
        end
    end
    if mod(frames,2) == 0 
        Screen('DrawDots', window,cfg.dotPositionMatrix , [],...
        cfg.colorVec,[0 0], 0);
        fixcross_least_em(window, windowRect, screen_ind, cfg.width, cfg.dist);
        % Tell PTB no more drawing commands will be issued until the next flip
        Screen('DrawingFinished', window);
        vbl =Screen('Flip', window, vbl + (cfg.waitframes - 0.5) * cfg.ifi);
    else
        Screen('DrawDots', window,cfg.dotPositionMatrix , [],...
        cfg.colorVec_opposite,[0 0], 0);
        fixcross_least_em(window, windowRect, screen_ind, cfg.width, cfg.dist);
        % Tell PTB no more drawing commands will be issued until the next flip
        Screen('DrawingFinished', window);  
        vbl = Screen('Flip', window,vbl + (cfg.waitframes - 0.5) * cfg.ifi);
    end
end

text = 'This is the end of the fixation training. \n Thank you for participating';
DrawFormattedText(window,text,'center','center',cfg.white    );
        Screen('Flip',window);

WaitSecs(10);

sca;