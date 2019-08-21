#!/bin/bash

## To permit vindauga integration of artist images with cantata

    if [ -f "$HOME/.config/vindauga.rc" ];then
        readarray -t line < "$HOME/.config/vindauga.rc"
        musicdir=${line[1]}
        cachedir=${line[3]}
        placeholder_img=${line[5]}
        placeholder_dir=${line[7]} 
        display_size=${line[9]} 
        XCoord=${line[11]} 
        YCoord=${line[13]} 
        ConkyFile=${line[15]} 
        LastfmAPIKey=${line[17]}
    fi


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for file in $(find "$cachedir" -iname "*-artist.jpg")
do


    fullfn=$(realpath "$file")

    echo "$fullfn"

    tmp1=$(basename "$file" | sed 's/\(.*\)\(-.*\)/\1.jpg/')
    tmp2=$(basename "$file" | sed 's/\(.*\)\(-.*\)/\1.png/')
    cantatadir1="$HOME/.cache/cantata/covers/"
    cantatadir2="$HOME/.cache/cantata/covers-scaled/136/"

    cfn1=$(printf "%s%s" "$cantatadir1" "$tmp1")
    cfn2=$(printf "%s%s" "$cantatadir2" "$tmp1")
    cfn3=$(printf "%s%s" "$cantatadir1" "$tmp2")
    cfn4=$(printf "%s%s" "$cantatadir2" "$tmp2")    
    
    #removing any cantata-native cachefiles
    if [ -f "$cfn1"];then rm "$cfn1";fi
    if [ -f "$cfn2"];then rm "$cfn2";fi
    if [ -f "$cfn3"];then rm "$cfn3";fi
    if [ -f "$cfn4"];then rm "$cfn4";fi

    ln -s "$fullfn" "$cfn1"
    ln -s "$fullfn" "$cfn2"

done
IFS=$SAVEIFS
