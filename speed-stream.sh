#!/usr/bin/env bash

# exit on failure.
set -e

# -[ configuration ]------------------------------------------ #
# /
# - source directory
#   https://stackoverflow.com/a/246128/422312
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
ROOT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"


# -[ parse arguments ]---------------------------------------- #
# /
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -s|--speedup)
            SPEEDUP="$2"
            shift
            shift
            ;;
		-c|--clips)
			CLIPS="$2"
			shift
			shift
			;;
       -h|--help)
            echo "Usage:                                                                   "
            echo "  bash speed-stream.sh --clips ./clips/                                  "
            echo "                                                                         "
            echo "Options:                                                                 "
            echo "  -s | --speedup [.5]    percentage to cut out. (optional)               "
            echo "  -c | --clips   [./]    clips to concat. (optional)                     "
            echo "                                                                         "
            shift
            exit 1
            ;;
    esac
done

SPEEDUP=${SPEEDUP:=0.5}
CLIPS=${CLIPS:=$PWD}

echo "                                          "
echo "[vars]                                    "
echo "dirname=$ROOT_DIR                         "
echo "--speedup=$SPEEDUP                        "
echo "--clips=$CLIPS                            "
echo "                                          "


# -[ execution ]-------------------------------------------------- #
# /
echo "<< NullStudios/SpeedStream >>"
rm -rf "$CLIPS/speed-stream.files" | true

for entry in "$CLIPS"/*.mp4
do
	echo "file '$entry'" >> "speed-stream.files"
done

ffmpeg -safe 0 -f concat -i "speed-stream.files" -vcodec libx264 -crf 27 -preset ultrafast -c:v copy normal-stream.mp4
ffmpeg -i normal-stream.mp4 -filter:v "mpdecimate,setpts=$SPEEDUP*N/FRAME_RATE/TB" -vcodec libx264 -crf 27 -preset ultrafast speed-stream.mp4

echo "Done."