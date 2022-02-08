function [images, paperclipTexture, my_images, ppd, pic_size, inanimates] = prepare_img(cfg,window)
%load visual stimuli set
stim = load('./vis_stim_121.mat'); 
images = stim.images;

%indexes of animate and inanimate objects to be used (see prepare_image)
my_images = [63    90    96   103     3    41     1    35    89    18   114    14    80    15    51    57   112   111 ...
    68   109    81    19    11    56    37   121    24   119    59    52    26    17   120    76    95    99 ...
97    69    53     6];


%save category names to label the categories later


food= {'149-bellpepper'  '124-hotdog' '114-bagel'  ...
     '135-artichoke'  '076-mushroom' '071-hamburger' '058-strawberry'...
    '046-lemon' '017-pizza' ...
    '001-orange' };

tool = { '003-remotecontrol' '016-ipod' '155-computermouse' '113-racket' ...
     '065-axe' '039-bow' '020-laptop' '146-dumbbell' '151-corkscrew'...
     '095-pitcher'};

inanimates = [food tool];


%adjust image sizes
visang_rad = 2 * atan((cfg.screensize/2)/cfg.distance);
visang_deg = visang_rad * (180/pi);
ppd = cfg.pixel /visang_deg;
pic_size = [cfg.visangx * ppd, cfg.visangx * ppd];

for i = my_images
    images(i).pixel_values = imresize(images(i).pixel_values, pic_size);
end

%add paper clip
paperclip = imread('./paperclip.jpg');
paperclip = imresize(paperclip,pic_size);
my_paperclip = double(paperclip)/255;
paperclipTexture = Screen('MakeTexture', window, my_paperclip);
end