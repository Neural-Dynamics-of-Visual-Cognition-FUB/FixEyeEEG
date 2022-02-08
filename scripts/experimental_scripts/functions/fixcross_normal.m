function fixcross_normal(window, cfg, xCenter, yCenter, ppd)

%creates standard fixation cross
colorCross = cfg.crossColor;

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

penWidth = 7.5;

Screen('DrawLine', window, colorCross,from_h1, from_v1, to_h1,to_v1, penWidth );
Screen('DrawLine', window, colorCross, from_h2, from_v2, to_h2, to_v2,penWidth);
end