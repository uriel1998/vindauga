#!/bin/bash

##############################################################################
# ┐ ┬o┌┐┐┬─┐┬─┐┬ ┐┌─┐┬─┐
# │┌┘│││││ ││─┤│ ││ ┬│─┤
# └┘ ││└┘│─┘┘ ││─┘│─┘┘ │
#
#
#  (c) Steven Saus 2023
#  Licensed under the MIT license
#
##############################################################################

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LOUD=1
SONGSTRING=""
SONGFILE=""
SONGDIR=""
COVERFILE=""
MPD_MUSIC_BASE="${HOME}/Music"
DEFAULT_COVER="${SCRIPT_DIR}/defaultcover.jpg"


function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}

if [ -z "${XDG_DATA_HOME}" ];then
    export XDG_DATA_HOME="${HOME}/.local/share"
    export XDG_CONFIG_HOME="${HOME}/.config"
    export XDG_CACHE_HOME="${HOME}/.cache"
fi

if [ ! -d "${XDG_CACHE_HOME}" ];then
    echo "Your XDG_CACHE_HOME variable is not properly set and does not exist."
    exit 99
fi

VINDAUGA_CACHE="${XDG_CACHE_HOME}/vindauga"
if [ ! -d "${VINDAUGA_CACHE}" ];then
    if [ -d "${XDG_CACHE_HOME}/yadshow" ];then
        ln -s "${XDG_CACHE_HOME}/yadshow" "${XDG_CACHE_HOME}/vindauga"
    else
        loud "Making cache directory"
        mkdir -p "${VINDAUGA_CACHE}"
        ln -s "${XDG_CACHE_HOME}/vindauga" "${XDG_CACHE_HOME}/yadshow"
    fi
fi

if [ ! -f "${VINDAUGA_CACHE}/vindauga_bg.png" ];then
    cp "${SCRIPT_DIR}/vindauga_bg.png" "${VINDAUGA_CACHE}/vindauga_bg.png"
fi

function round_rectangles (){
    
    #NEED TO CLEAN UP FILE HANDLING AND OUTPUT AND SHIT
    
    convert "${1}" \
        -format 'roundrectangle 1,1 %[fx:w+4],%[fx:h+4] 15,15' \
        -write info:tmp.mvg \
        -alpha set -bordercolor none -border 3 \
        \( +clone -alpha transparent -background none \
        -fill white -stroke none -strokewidth 0 -draw @tmp.mvg \) \
        -compose DstIn -composite \
        \( +clone -alpha transparent -background none \
        -fill none -stroke black -strokewidth 3 -draw @tmp.mvg \
        -fill none -stroke white -strokewidth 1 -draw @tmp.mvg \) \
        -compose Over -composite               "${2}"
    rm tmp.mvg
}


function get_coverart () {
    
    ### Test audacious, local mpd, remote mpd ###
    aud_status=$(audtool playback-status)
    if [ "${aud_status}" == "playing" ];then
        SONGSTRING=$(audtool current-song)
        SONGFILE=$(audtool current-song-filename)
    else
        # checking if MPD_HOST is set or exists in .bashrc
        # if neither is set, will just go with defaults (which will fail if 
        # password is set.) 
        if [ "$MPD_HOST" == "" ];then
            export MPD_HOST=$(cat "${HOME}/.bashrc" | grep MPD_HOST | awk -F '=' '{print $2}')
        fi
        status=$(mpc | grep -c -e "\[")
        if [ $status -lt 1 ];then
            echo "Not playing or paused"            
        else
            SONGFILE="${MPD_MUSIC_BASE}"/$(mpc current --format %file%)
            SONGSTRING=$(mpc current --format "%artist% - %album% - %title%")
        fi
    fi
    if [ -f "${SONGFILE}" ];then 
        SONGDIR=$(dirname "$(readlink -f "${SONGFILE}")")
    
        if [ -f "$SONGDIR"/folder.jpg ];then
            COVERFILE="$SONGDIR"/folder.jpg
        else
            if [ -f "$SONGDIR"/cover.jpg ];then
                COVERFILE="$SONGDIR"/cover.jpg
            fi
        fi
    fi
    if [ "$COVERFILE" == "" ];then
        COVERFILE=${DEFAULT_COVER}
    fi
    echo "${SONGSTRING}" > "${VINDAUGA_CACHE}/songinfo"
    TEMPFILE3=$(mktemp)    
    convert "${COVERFILE}" -resize "600x600" "${TEMPFILE3}"
    round_rectangles "${TEMPFILE3}" "${VINDAUGA_CACHE}/nowplaying.album.png"
    rm "${TEMPFILE3}"
}

display_help() {
    ##############################################################################
    # Show help on cli
    ##############################################################################
    echo "usage: vindauga.sh [-h][-c][-y]"
    echo " "
    echo "┐ ┬o┌┐┐┬─┐┬─┐┬ ┐┌─┐┬─┐"
    echo "│┌┘│││││ ││─┤│ ││ ┬│─┤"
    echo "└┘ ┆┆└┘┆─┘┘ ┆┆─┘┆─┘┘ ┆"
    echo "Download and display album art or display embedded album art"
    echo " "
    echo "optional arguments:"
    echo "   -h     show this help message and exit"
    echo "   -c     run once and exit"    
    echo "   -y     do not use sxiv (e.g. for the art to be picked up by conky)"        
    echo "   -k     kill an existing background instance of vindauga"   
    echo "   -i     use a specific configuration file"
    echo "   -t     write mpc output to tempfile for remote mpc and conky"
}

if [ "$1" == "-h" ];then
    display_help
    exit
fi

get_coverart
