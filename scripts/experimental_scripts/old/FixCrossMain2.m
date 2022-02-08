   % Clear the workspace and the screen
close all;
clearvars;
sca;
addpath('functions');

cfg.eye_on =input('Run experiment with Eye-tracker? (0 = no, 1 = yes) ');
cfg.eeg_on = input('Run experiment with EEG? (0 = no, 1 = yes) ');
cfg.session = input('Baseline(0), Notraining(1), Training(2): ');

dummymode=0;       % for eye-tracker-- set to 1 to initialize in dummymode
%% Define presentation variables
textfont = 'Arial';
textsize = 26;
text = 'Thank you for participating in our experiment. \n In the following you will see images from different object categories. \n Your task is to blink and press a button when you see an image of a paperclip.\n Press any button to start.';

cfg.stimuli = 60;
cfg.blocks = 10;
cfg.trial = 150;
cfg.alltrials = 1500;
cfg.distance = 60;
cfg.screensize = 54; 

stim_pres = 0.5;
iti = [400 500];

%% get subject code, age and gender
data.subj_code=input('Enter subject number: ');
data.age=input('Age: ');
data.gender=input('Gender: ', 's');

%% open an onscreen window and color it gray
[window, windowRect, black, white, grey, screenXpixels, screenYpixels, xCenter, yCenter]= open_window();

%%
KbName('UnifyKeyNames');

%fixation cross properties
darkGrey = white/3;
cfg.dot1color = black;
cfg.crossColor = darkGrey;
cfg.pixel = screenXpixels;
cfg.visangx = 5;

%% prepare images (load visual stimuli, adjust sizes)
[images, paperclipTexture, my_images, ppd, pic_size] = prepare_img(cfg,window);

%% get flip interval for accurate timing
frame_rate = FrameRate(window);
flip_interval = Screen('GetFlipInterval',window);

%for stimulus
real_stim = 1000*stim_pres;
stim_frames=real_stim/(1000/frame_rate);
stim_pres=flip_interval*(stim_frames-0.5);

%for iti
times_iti = (randi(iti, cfg.alltrials, 1)/1000);
real_stim=1000*times_iti;
iti_frames=real_stim/(1000/frame_rate);
times_iti=flip_interval*(iti_frames-0.5);

%% randomize the conditions(fixcross or bulls eye)
[block,cond,dat] = randomize_conditions(cfg);

cfg.trial_order(:,1) = block;
cfg.trial_order(:,2) = cond;
cfg.trial_order(:,3) = dat;
cfg.pause = cfg.alltrials/cfg.blocks;


%% initialize eyelink

el=EyelinkInitDefaults(window);

% Initialization of the connection with the Eyelink Gazetracker.
if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end


%edfFile = 'training01.edf'; 

% edf file names cant be more than 8 characters!
if cfg.session == 0
    edfFile = ['base',num2str(data.subj_code),'.edf'];
elseif cfg.session == 1
    edfFile = ['ntrain',num2str(data.subj_code),'.edf'];
elseif cfg.session == 2
    edfFile = ['train',num2str(data.subj_code),'.edf'];
end

Eyelink('OpenFile',edfFile); %open file to write eye tracking data

%% show a few trials before actual experiment
show_trial(window,images,my_images,dat,cfg,paperclipTexture,stim_pres,times_iti,xCenter,yCenter,ppd);


