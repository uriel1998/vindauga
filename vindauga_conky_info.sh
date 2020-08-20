#! /bin/bash

 function getInfo() {
	#mpdinfo=$(mpc --host "$hoststring"  )
	playingstring=$(echo "$mpdinfo" | head -1 | awk -F '[' '{print $1}' | fold -sw 58 | head -1 ) 
	percent=$(echo "$mpdinfo" | tail -2 | head -1 | awk '{print $4}')
    printf "%s: %s" "$playingstring" "$percent"
}

function isplaying() {
    mpdinfo=$(mpc --host "$hoststring" | sed -e 's/[/()&]//g')
    progress=$(echo "$mpdinfo" | tail -2 | head -1 | awk '{print $1" "$3 $4}')
    check=$(echo "$progress" | grep -c '\[')
}

function main() {
    
    hoststring="PASSWORD@localhost"
    isplaying
    if [ $check = 0 ];then
        hoststring="PASSWORD@OTHER HOST"
        isplaying
        if [ $check = 0 ];then
            echo "MPD is off"
        else
            getInfo
        fi
    else
        getInfo
    fi
}

main

