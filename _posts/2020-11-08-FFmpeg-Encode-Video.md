---
layout: post
title: FFmpeg Encode Video
date: 2020-11-08 21:48:00
comment_id: 108
categories: [Mac]
tags: [video, codec]
---

Personally I prefer using ffmpeg to quick convert video in Mac. So I'd like to memo some frequent use commands at here. Some examples:

```s
# force the frame rate of the output file to 24 fps
ffmpeg -i input.avi -r 24 output.avi

# force the frame rate of the input file (valid for raw formats only) to 1 fps and the frame rate of the output file to 24 fps
ffmpeg -r 1 -i input.m2v -r 24 output.avi
```

## Encode video and transfer format

```s
## stream copy

ffmpeg -i inputFile.avi -c copy outputFile.mp4

# lossy encoding
ffmpeg -i inputFile.avi outputFile.mp4

## Adjust Bitrate

# set video bitrate of the output file to 1500 kbit/s and audio bitrate as 128 kbit/s
ffmpeg -i inputFile.avi -b:v 1500k -b:a 128k outputFile.mp4

## Set codec

# use libx265 video and aac audio codec
# video codec: h265(libx265), vp9 are popular
# audio codec: aac, mp3(libmp3lame) are popular
# with h264/h265 encoding, there is an option -crf
# (Constant Rate Factor) which can be changed to improve
# the visual quality of the video.
# The lower the value, the better the visual quality.
ffmpeg -i inputFile.avi -c:v libx265 -c:a aac outputFile.mp4

# lossless encoding
# for h264/h265 encoding, set the -crf option to 0 to get a lossless encoding
# for Vp9, set the -lossless option to 1
ffmpeg -i inputFile.mkv -c:v libx264 -preset ultrafast -crf 0 outputFile.mkv
ffmpeg -i inputFile.mkv -c:v libx265 -crf 0 outputFile.mkv
ffmpeg -i input.mp4 -c:v vp9 -lossless 1 output.webm
```

## Resize video resolution

```s
# resize to a fixed dimension/resolution
ffmpeg -i inputFile.avi -c:v vp8 -vf scale=640:360 -c:a libvorbis outputFile.mkv
# resize proportionally
ffmpeg -i inputFile.VOB -c:v libx265 -c:a aac -vf scale=1080:-1 outputFile.mkv
ffmpeg -i inputFile.VOB -c:v libx265 -c:a aac -vf scale=-1:1080 outputFile.mkv
```

## Merge 2 more videos

```s
ffmpeg -i "concat:file1.mpg|file2.mpg|file3.mpg" output.avi
ffmpeg -i "concat:file1.mpg|file2.mpg|file3.mpg" -c copy output.mpg

# convert each file first, then merge them
# it required the files in the same format(encode same, same resolution)
ffmpeg -i file1.mp4 -c copy -bsf:v h264_mp4toannexb temp1.ts
ffmpeg -i file2.mp4 -c copy -bsf:v h264_mp4toannexb temp2.ts
// Then join the intermediate files
ffmpeg -i "concat:temp1.ts|temp2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
```

## Split video

```s
# create a clip of ~2 minutes beginning from the 10th minute to the 12th minute
ffmpeg -i inputVideo.mp4 -ss 00:10:00 -to 00:12:00 outputClip.mp4
```

## Extract audio

```s
ffmpeg -i input.avi -vn output.mp3

# Using custom audio sampling frequency/audio channels/audio-bitrate
ffmpeg -i input.avi -vn -ar 44100 -ac 2 -b:a 192k output.aac

# get audio with the highest possible quality
ffmpeg -i input.avi -vn -#### Q:a 0 output.aac

# extracting audio from the 5th second to the 10th second
ffmpeg -i input_input.avi -ss 5 -to 10 -vn output.mp3

# lossless extract -> only copy audio stream from video
# without encoding, the process will be fast

# Get the information about video
# (This reveals the audio codec used)
ffmpeg -i input.avi
# If the audio codec is mp3,
ffmpeg -i input.avi -c:a copy output.mp3
# If the audio codec is aac,
ffmpeg -i input.flv -c:a copy output.aac
```

