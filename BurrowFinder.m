function BurrowFinder

%% Instructions
%You MUST change the path_video (line 22) to the location of the videos on
%your computer and change the path_save (line 23) to the location where
%you would like the outputs to be saved.

%You MAY choose to:
%disable storing the image differences (StorDiffs = 0)
%disable storing thresholded images (StorThreshs = 0)
%disable skeletonization of data (StorSkels = 0)

%% Setup logistics

framesecs = 10; %how many seconds of real time does each video frame represent?
skiprate = 100; %the skip rate of frames you want to analyze, eg. 1 = every frame being analyzed

StorDiffs = 1;
StorThreshs = 1;
StorSkels = 0;

path_video = 'G:\My Drive\Maddy_Timelapse\RawVideos';
path_save = 'G:\My Drive\Maddy_Timelapse\FrameDifferences';

%Set the time in seconds of the longest video you wish to analyze
longestvideo = 240; %This will standardize the color gradient between videos

%% Interactively choose file
list=dir(path_video);
lst={list.name};
[indx,~] = listdlg('ListSTring',lst,'SelectionMode','single');
flnm=lst{indx};

filename = flnm(1:end-4);
filetype = flnm(end-3:end);


%% Load a usable video
vid=VideoReader([path_video filesep filename filetype]);
numFrame = vid.NumFrames; %n=get(vid,'numberOfFrames');

set(0,'DefaultFigureWindowStyle','docked')

%Compare the first and last frames
first = vid.read(1);
last = vid.read(numFrame);
figure
imshowpair(first,last,'montage')
title('Compare the first and last frames')
bName = questdlg('Look at these images. Is the camera pointed in the same direction in each?','Preliminary Review','Yes', 'No ','Yes');

%End program and throw error if camera is obviously moved during recording.
if bName == 'No '
    error('Camera was not stationary.')
end

%Determine which side of the tank we're looking at
bName = questdlg('Which side of the tank is this?','Thresh Determination','N', 'S','N');

if bName == 'N'
    thresh = 0.7;
elseif bName == 'S'
    thresh = 0.9;
end

%% Interactively choose ROI

%Give instructions to person finding the ROI
questdlg('On the following figure, click the four points that correspond to the square of sediment. Include as little of the white tank within the square as possible. Once the four points have been chosen, double click the first point to complete the square.','Instructions','Start','Start');

figure
imshow(first)
title('Choose ROI points.')

% Interactively find ROI
h = impoly;
wait(h);

% Store ROI points
tmp = getPosition(h);
roi.x = tmp(:,1);
roi.y = tmp(:,2);

% Show ROI points
delete(h)
hold on
plot(roi.x,roi.y,'r-')
pause(1)
hold off

x_r=[round(min(roi.x)),round(max(roi.x))];
y_r=[round(min(roi.y)),round(max(roi.y))];

vid_roi=first(y_r(1):y_r(2),x_r(1):x_r(2),:);
figure
imshow(vid_roi)


%% Compare different frames iteratively
if StorDiffs == 1
    mkdir([path_save filesep filename filesep '1 Image Differences']);
end
if StorThreshs == 1
    mkdir([path_save filesep filename filesep '2 Thresholded Images']);
end
if StorSkels == 1
    mkdir([path_save filesep filename filesep '3 Skeletons']);
end

%se = strel('line',10,45); %structering element required for imerode function
se = strel('disk',2,8); %structering element required for imerode function

A = vid.read(1);
a=A(y_r(1):y_r(2),x_r(1):x_r(2),:);

frames = round(linspace(1,numFrame,round(numFrame/skiprate))); %Analyzes only every 100th frame

