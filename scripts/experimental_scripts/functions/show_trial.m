function show_trial(window,images,my_images,dat,cfg,paperclipTexture,stim_pres,times_iti,xCenter,yCenter,ppd)
ex_trial = dat(1:20);
for trial = 1:length(ex_trial)
    if ex_trial(trial)~= 0 %not catch trial
        my_img = double(images(my_images(dat(trial))).pixel_values)/255; %convert image to double
        imageTexture = Screen('MakeTexture', window, my_img); %make texture for the image
        Screen('DrawTexture', window, imageTexture, [], [], 0); %draw stimulus
        
        %fix cross on stimulus
        
        fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
        
        Screen('Flip', window);
        
        WaitSecs(stim_pres);
        
        %blank screen with fix cross
        fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
        Screen('Flip',window);
        
        WaitSecs(times_iti(trial));
    else
        %draw paperclip
        Screen('DrawTexture', window, paperclipTexture, [], [], 0);
        
        %fix cross
        fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
        
        Screen('Flip',window);
        
        WaitSecs(stim_pres);
        
        %blank screen with fix cross
        
        fixcross_bulls(window, cfg, xCenter, yCenter, ppd);
        
        Screen('Flip',window);
        
        WaitSecs(times_iti(trial));
    end
end
WaitSecs(1);
end

