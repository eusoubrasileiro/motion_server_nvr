### Network Video Recorder System Inside Linux 

- Uses [Motion Project](https://github.com/Motion-Project/motion)

 - Due Yoosee Ip Cameras (what I have) [abuse of RTSP protocol](https://stackoverflow.com/q/66280861/1207193) I had to create a patch for ffmpeg/libavformat (`RTSP_lower_transport_TCP.patch` modifies rtsp.c and rtsp.h) and make connection using rtsp/tcp possible. Hence ffmpeg must be compiled from source.
 
 - Uses [a custom](https://github.com/eusoubrasileiro/jetson-nano-image/tree/bionic_latest) jeston-nano image Ubuntu 18.04.5.
 
