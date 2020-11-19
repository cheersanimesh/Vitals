# Heart Rate Detection through Eulerian Magnification of Face Videos


An implementation of the Eulerian video magnification computer vision algorithm initially developed by MIT CSAIL. This program uses the method for the application of remotely detecting an individual's heart rate in beats per minute from a still video of his/her face.
The paper is in repository. 
"https://github.com/cheersanimesh/Vitals/blob/master/Eulerian%20Video%20Magnification%20for%20Revealing%20Subtle%20Changes%20in%20the%20World%20.pdf"


Built with OpenCV, NumPy, and SciPy in Python 3

## Program organization:
The main.py file contains the main program that utilizes all of the other modules defined in the other code files
to read in the input video, run Eulerian magnification on it, and to display the results. The purposes of the other
files are described below:
- preprocessing.py - Contains function to read in video from file and uses Haar cascade face detection to select an ROI on all frames
- capture_frames.py - Trying to extract the face skin part using Deep-Learning Semantic Segmentation.(Feature Not Complete)
- pyramids.py - Contains functions to generate and collapse image/video pyramids (Gaussian/Laplacian)
- eulerian.py - Contains function for a temporal bandpass filter that uses a Fast-Fourier Transform
- heartrate.py - Contains function to calculate heart rate from FFT results

## How to run:
To run the program, specify the path of the input video at "source" variable on line 12 of
main.py. To alter the frequency range to be filtered, change the values assigned to freq_min and freq_max on lines 9
and 10.