## Add/Remove audio

```s
### Add audio

## replace original audio

# if the audio is longer than the video, the video will freeze when it reaches its end whereas the audio will continue until it reaches the end of its duration, and vice-versa.
ffmpeg -i inputAudio.mp3 -i inputVideo.avi outputVideo.avi

# To avoid above issue
# use the -shortest option which truncates the output to the same duration as the shortest input
# OR use the -t 300 option which will truncate the output at the 300th second.
ffmpeg -i inputAudio.mp3 -i inputVideo.avi -shortest outputVideo.avi
ffmpeg -i inputAudio.mp3 -i inputVideo.avi -t 300 outputVideo.avi

## add additional audio track

# -map 0 copies all streams(audio + video) from the first input file (input_video_with_audio.avi)
# -map 1 copies all streams (in this case, one i.e. audio) from the second input file (new_audio.ac3)
# Hence the output video will now have 2 audio streams. During playback,
# the user can choose the audio track to listen. (Works with players that support it, like VLC player)
# By default, it uses the first audio track that was mapped. (-map 0, where 0 refers to the first input file)
ffmpeg -i input_video_with_audio.avi -i new_audio.ac3 -map 0 -map 1 -c copy outputVideo.avi


### Remove audio

# use the -an option which tells FFmpeg to exclude all audio streams from the input.
ffmpeg -i inputVideo.avi -c copy -an outputVideo.avi
```

## Add/Remove/Extract Subtitles

```s
## add
ffmpeg -i inputVideo.mp4 -i inputSubtitle.srt -c copy -c:s mov_text outputVideo.mp4

## remove
ffmpeg -i input.mkv -c copy -sn output.mkv

## extract
ffmpeg -i inputVideo.avi -txt_format text output.srt
```

## Convert audio format

```s
ffmpeg -i input.wav -vn output.mp3
ffmpeg -i input.mp4 -vn output.ogg
ffmpeg -i input.flv -vn output.mp3
ffmpeg -i input.flac -vn -ar 44100 -ac 2 -b:a 192k output.aac
```

## Convert video to images and vice-versa

> You can generate images from a video in the following formats:
> PGM, PPM, PAM, PGMYUV, JPEG, GIF, PNG, TIFF, SGI.

```s
ffmpeg -i input.mpg image%d.jpg
ffmpeg -i image%d.jpg output.avi
```

## Video filters, additional options

```s
## Deinterlace Videos
## Deinterlacing is done generally on older videos or videos that had been used for broadcasting purposes to minimize the interlacing effect.

# Yadif(“yet another deinterlacing filter”) is the name of the filter used.
ffmpeg -i input.mp4 -vf yadif output.mp4

## Customize Chroma Subsampling
## Chroma subsampling is the practice of encoding images by implementing less resolution for chroma information(i.e. color information)
## than for luma information(brightness information), taking advantage of the human visual system’s lower acuity for color differences than for luminance.

# The Pixel format is set to yuv420p which denotes 4:2:0 chroma subsampling.
ffmpeg -i input.mp4 -vf format=yuv420p output.mp4

## Update Interval of Keyframes
## A Keyframe is a frame that defines the starting or the ending point of a transition. You can update the keyframes interval to reach the GOP(Group of Pictures) size.
## The GOP size depends on the application and the delay. A higher frame rate has a higher GOP size.

# The expression expr:gte(t\,n_forced/2) is used to place keyframes every half a second.
ffmpeg -i input.mp4 -force_key_frames expr:gte(t\,n_forced/2) output.mp4
```

#### Reference

- <https://www.ffmpeg.org/documentation.html>
- <https://github.com/FFmpeg/FFmpeg>
