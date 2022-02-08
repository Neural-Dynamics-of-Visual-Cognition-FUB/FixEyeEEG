function [window, windowRect, black, white, grey, screenXpixels, screenYpixels, xCenter, yCenter]= open_window()
% opens window and defines coordinates
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2; 
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
end 