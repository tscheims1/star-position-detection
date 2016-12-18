%% Template Matching Script for detecting the Positions of stars

clear;close all; clc;

I = imread('template_star.png');
I = rgb2gray(I); 							
templateInfo = imfinfo('TL_27_IMG_0079.JPG');
templateTime = datetime(templateInfo.DateTime,'InputFormat','yyyy:MM:dd HH:mm:ss');
Istart = I;

images = dir('*.JPG');
lastPos = [0,0];
maskOffsetX = 200;
maskOffsetY = 100;

hFig = figure;
hAx  = axes;

imshow(Istart,'Parent', hAx);


%a static local mask for star detection
maskOffset = [0,200,-100,100;       %star 0  - 10
              0,200,-100,100;       %star 10 - 20
              0,100,-100,100;       %star 20 - 30
              -100,100,-100,100;    %star 30 - 40
              -100,100,-100,100;    %star 40 - 50
              0,-200,-100,100;      %star 50 - 60
              0,-200,-100,100;];    %star 60 - 70


tic
data = zeros(size(images,1),5);
for i=1:50
    disp(fprintf('%i / %i',i,(size(images,1))));
    
	%read a new star image file
    filename = images(i).name;
    I2 = rgb2gray((imread(filename)));
    imageInfo = imfinfo(filename);
    imgTime = datetime(imageInfo.DateTime,'InputFormat','yyyy:MM:dd HH:mm:ss');

	%calculate delta Time for template rotation
    dv = datevec(imgTime);
    data(i,1) = dv(4);
    data(i,2) = dv(5);
    data(i,3) = dv(6);
    deltaTimeM = minutes(imgTime-templateTime);
	


    % 23.934469h == 360°
    minutesPerDay = 23.934469*60;
    rotAngle = (deltaTimeM / minutesPerDay)*360;
    IGray = imrotate(I,rotAngle); %rotate for template matching

    tSize1 = size(IGray,1);
    tSize2 = size(IGray,2);

	% do a local template matching (less false detects)
	% the first image is a perfect match -> we dont need a local template matching
    if(i > 1)
       mask = zeros(imgSize1,imgSize2);
       imod = ceil(i/10);
       
       mask(lastPos(1)+maskOffset(imod,1):lastPos(1)+maskOffset(imod,2),lastPos(2)+maskOffset(imod,3):lastPos(2)+maskOffset(imod,4)) = 1;
       I2(~mask) = 0;
    end
    
	%here the magic happens: find the position with the best correlation
    c = normxcorr2(IGray,I2);

    [ypeak, xpeak] = find(c==max(c(:)));
	%%
	
    lastPos = [ypeak,xpeak];
    
    yoffSet = (ypeak-floor(tSize1/2));
    xoffSet = (xpeak-floor(tSize2/2));
    data(i,4) = yoffSet;
    data(i,5) = xoffSet;
    
    plot(xoffSet,yoffSet,'+');
end
toc
save('stardata.mat');
hold off;