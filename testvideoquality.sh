#!/bin/sh
#
# Test video codecs
# 
# Nicolargo - GPL v3
# 
# QPSNR:
# * http://qpsnr.youlink.org/
#

SOURCE=$1
BASENAME=$(basename $1 .${1##*.})
RESOLUTION=`ffmpeg -i $SOURCE 2>&1 | grep Stream | grep Video | awk -F\, '{ print $3 }'`
CODECVIDEO=`ffmpeg -i $SOURCE 2>&1 | grep Stream | grep Video | awk '{ print $4 }' | sed 's/,//g'`

# BUB DECODAGE Theora... http://qpsnr.youlink.org/#known_issues
# CODECLIST="ffmpeg x264enc ffmpeg2theora" 
# CODECLIST="ffmpeg x264enc"
CODECLIST="x264enc"
ALGOLIST="psnr ssim"
PROFILELIST="HQ MQ LQ"

for CODEC in `echo $CODECLIST`
do
  case $CODEC in
    ffmpeg2theora) EXT="ogg";;
    *) EXT="mp4";;
  esac
  for ALGO in `echo $ALGOLIST`
  do
    case $ALGO in 
      psnr ) ALGODESC="PSNR - Higher is better";;
      ssim ) ALGODESC="SSIM - Higher is better (0-1)";;
    esac  
    FILELIST=$SOURCE
    for PROFILE in `echo $PROFILELIST`
    do
	FILELIST=`echo $FILELIST $BASENAME-$PROFILE-$CODEC.$EXT`
    done

    echo ">>> $FILELIST"

    # Compute
    qpsnr -a avg_$ALGO -r $FILELIST | sed 's/,/\ /g' > $BASENAME-$CODEC.$ALGO
    awk '{sum1+=$2; sum2+=$3; sum3+=$4;} END {print sum1/NR, sum2/NR, sum3/NR}' $BASENAME-$CODEC.$ALGO > $BASENAME-$CODEC.$ALGO.avg

    # Graph
    (echo "reset;\n \
       set terminal png;\n \
       set key ins vert;\n \
       set key bot right;\n \
       set xlabel 'Frame';\n \
       set ylabel '$ALGODESC';\n \
       set title 'Source file: $BASENAME';\n \
       set grid;\n \
       ") > $BASENAME-$CODEC.$ALGO.gp    
    (echo -n "plot ") >> $BASENAME-$CODEC.$ALGO.gp
    CPT=2
    for PROFILE in `echo $PROFILELIST`
    do
      if [ $CPT -ne 2 ]
      then
        (echo ", \\") >> $BASENAME-$CODEC.$ALGO.gp
      fi
      (echo -n "'$BASENAME-$CODEC.$ALGO' using 1:$CPT with linespoints title '$CODECVIDEO/$CODEC $PROFILE'") >> $BASENAME-$CODEC.$ALGO.gp
      CPT=$(expr $CPT + 1)
    done
    CPT=1
    for PROFILE in `echo $PROFILELIST`
    do
      (echo ", \\") >> $BASENAME-$CODEC.$ALGO.gp
      AVG=`cat $BASENAME-$CODEC.$ALGO.avg | awk -v cptawk=$CPT '{ print $cptawk; }'`
      (echo -n "$AVG with lines lw 2 title 'Average $CODECVIDEO/$CODEC $PROFILE'") >> $BASENAME-$CODEC.$ALGO.gp
      CPT=$(expr $CPT + 1)
    done
    (echo ";") >> $BASENAME-$CODEC.$ALGO.gp
    cat $BASENAME-$CODEC.$ALGO.gp | gnuplot > $BASENAME-$CODEC.$ALGO.png

    # Display
    eog $BASENAME-$CODEC.$ALGO.png &
  done
done

exit

#########
# THE END
#########

