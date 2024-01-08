# PCL_caged_dye

This code is meant to measure fluid flow in the PCL by tracking the displacement of a fluorescent dye uncaged in a certain position within the periciliary layer.

For each position 2 videos are required:
- Brightfield for detecting the epithelium position, powerstroke direction and ciliary beating frequency
- Epifluorescence video where the dye is released and is transported by the cilia

'example_running_code.m' is an example script to run the main scripts in the code:
% NOTE: experiments were run in a way that the dye is activated at different positions in the PCL, moving towards the cilia tips from their base. The two videos for each positions were put in a folder named depending on the position

'Caged_dye_manual_line.m' reads the bright-field video, shows one frame for the user to draw the epithelium contour and moves the contour parallel
