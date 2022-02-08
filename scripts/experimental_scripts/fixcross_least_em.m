function [ output_args ] = fixcross_least_em(window, windowRect, screen, width, dist)
%Creates bulls eye fixation cross which should minimize eye movements 
%window: Psychtoolboxwindow
%windowRect: Psuchtoolbox defintion of window rectangle 
%width: width of the monitor in cm 
%dist: distance of the participant to the monitor 

% code mostly from: 

%Thaler, L., Sch?tz, A. C., Goodale, M. A., & Gegenfurtner, K. R. (2013).
%What is the best fixation target? The effect of target shape on stability of fixational eye movements. 
%Vision Research, 76, 31?42. https://doi.org/10.1016/j.visres.2012.10.012


colorOval = [0 0 0]; % color of the two circles in [R G B]
colorCross = [255 255 255]; % color of the cross [R G B]

d1 = 0.6; % diameter of outer circle (degrees)
d2 = 0.2; % diameter of inner circle (degrees)

% get screen properties in pixels
w=Screen('Resolution', screen);

screensize = [w.width w.height]/2;

%Screen('Preference', 'SkipSyncTests', 1);

[cx,cy] = RectCenter(windowRect); %returns the integer x,y point closest to the center of a rect.
ppd = pi * screensize(1)/atan(width/dist/2)/360; % pixel per degree 


%HideCursor;
% apparently 'DrawLine' cannot deal with non-integers for the penwidth (or this is a problem
% with the pixel sixe?)
penWidth = round(d2*ppd);
%Screen('FillOval', window, colorOval, [cx-d1/2*ppd,cy-d1/2*ppd, ...
%    cx+d1/2*ppd,cy+d1/2*ppd],d1*ppd);
Screen('DrawLine', window, colorCross,cx-d1/2*ppd, cy, cx+d1/2*ppd, cy, 6);
Screen('DrawLine', window, colorCross, cx, cy-d1/2*ppd, cx, cy+d1/2*ppd, 6);
%Screen('FillOval', window, colorOval, [cx-d2/2*ppd, cy- d2/2*ppd, cx+d2/2*ppd, ...
%    cy+d2/2*ppd], d2*ppd);


end