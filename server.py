import cv2
from pyramids import build_video_pyramid, collapse_laplacian_video_pyramid
from heartrate import find_heart_rate
from preprocessing import read_video
from eulerian import fft_filter
from capture_frames import CaptureFrames
from flask import Flask,jsonify,request
import pickle
import requests

# Frequency range for Fast-Fourier Transform
# Initializers
freq_min = 1
freq_max = 1.8
ml_model = False
show_frames = False
source = "vid_from_net.mp4"

app= Flask(__name__)


class Run():
    def __init__(self, freq_max=1.8, freq_min=1, ml_model=False, show_frames=False, final_video=False):
        # self.source = source
        self.freq_max = freq_max
        self.freq_min = freq_min
        self.ml_model = ml_model
        self.show_frames = show_frames
        self.final_video = final_video

    def __call__(self, source):

        self.source = source

        print("Reading + pre-processing video...")
        if self.ml_model is True:
            capture_frames = CaptureFrames()
            self.video_frames, self.frame_ct, self.fps = capture_frames(self.source)
        else:
            self.video_frames, self.frame_ct, self.fps = read_video(source)

        print("Building Laplacian video pyramid...")
        self.lap_video = build_video_pyramid(self.video_frames)

        amplified_video_pyramid = []

        # Eulerian magnification with temporal FFT filtering
        print("Running FFT and Eulerian magnification...")
        self.result, self.fft, self.frequencies = fft_filter(self.lap_video[1], self.freq_min, self.freq_max, self.fps)
        self.lap_video[1] += self.result

        print("Calculating heart rate...")
        self.heart_rate = find_heart_rate(self.fft, self.frequencies, self.freq_min, self.freq_max)
        print(self.heart_rate)

        if self.final_video:
            # Collapse laplacian pyramid to generate final video
            print("Rebuilding final video...")
            self.amplified_frames = collapse_laplacian_video_pyramid(self.lap_video, self.frame_ct)

            # Output heart rate and final video
            print("Heart rate: ", self.heart_rate, "bpm")
            if show_frames:
                print("Displaying final video...")
                for frame in self.amplified_frames:
                    cv2.imshow("frame", frame)
                    cv2.waitKey(20)

        return self.heart_rate
run = Run()

@app.route('/',methods=['POST','GET'])
def calcHeartRate():
    data= request.get_json()
    vid_url=data['link']
    r= requests.get(vid_url)
    with open('vid_from_net.mp4','wb') as f:
        f.write(r.content)
    source='vid_from_net.mp4'
    heartbeat= run(source)
    with open('file','wb') as f:
        pickle.dump(heartbeat,f)
    return "success"

@app.route('/getVal',methods=['POST','GET'])
def getGetHeartRate():
    with open('file','rb') as f:
        heartRate= pickle.load(f)
    return jsonify({"heartRate": heartRate})


if(__name__=='__main__'):
    app.run(host='0.0.0.0',port=80)