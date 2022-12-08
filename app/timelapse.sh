#!/usr/bin/env bash
set -e
trap "rm -f $tmp_email" EXIT

if ! source $HOME/app/timelapse.conf;then
  echo "
Use /timelapse.conf-template to create an 
/timelapse.conf file and restart the service.
"
  exit 1
fi

# Make the $STILLS directory if it doesn't exist
[ -d $STILLS ] || mkdir -p $STILLS
# Make the $VIDEOS directory if it doesn't exist
[ -d $VIDEOS ] || mkdir -p $VIDEOS
# Make the $ASSEMBLY directory if it doesn't exist
[ -d $ASSEMBLY ] || mkdir -p $ASSEMBLY
# Make the temp file if sending email report
[ ! -z $MAILTO ] && tmp_email=$(mktemp)

usage() {
  cat<< EOF

    Usage: $0 [-hrlfS] [-s<stage>]

-h 'help'  ------------ print this info
-r 'run'   ------------ run all stages
-l 'list'  ------------ list the stages by number
-f 'fast'  ------------ generate the fast timelapse
-S 'still' ------------ generate a still
-s <stage_number> ----- run the specified stage

EOF
}

list() {
  cat<< EOF

    $0 stages:

    Run a specific stage with: $0 -s<stage_number>
    Example to run stage 1: $0 -s1

Stage 1 - Moves the stills from $STILLS to $VIDEOS
Stage 2 - Prepares the cumulative video
Stage 3 - Generates timelapse in $VIDEOS
Stage 4 - Removes the stills
Stage 5 - Appends (concatenates) the new timelapse with the cumulative video
Stage 6 - Removes the older videos

(Extra stage not run by default)
Stage f - Generates the FAST timelapse

EOF
}

# Exit and show usage if no command line arguments are provided
if [ "$#" -le 0 ];then
  echo "No options given"
  usage && exit 1
fi

# Parse command line arguments
while getopts "hrlfs:S" options;do
  case $options in
    h)  usage && exit 1
      ;;
    r)  continue;;
    l)  list && exit 1
      ;;
    f)  echo -n "-- Generate FAST timelapse  --  "
        (ffmpeg -y $FFMPEG_LOGGING -i "$(ls $VIDEOS/${TIMELAPSE}*.mp4)" \
          -vf  "setpts=0.05*PTS" $VIDEOS/speedyTimelapse.mp4 \
          && echo COMPLETE) \
          || (echo "NOPE" && exit 1)
        exit 0
      ;;
    s)  echo "Running stage $OPTARG"
        number=$OPTARG
      ;;
    S)  ffmpeg $FFMPEG_LOGGING -y -rtsp_transport tcp -re -i "$RTSP_STREAM" -frames 1 $STILLS/$(date +%F_%T).jpg
        exit 0
      ;;
    \?) echo "Option not recognized"; usage; exit 1;;
   esac
done

################################################################################
#                                  Stages BEGIN
################################################################################

stage_1() {
  echo -n "-- Moving the stills from $STILLS to $ASSEMBLY --  "

  (mv $STILLS/* $ASSEMBLY && echo COMPLETE) \
    || (echo "NOPE" && exit 1)
}

stage_2() {

  if ls $VIDEOS/$TIMELAPSE* &>/dev/null;then
    echo -n "-- Preparing the cumulative video $(basename $FILENAME) --  "
    (mv $VIDEOS/$TIMELAPSE*.mp4 $VIDEOS/$TIMELAPSE.mp4 \
      && echo COMPLETE) \
      || (echo "NOPE" && exit 1)
  else
    echo -n "-- Generating the first timelapse in $VIDEOS --  "
    (ffmpeg -y $FFMPEG_LOGGING -framerate $FPS -pattern_type glob \
      -i "$ASSEMBLY/*.jpg" -c:v libx264 -crf 17 \
      -pix_fmt yuv420p $VIDEOS/${TIMELAPSE}_tmp.mp4 \
      && rm -f $ASSEMBLY/*.jpg && echo COMPLETE) \
      || (echo "NOPE" && exit 1)
    exit
  fi
}

stage_3() {
  echo -n "-- Generating timelapse in $ASSEMBLY  --  "

  (ffmpeg -y $FFMPEG_LOGGING -framerate $FPS -pattern_type glob \
    -i "$ASSEMBLY/*.jpg" -c:v libx264 -crf 17 \
    -pix_fmt yuv420p $ASSEMBLY/${TIMELAPSE}_tmp.mp4 \
    && echo COMPLETE) \
    || (echo "NOPE" && exit 1)
}

stage_4() {
  echo -n "-- Removing the stills  --  "

  (rm $ASSEMBLY/*.jpg \
    && echo COMPLETE) \
    || (echo "NOPE" && exit 1)
}

stage_5() {
  echo -n "-- Appending (concatenating) the new timelapse with the cumulative \
video  --  "

#  tmpfile=$(mktemp) || exit 100
#  cat <<- EOF > $tmpfile
#	file '$ASSEMBLY/$TIMELAPSE.mp4'
#	file '$ASSEMBLY/${TIMELAPSE}_tmp.mp4'
#	EOF
  (cat "$VIDEOS/$TIMELAPSE.mp4" "$ASSEMBLY/${TIMELAPSE}_tmp.mp4" > "$FILENAME"\
    && echo COMPLETE) \
    || (echo "NOPE" && exit 1)

#  (ffmpeg $FFMPEG_LOGGING -f concat -safe 0 \
#    -i $tmpfile -c copy $FILENAME && rm -f $tmpfile \
#    && echo COMPLETE) \
#    || (echo "NOPE" && exit 1)
}

stage_6() {
  echo -n "-- Removing the older videos  --  "

  (rm -f $ASSEMBLY/$TIMELAPSE.mp4 \
    && rm -f $ASSEMBLY/${TIMELAPSE}_tmp.mp4 \
    && echo COMPLETE) \
    || (echo "NOPE" && exit 1)
}

################################################################################
#                                  Stages END
################################################################################

# Only run specified stage if '-s' flag is present
if [ ! -z $number ];then
  stage_$number
  exit 0
fi

# Standard run going through each stage ( '-r' flag )
{
  [ -z $SYSTEMD ] || echo '<pre>'
  echo Stage 1
  stage_1
  echo Stage 2
  stage_2
  echo Stage 3
  stage_3
  echo Stage 4
  stage_4
  echo Stage 5
  stage_5
  echo Stage 6
  stage_6
  # Report on disk space
  echo
  echo --------------------------------------------------------------------------------
  echo "Disk space"
  df -h /
  [ -z $SYSTEMD ] || echo '</pre>'
} | tee -a $tmp_email

# Send email report if $MAILTO is defined in timelapse.conf
if [ ! -z $MAILTO ];then
  cat $tmp_email | mail -a "Content-type: text/html" \
    -s "$TIMELAPSE timelapse from $(hostname)" $MAILTO &&\
    rm -f $tmp_email
fi

exit 0
