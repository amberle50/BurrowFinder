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
You MUST specify the filename (without the part after the ".") and the filetype (including the "."). 
You must declare these two variables when calling the function.

EXAMPLE:
filename = '2n_6_22_4';
filetype = '.mp4';
BurrowFinder(filename,filetype)

You MUST change the path_video (line 29) to the location of the videos on your computer and change the path_save (line 30) to the location where you would like the outputs to be saved.

You MAY choose to:
-disable storing the image differences (StorDiffs = 0)
-disable storing thresholded images (StorThreshs = 0)
-disable skeletonization of data (StorSkels = 0)