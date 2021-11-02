### Network Video Recorder System Inside Linux 

- Uses [Motion Project](https://github.com/Motion-Project/motion)

 - Due Yoosee Ip Cameras (what I have) [abuse of RTSP protocol](https://stackoverflow.com/q/66280861/1207193) I had to create a patch for ffmpeg/libavformat. They are rtsp.c and rtsp.h and make connection using rtsp/tcp possible. Hence ffmpeg must be compiled from source.
 
 
