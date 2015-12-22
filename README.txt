MATLAB code
18-551 Group 2
Spring 2015
Michael Kellman, Bryan Phipps, Sophia Zikanova

This is the directory which contains all of the matlab code for testing the algorithm for extracting heart rate. The important files are listed below:
	heartrate_estimate.m
	jadeR.m [1]
	Video_load.m
	clamp.m

heartrate_estimate.m does the bulk of the work. JadeR.m is an open source implementation of Independent Component Analysis (ICA) made by Jean-Francois Cardoso [1]. Video_load.m loads in a video at a specific path. clamp.m clamps a minimum and maximum bound on signal.

The code in heartrate_estimate.m unmixes the RGB sensor signals and plots the separated source signals and their spectrums in beats per minute (bpm). The box for spatial averaging needs to be manully selected for new videos. Pausible boxes to select involve finding points on face and cheek. The best way to run this code is to load the video, display the first frame, manually select the face, and then run the spatially averaging and ICA. All the code is commented and more explanations lie within the scripts.

I have provided a couple example videos, all of me :). These are all recorded at 30 fps.
	video_test_2.mov
	video_test_4.mov
	video_test_5.mov
	video_test_6.mov

Best user case is when subject in video is stationary through out whole video.

References: 
[1] http://perso.telecom-paristech.fr/~cardoso/Algo/Jade/jadeR.m