%%
% defines the trigger setup for the lab computers
%if eeg is on
if cfg.eeg_on == 1
    cfg.trigger_delay_time = 0.01367;
    address=hex2dec('3FC8');
    condition=99;
    %addpath('.\iosetup\');
end

eeg_start=GetSecs;

%% do eye tracker calibration
if cfg.eye_on == 1
    EyelinkDoTrackerSetup(el);
    EyelinkDoDriftCorrection(el);
end

%% present instruction
%text size and font
HideCursor;
Screen('TextSize', window, textsize);
Screen('TextFont', window, textfont);
DrawFormattedText(window, text, 'center', 'center', white);
Screen('Flip', window);
KbWait;

%% trial loop
data.cond = NaN(1,cfg.alltrials);
data.block = NaN(1,cfg.alltrials);
data.onset = NaN(1,cfg.alltrials);
data.category = cell(1,cfg.alltrials);
data.response = NaN(1,cfg.alltrials);


for trial = 1:length(cfg.trial_order)
    %mark the start of the trial
    Eyelink('Message', 'TRIALID %d', trial);
    
    %start recording
    Eyelink('StartRecording');
    WaitSecs(0.1);
    
    if cfg.trial_order(trial,2) == 1 %with bulls eye
        if cfg.trial_order(trial,3) ~= 0  %not catch trial
            if trial == 1
                %blank screen with fix cross
                fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
                t0 = Screen('Flip',window);
                WaitSecs(1);
            end
            
            %present stimulus
            my_img = double(images(my_images(dat(trial))).pixel_values)/255; %convert image to double
            imageTexture = Screen('MakeTexture', window, my_img); %make texture for the image
            Screen('DrawTexture', window, imageTexture, [], [], 0); %draw stimulus
            
            %fix cross on stimulus
            fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
            
            time1 = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(times_iti(trial) - 0.0084));
            if press_time - time1 < t0+(times_iti(trial) - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(times_iti(trial) - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            %collect key response
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
                sca
            else
                data.response(trial) = 1;
            end
            
            % mark zero-plot time in data file
            Eyelink('Message', 'STARTTIME');
            
            %send trigger
            if cfg.eeg_on == 1
                WaitSecs(cfg.trigger_delay_time); % Wait Xms before sending the trigger
                send_triggerIO64(address,condition);
            end
            
            %get trial onset
            data.onset(trial)=t0-eeg_start;
            
            
            %blank screen with fix cross
            fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
            
            
            time = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(stim_pres - 0.0084));
            if press_time - time < t0+(stim_pres - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(stim_pres - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            
            data.category{trial} = images(my_images(dat(trial))).category;
            
        elseif cfg.trial_order(trial,3) == 0 %catch trial
            
            %draw paperclip
            Screen('DrawTexture', window, paperclipTexture, [], [], 0);
            
            %fix cross
            fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
            
            
            time1 = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(times_iti(trial) - 0.0084));
            if press_time - time1 < t0+(stim_pres - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(times_iti(trial) - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            Eyelink('Message', 'STARTTIME');
            
            %send trigger
            if cfg.eeg_on == 1
                WaitSecs(cfg.trigger_delay_time); 
                send_triggerIO64(address,condition);
            end
            
            %get trial onset
            data.onset(trial)=t0-eeg_start;
            
            %blank screen with fix cross
            fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
            
            time = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(stim_pres - 0.0084));
            if press_time - time < t0+(times_iti(trial) - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(stim_pres - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            data.category{trial} = 'paperclip';
        end
        data.cond(trial) = cfg.trial_order(trial,2);
        data.block(trial) = cfg.trial_order(trial,1);
        
        %% with standard fix cross
    elseif cfg.trial_order(trial,2) == 2 %with standard cross
        if cfg.trial_order(trial,3) ~= 0  %not catch trial
            
            if trial == 1
                %blank screen with fix cross
                fixcross_normal(window, cfg, xCenter, yCenter, ppd);
                t0 = Screen('Flip',window);
                WaitSecs(1);
            end
            
            %present stimulus
            my_img = double(images(my_images(dat(trial))).pixel_values)/255; %convert image to double
            imageTexture = Screen('MakeTexture', window, my_img); %make texture for the image
            Screen('DrawTexture', window, imageTexture, [], [], 0); %draw stimulus
            
            %fix cross on stimulus
            fixcross_normal(window, cfg, xCenter, yCenter, ppd);
            
            time1 = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(times_iti(trial) - 0.0084));
            if press_time - time1 < t0+(stim_pres - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(times_iti(trial) - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            Eyelink('Message', 'STARTTIME');
            
            %send trigger
            if cfg.eeg_on == 1
                WaitSecs(cfg.trigger_delay_time); 
                send_triggerIO64(address,condition);
            end
            
            %get data onset
            data.onset(trial)=t0-eeg_start;
            
            %blank screen with fix cross
            fixcross_normal(window, cfg, xCenter, yCenter, ppd)
            
            time = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(stim_pres - 0.0084));
            if press_time - time < t0+(stim_pres - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(stim_pres - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            data.category{trial} = images(my_images(dat(trial))).category;
            
        elseif cfg.trial_order(trial,3) == 0 %catch trial
            
            
            %draw paperclip
            Screen('DrawTexture', window, paperclipTexture, [], [], 0);
            
            %fix cross
            fixcross_normal(window, cfg, xCenter, yCenter, ppd);
            
            
            time1 = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(times_iti(trial) - 0.0084));
            if press_time - time1 < t0+(stim_pres - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(times_iti(trial) - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            Eyelink('Message', 'STARTTIME');
            
            %send trigger
            if cfg.eeg_on == 1
                WaitSecs(cfg.trigger_delay_time); 
                send_triggerIO64(address,condition);
            end
            
            %get trial onset
            data.onset(trial)=t0-eeg_start;
            
            %blank screen with fix cross
            fixcross_normal(window, cfg, xCenter, yCenter, ppd);
            
            time = GetSecs;
            [press_time, keyCode] = KbPressWait([] , t0+(stim_pres - 0.0084));
            if press_time - time < t0+(stim_pres - 0.0084)
                t0 = Screen( 'Flip' , window, t0+(stim_pres - 0.0084)) ;
            else
                t0 = Screen( 'Flip' , window);
            end
            
            resp=KbName(keyCode);
            if isempty(resp)
                data.response(trial) = 0;
            elseif strcmp(resp, 'ESCAPE' )
                sca
                Eyelink('CloseFile');
                Eyelink('ReceiveFile');
            else
                data.response(trial) = 1;
            end
            
            data.category{trial} = 'paperclip';
            
            
        end
        
        data.cond(trial) = cfg.trial_order(trial,2);
        data.block(trial) = cfg.trial_order(trial,1);
        
    end
    
    
    %pause and calibration after each block
    if trial == cfg.pause && trial ~= length(cfg.trial_order)
        cfg.pause = cfg.pause + 150;
        text_pause = 'This is a pause. Press any button if you want to continue. \n Take as long as you need.';
        DrawFormattedText(window, text_pause, 'center', 'center', white);
        Screen('Flip', window);
        Eyelink('Message', 'PAUSE');
        KbWait;
        WaitSecs(1);
        EyelinkDoTrackerSetup(el);
        EyelinkDoDriftCorrection(el);
    end
    
   %wait a bit before stop recording 
   WaitSecs(0.1);
   Eyelink('StopRecording');
   
   %mark the end of trial
   Eyelink('Message', 'TRIAL_RESULT 0');
    
end
%%
end_text = 'This is the end of the experiment. Thank you for participating.';
DrawFormattedText(window, end_text, 'center', 'center', white);
Screen('Flip', window);

Eyelink('CloseFile');
Eyelink('ReceiveFile');
Eyelink('Shutdown');

KbStrokeWait;
sca;
save(['.\FixCrossExp_s',num2str(data.subj_code),'_ses',num2str(cfg.session),'cfg','data']);
