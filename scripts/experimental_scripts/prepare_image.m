%% load visual stimuli set
stim = load('.\vis_stim.mat');
images = stim.visual_stimuli;

%% extract animate and inanimate

% animate
% add 3 more animate images to balance categories

cat = imread('.\cat.jpg');
panda = imread('.\redpanda.jpg');
racoon = imread('.\racoon.jpg');

images(119).category = '119-cat';
images(119).pixel_values = cat;
images(119).animate = 1;

images(120).category = '120-panda';
images(120).pixel_values = panda;
images(120).animate = 1;

images(121).category = '121-racoon';
images(121).pixel_values = racoon;
images(121).animate = 1;

%stim.visual_stimuli = images;
save('.\vis_stim_121.mat', 'images');

animate = zeros(1,121);
for i = 1:length(images)
    animate(i) = images(i).animate;
end
animates = find(animate==1);
animates20 = randsample(animates,20);

mkdir('.\org_img')

%save animate
for j = animates20
    img = images(j).pixel_values;
    imwrite(img, ['.\org_img\animate',num2str(j),'.jpg']);
end

%tools and food

%all category names
catnames = cell(1,121);
for i = 1:length(images)
    catnames{i} = images(i).category;
end

%foods
food= {'149-bellpepper' '133-pretzel' '124-hotdog' '114-bagel' '110-pomegranate' '083-cucumber'...
    '088-pineapple' '135-artichoke' '040-fig' '076-mushroom' '071-hamburger' '058-strawberry'...
    '046-lemon' '043-banana' '017-pizza' '008-apple'...
    '001-orange' '143-winebottle'};

foods = zeros(1,18);
for i = 1:length(food)
    foods(i) = find(strcmp(catnames, food(i)));
end

%tools
tool = { '003-remotecontrol' '016-ipod' '145-fryingpan' '155-computermouse' '119-hairdryer' '113-racket' ...
    '075-microphone' '065-axe' '039-bow' '020-laptop' '165-canopener' '146-dumbbell' '151-corkscrew'...
    '117-syringe' '105-screwdriver' '049-hammer' '054-beaker' '095-pitcher' '087-ruler' '164-computerkeyboard'};

tools = zeros(1,20);
for i = 1:length(tool)
    tools(i) = find(strcmp(catnames, tool(i)));
end

inanimates = [tools foods];

% randomly choose 33 inanimate images
inanimate20 = randsample(inanimates, 20);

%save inanimate

for j = inanimate20
    img = images(j).pixel_values;
    imwrite(img, ['.\org_img\inanimate',num2str(j),'.jpg']);
end

my_images = [inanimate20 animates20];