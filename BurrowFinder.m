function BurrowFinder

%% Instructions
%You MUST change the path_video (line 29) to the location of the videos on
%your computer and change the path_save (line 30) to the location where
%you would like the outputs to be saved.

%You MAY choose to:
%disable storing the image differences (StorDiffs = 0)
%disable storing thresholded images (StorThreshs = 0)
%disable skeletonization of data (StorSkels = 0)

%% Setup logistics

StorDiffs = 1;
StorThreshs = 1;
StorSkels = 0;


path_video = 'G:\My Drive\Maddy_Timelapse\RawVideos';
path_save = 'G:\My Drive\Maddy_Timelapse\FrameDifferences';


%% Interactively choose file
list=dir(path_video);
lst={list.name};
[indx,tf] = listdlg('ListSTring',lst,'SelectionMode','single')
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
bName = questdlg('On the following figure, click the four points that correspond to the square of sediment. Include as little of the white tank within the square as possible. Once the four points have been chosen, double click the first point to complete the square.','Instructions','Start','Start');

figure
imshow(first)
title(['Choose ROI points.'])

% Interactively find ROI
h = impoly;
roi_poly = wait(h);

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

frames = round(linspace(1,numFrame,round(numFrame/100))); %Analyzes only every 100th frame

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
%% Create composite figures to view all burrows created
figure
subplot(1,2,1)
imshow(last(y_r(1):y_r(2),x_r(1):x_r(2),:));
subplot(1,2,2)
imshow(last(y_r(1):y_r(2),x_r(1):x_r(2),:));
hold on
set(gca, 'YDir','reverse')
for i = 1:(length(frames)-1)
    load([path_save filesep filename filesep '2 Thresholded Images' filesep 'Frame' num2str(i)]);
    hold on
    plot(epoints(:,1),epoints(:,2),'.')
end


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

