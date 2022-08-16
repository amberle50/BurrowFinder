Burrow Finder - July 22, 2022

This program looks for narrow worm burrows in thin aquaria filled with mud.

INPUTS:
-Timelapse videos of worms burrowing in mud-filled thin aquaria. 
 Stationary camera and aquaria with minimal light disturbances are required for a clean analysis.

Manual ROI is defined through an interactive portion of the program.

OUTPUTS:
-A graph showing the visible burrows and how they change and develop through time
-A folder of .mat files showing the thresholded differences between frames
-OPTIONAL: A graph showing the skeletonized burrows and how they change through time
-OPTIONAL: A folder of .png files showing the differences between frames
-OPTIONAL: .png files showing the thresholded differences between frames in the folder with the .mat files for the same
-OPTIONAL: A folder of .png and .mat  files showing the skeletonized thresholded images

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INSTRUCTIONS ON USING PROGRAM:
You MUST change the path_video (line 22) to the location of the videos on your computer and change the path_save (line 23) to the location where you would like the outputs to be saved.

You would be advised to:
-update framesecs with the number of real time seconds captured by each frame, eg. a frame rate of 30fps would warrant a value of 1/30 or 0.033.
-update skiprate with how many of the frames you want to analyze. A value of 1 will analyze every frame. A value of 100 will analyze every 100th frame.
-update longestvideo with the real time in seconds of the longest video you wish to analyze. This will effect the ticks and labels on the output graph.

You MAY choose to:
-disable storing the image differences (StorDiffs = 0)
-disable storing thresholded images (StorThreshs = 0)
-disable skeletonization of data (StorSkels = 0)