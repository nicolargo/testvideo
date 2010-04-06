#!/bin/sh
#
# Test video codecs
# 
# Nicolargo - GPL v3
#
# Installation of the latest codec version:
# * http://ubuntuforums.org/showpost.php?p=8345112&postcount=636
#
# Encoding pipeline: 
# * http://keyj.s2000.ws/?p=356
# * http://forum.doom9.org/showthread.php?p=1072386#post1072386
# * http://www.mplayerhq.hu/DOCS/HTML/fr/menc-feat-x264.html
# * http://forum.ripp-it.com/Codec-H264-X264-Encodage-en-x264-hp-et-h264-AVC-t8724.html
# * http://mewiki.project357.com/wiki/X264_Settings
# * http://rob.opendot.cl/index.php/useful-stuff/x264-to-ffmpeg-option-mapping/
# * http://blog.nicolargo.com/2009/11/encodage-de-video-avec-gstreamer.html

SOURCE=$1
BASENAME=$(basename $1 .${1##*.})
RESOLUTION=`ffmpeg -i $SOURCE 2>&1 | grep Stream | grep Video | awk -F\, '{ print $3 }'`

# Codec: H.264 GSTREAMER
ENCODER="x264enc"
PROFILE="HQ"
PARAMETERS="pass=4 quantizer=20 subme=6 me=2 ref=3 threads=0"
time gst-launch filesrc location=$SOURCE ! decodebin name=decoder \
 decoder. ! queue ! audioconvert ! faac profile=2 ! queue ! \
 ffmux_mp4 name=muxer \
 decoder. ! queue ! ffmpegcolorspace ! $ENCODER $PARAMETERS ! queue ! \
 muxer. muxer. ! queue ! filesink location=$BASENAME-$PROFILE-$ENCODER.mp4

# Codec: H.264 GSTREAMER
ENCODER="x264enc"
PROFILE="MQ"
PARAMETERS="pass=4 quantizer=25 subme=5 me=2 ref=3 threads=0"
time gst-launch filesrc location=$SOURCE ! decodebin name=decoder \
 decoder. ! queue ! audioconvert ! faac profile=2 ! queue ! \
 ffmux_mp4 name=muxer \
 decoder. ! queue ! ffmpegcolorspace ! $ENCODER $PARAMETERS ! queue ! \
 muxer. muxer. ! queue ! filesink location=$BASENAME-$PROFILE-$ENCODER.mp4

# Codec: H.264 GSTREAMER
ENCODER="x264enc"
PROFILE="LQ"
PARAMETERS="pass=4 quantizer=30 subme=4 threads=0"
time gst-launch filesrc location=$SOURCE ! decodebin name=decoder \
 decoder. ! queue ! audioconvert ! faac profile=2 ! queue ! \
 ffmux_mp4 name=muxer \
 decoder. ! queue ! ffmpegcolorspace ! $ENCODER $PARAMETERS ! queue ! \
 muxer. muxer. ! queue ! filesink location=$BASENAME-$PROFILE-$ENCODER.mp4

# !!!!
# ON ENCODE SEULEMENT EN X.264
exit

# Codec: THEORA
ENCODER="ffmpeg2theora"
PROFILE="HQ"
PARAMETERS="-v 8 --optimize"
time $ENCODER $PARAMETERS $SOURCE -o $BASENAME-$PROFILE-$ENCODER.ogg

# Codec: THEORA
ENCODER="ffmpeg2theora"
PROFILE="MQ"
PARAMETERS="-v 6 --optimize"
time $ENCODER $PARAMETERS $SOURCE -o $BASENAME-$PROFILE-$ENCODER.ogg

# Codec: THEORA
ENCODER="ffmpeg2theora"
PROFILE="LQ"
PARAMETERS="-v 4 --optimize"
time $ENCODER $PARAMETERS $SOURCE -o $BASENAME-$PROFILE-$ENCODER.ogg

# Codec: H.264 FFMEG
ENCODER="ffmpeg"
PROFILE="HQ"
PARAMETERS="-vcodec libx264 -s $RESOLUTION -vpre hq -vpre main -crf 18 -subq 6 -refs 6 -bf 3 -flags2 +bpyramid+wpred+dct8x8"
time $ENCODER -i $SOURCE $PARAMETERS $BASENAME-$PROFILE-$ENCODER.mp4

# Codec: H.264 FFMEG
ENCODER="ffmpeg"
PROFILE="MQ"
PARAMETERS="-vcodec libx264 -s $RESOLUTION -vpre hq -vpre main -crf 22 -subq 5 -refs 3 -bf 2 -flags2 +bpyramid+dct8x8"
time $ENCODER -i $SOURCE $PARAMETERS $BASENAME-$PROFILE-$ENCODER.mp4

# Codec: H.264 FFMEG
ENCODER="ffmpeg"
PROFILE="LQ"
PARAMETERS="-vcodec libx264 -s $RESOLUTION -vpre hq -vpre main -crf 26 -subq 1 -refs 1"
time $ENCODER -i $SOURCE $PARAMETERS $BASENAME-$PROFILE-$ENCODER.mp4

# Results

# Hwd: Intel(R) Core(TM)2 Duo CPU     E6750  @ 2.66GHz / 1 Go RAM
# Src: twilighteclipse_trlr_01_1080p_dl.mov
# PROFILE		ENCODING TIME	AVG BITRATE	FILE SIZE	PSNR	SSIM
# HQ-ffmpeg		793 sec		4867 Kbps	57 Mo		39,87	0,95
# MQ-ffmeg		469 sec		2166 Kbps	26 Mo		39,64	0,95
# LQ-ffmeg		210 sec		1094 Kbps	14 Mo 		38,49	0,95
# HQ-x264enc		408 sec		4927 Kbps	56 Mo		49,55	0,99
# MQ-x264enc		287 sec		1987 Kbps	23 Mo		46,19	0,98
# LQ-x264enc		174 sec		1009 Kbps	12 Mo		42,50	0,98
# HQ-ffmpeg2theora	426 sec		3093 Kbps	36 Mo		-	-
# MQ-ffmpeg2theora	410 sec		1814 Kbps	21 Mo		-	-
# LQ-ffmpeg2theora	400 sec		1082 Kbps	13 Mo		-	-







