function fixcross_bulls(window, cfg, xCenter, yCenter, ppd)
%Creates bulls eye fixation cross which should minimize eye movements 

% code mostly from: 

%Thaler, L., Sch?tz, A. C., Goodale, M. A., & Gegenfurtner, K. R. (2013).
%What is the best fixation target? The effect of target shape on stability of fixational eye movements. 
%Vision Research, 76, 31?42. https://doi.org/10.1016/j.visres.2012.10.012


colorOval = cfg.dot1color; % color of the two circles in [R G B]
colorCross = cfg.crossColor; % color of the cross [R G B]

d1 = 0.6; % diameter of outer circle (degrees)
d2 = 0.2; % diameter of inner circle (degrees)


from_h1 = xCenter-d1/2*ppd;
from_v1 = yCenter;
to_h1 = xCenter+d1/2*ppd;
to_v1 = yCenter;


from_h2 = xCenter;
from_v2 = yCenter-d1/2*ppd;
to_h2 = xCenter;
to_v2 = yCenter+d1/2*ppd;

%penWidth = round(d2*ppd);
penWidth = 7.5;
Screen('FillOval', window, colorOval, [xCenter-d1/2*ppd,yCenter-d1/2*ppd, ...
    xCenter+d1/2*ppd,yCenter+d1/2*ppd],d1*ppd);
Screen('DrawLine', window, colorCross,from_h1, from_v1, to_h1,to_v1,penWidth );
Screen('DrawLine', window, colorCross, from_h2, from_v2, to_h2, to_v2,penWidth);
Screen('FillOval', window, colorOval, [xCenter-d2/2*ppd, yCenter- d2/2*ppd, xCenter+d2/2*ppd, ...
    yCenter+d2/2*ppd], d2*ppd);


end