tic
for i=1:(length(frames)-1)%numFrame
    B = vid.read(frames(i+1));
    b=B(y_r(1):y_r(2),x_r(1):x_r(2),:);
    c = imabsdiff(a,b); %take the difference between this frame and the previous one
    d = imadjust(rgb2gray(c)); %make the result grayscale and adjust the contrast to use the full range from 0-1
    e = im2bw(d,thresh); %thresholds the image and makes it black and white
    a = b;
    e=imerode(e,se);
    f = bwskel(e);
    
    if StorDiffs == 1
        imwrite(c,[path_save filesep filename filesep '1 Image Differences' filesep 'Frame' num2str(i) '.png']);
    end
    
    if StorThreshs == 1
        imwrite(e,[path_save filesep filename filesep '2 Thresholded Images' filesep 'Frame' num2str(i) '.png']);
    end
    
    if StorSkels == 1
        
        [y_points,x_points] = find(f);
        fpoints = [x_points,y_points];
        
        imwrite(f,[path_save filesep filename filesep '3 Skeletons' filesep 'Frame' num2str(i) '.png']);
        save([path_save filesep filename filesep '3 Skeletons' filesep 'Frame' num2str(i)], 'fpoints');
    end
    
    [y_points,x_points] = find(e);
    
    epoints = [x_points,y_points];
    
    save([path_save filesep filename filesep '2 Thresholded Images' filesep 'Frame' num2str(i)], 'epoints');
    
end
toc

%% Create the color gradient for the final figure

ColNum = longestvideo * 30 / skiprate; %for a framerate of 30fps

c1 = [1 0 0]; %rgb value for the starting color
c2 = [0 0 1]; %rgb value for the ending color


%Creates a value determining the amount of color change between each frame
cr=(c2(1)-c1(1))/(ColNum-1);
cg=(c2(2)-c1(2))/(ColNum-1);
cb=(c2(3)-c1(3))/(ColNum-1);

%Initializes matrices.
gradient=zeros(ColNum,3);
r=zeros(10,ColNum);
g=zeros(10,ColNum);
b=zeros(10,ColNum);
%for each color step, increase/reduce the value of Intensity data.
for j=1:ColNum
    gradient(j,1)=c1(1)+cr*(j-1);
    gradient(j,2)=c1(2)+cg*(j-1);
    gradient(j,3)=c1(3)+cb*(j-1);
    r(:,j)=gradient(j,1);
    g(:,j)=gradient(j,2);
    b(:,j)=gradient(j,3);
end

%merge R G B matrix and obtain our image.
imColGradient=cat(3,r,g,b);

%% Create the tick labels for the final figure
maxtime=longestvideo * 30 * framesecs/60/60;% in hours
ColTicks=linspace(0, maxtime, 6);
ColTicks = round(ColTicks,2,'significant');

TickLabels = {
    [num2str(ColTicks(1)), ' hr'];
    [num2str(ColTicks(2)), ' hr'];
    [num2str(ColTicks(3)), ' hr'];
    [num2str(ColTicks(4)), ' hr'];
    [num2str(ColTicks(5)), ' hr'];
    [num2str(ColTicks(6)), ' hr'];
   };

%% Create composite figures to view all burrows created

figure
orig=subplot('Position', [0.1300    0.1210    0.29    0.79]);
imshow(last(y_r(1):y_r(2),x_r(1):x_r(2),:));
fin=subplot('Position', [0.5703    0.1100    0.3347    0.8150]);
imshow(last(y_r(1):y_r(2),x_r(1):x_r(2),:));
hold on
set(gca, 'YDir','reverse')
for i = 1:(length(frames)-1)
    load([path_save filesep filename filesep '2 Thresholded Images' filesep 'Frame' num2str(i)]);
    hold on
    plot(epoints(:,1),epoints(:,2),'.','MarkerFaceColor',gradient(i,:),'MarkerEdgeColor',gradient(i,:))
end

colormap(gradient)
ColBar=colorbar;
ColBar.Ticks = [0,0.2,0.4,0.6,0.8,1];
ColBar.TickLabels = TickLabels;


if StorSkels ==1
    figure
    subplot(1,2,1)
    imshow(last(y_r(1):y_r(2),x_r(1):x_r(2),:));
    subplot(1,2,2)
    imshow(last(y_r(1):y_r(2),x_r(1):x_r(2),:));
    hold on
    set(gca, 'YDir','reverse')
    for i = 1:(length(frames)-1)
        load([path_save filesep filename filesep '3 Skeletons' filesep 'Frame' num2str(i)]);
        hold on
        plot(fpoints(:,1),fpoints(:,2),'.')
    end
end


end

