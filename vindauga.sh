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

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export SCRIPT_DIR
LOUD=1
SONGSTRING=""
SONGFILE=""
SONGDIR=""
COVERFILE=""
MPD_MUSIC_BASE="${HOME}/Music"
DEFAULT_COVER="${SCRIPT_DIR}/defaultcover.jpg"
VINDAUGA_CACHE=""


function loud() {
    if [ "$LOUD" -eq 1 ];then
        echo "$@"
    fi
}

init_cache() {
    if [ -z "${XDG_DATA_HOME}" ];then
        export XDG_DATA_HOME="${HOME}/.local/share"
    fi
    if [ -z "${XDG_CONFIG_HOME}" ];then
        export XDG_CONFIG_HOME="${HOME}/.config"
    fi
    if [ -z "${XDG_CACHE_HOME}" ];then
        export XDG_CACHE_HOME="${HOME}/.cache"
    fi

    if [ ! -d "${XDG_CACHE_HOME}" ];then
        echo "Your XDG_CACHE_HOME variable is not properly set and does not exist." >&2
        return 99
    fi

    VINDAUGA_CACHE="${XDG_CACHE_HOME}/vindauga"
    if [ ! -d "${VINDAUGA_CACHE}" ];then
        if [ -d "${XDG_CACHE_HOME}/yadshow" ];then
            if ! ln -s "${XDG_CACHE_HOME}/yadshow" "${VINDAUGA_CACHE}";then
                echo "Unable to create cache symlink at ${VINDAUGA_CACHE}." >&2
                return 1
            fi
        else
            loud "Making cache directory"
            if ! mkdir -p "${VINDAUGA_CACHE}";then
                echo "Unable to create cache directory at ${VINDAUGA_CACHE}." >&2
                return 1
            fi
        fi
    fi

    if [ ! -f "${VINDAUGA_CACHE}/vindauga_bg.png" ];then
        if ! cp "${SCRIPT_DIR}/vindauga_bg.png" "${VINDAUGA_CACHE}/vindauga_bg.png";then
            echo "Unable to initialize cache assets in ${VINDAUGA_CACHE}." >&2
            return 1
        fi
    fi
}

function round_rectangles (){
    local draw_cmd
    local width
    local height

    width=$(identify -format "%w" "${1}") || return 1
    height=$(identify -format "%h" "${1}") || return 1
    draw_cmd="roundrectangle 1,1 $((width + 4)),$((height + 4)) 15,15"

    convert "${1}" \
        -alpha set -bordercolor none -border 3 \
        \( +clone -alpha transparent -background none \
        -fill white -stroke none -strokewidth 0 -draw "${draw_cmd}" \) \
        -compose DstIn -composite \
        \( +clone -alpha transparent -background none \
        -fill none -stroke black -strokewidth 3 -draw "${draw_cmd}" \
        -fill none -stroke white -strokewidth 1 -draw "${draw_cmd}" \) \
        -compose Over -composite "${2}"
}

load_mpd_host() {
    local mpd_line

    [ -n "${MPD_HOST}" ] && return 0
    [ -f "${HOME}/.bashrc" ] || return 0

    mpd_line=$(grep -E '^[[:space:]]*(export[[:space:]]+)?MPD_HOST=' "${HOME}/.bashrc" | tail -n 1) || return 0
    mpd_line=${mpd_line#export }
    mpd_line=${mpd_line#MPD_HOST=}
    mpd_line="${mpd_line%\"}"
    mpd_line="${mpd_line#\"}"
    mpd_line="${mpd_line%\'}"
    mpd_line="${mpd_line#\'}"

    if [ -n "${mpd_line}" ];then
        export MPD_HOST="${mpd_line}"
    fi
}

function get_coverart () {
    local aud_status
    local status
    local songcheck
    local tempfile3

    ### Test audacious, local mpd, remote mpd ###
    aud_status=$(audtool playback-status)
    if [ "${aud_status}" == "playing" ];then
        SONGSTRING=$(audtool current-song)
        SONGFILE=$(audtool current-song-filename)
    else
        # checking if MPD_HOST is set or exists in .bashrc
        # if neither is set, will just go with defaults (which will fail if
        # password is set.)
        load_mpd_host
        status=$(mpc | grep -c -e "\[")
        if [ "${status}" -lt 1 ];then
            echo "Not playing or paused"            
        else
            SONGFILE="${MPD_MUSIC_BASE}"/$(mpc current --format %file%)
            SONGSTRING=$(mpc current --format "%artist% - %album% - %title%")
        fi
    fi
    if [ -f "${VINDAUGA_CACHE}/songinfo" ];then
        songcheck=$(head -1 "${VINDAUGA_CACHE}/songinfo")
    else
        songcheck=""
    fi
    if [ "${SONGSTRING}" != "${songcheck}" ];then
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
        tempfile3=$(mktemp "${VINDAUGA_CACHE}/cover.XXXXXX.png") || return 1
        if ! convert "${COVERFILE}" -resize "600x600" "${tempfile3}";then
            rm -f "${tempfile3}"
            return 1
        fi
        if ! round_rectangles "${tempfile3}" "${VINDAUGA_CACHE}/nowplaying.album.png";then
            rm -f "${tempfile3}"
            return 1
        fi
        rm -f "${tempfile3}"
    fi
}

display_help() {
    ##############################################################################
    # Show help on cli
    ##############################################################################
    echo "usage: vindauga.sh [-h]"
    echo " "
    echo "┐ ┬o┌┐┐┬─┐┬─┐┬ ┐┌─┐┬─┐"
    echo "│┌┘│││││ ││─┤│ ││ ┬│─┤"
    echo "└┘ ┆┆└┘┆─┘┘ ┆┆─┘┆─┘┘ ┆"
    echo "Download and display album art or display embedded album art"
    echo " "
    echo "optional arguments:"
    echo "   -h     show this help message and exit"
}

case "${1:-}" in
    "")
        ;;
    -h|--help)
        display_help
        exit 0
        ;;
    *)
        echo "Unknown option: ${1}" >&2
        display_help >&2
        exit 2
        ;;
esac

init_cache || exit $?
get_coverart
