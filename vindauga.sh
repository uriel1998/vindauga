#!/bin/bash


#!/usr/bin/env bash
# ┐ ┬o┌┐┐┬─┐┬─┐┬ ┐┌─┐┬─┐
# │┌┘│││││ ││─┤│ ││ ┬│─┤
# └┘ ││└┘│─┘┘ ││─┘│─┘┘ │
#
# by Steven Saus
#
# A (rather rewritten) fork of kunst (originally by Siddharth Dushantha)


##############################################################################
# Use ionice if it exists
##############################################################################
HasIonice=$(which ionice)
if [ -f "$HasIonice" ];then
    "$HasIonice" -c3 -p$$
fi

tempcover=$(mktemp)
tempartist=$(mktemp)
RunOnce=""
NoSXIV="false"
DynamicConky="false"
cachecover=""
SXIVPID=""
##############################################################################
# Initialize
##############################################################################

init (){

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

    if [ -z "$MusicDir" ] || [ ! d "$MusicDir" ]; then
        MusicDir="$HOME/music"
    fi
    if [ -z "$display_size" ];then
        display_size=256
    fi
    if [ -z "$XCoord" ];then
        XCoord=64
    fi
    if [ -z "$YCoord" ];then
        YCoord=64
    fi    
    if [ -z "$cachedir" ];then
        cachedir="$HOME/.cache/vindauga"
    fi
    if [ ! -d "$cachedir" ];then
        mkdir -p "$cachedir"
    fi
    if [ -z "$ConkyFile" ];then
        ConkyFile="$HOME/.conky/vindauga_conkyrc"
    fi


# This is a base64 endcoded image which will be used if nothing is found    
read -d '' DEFAULT_COVER << EOF
iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGqUlEQVRoge2Ze2yV5R3HP9/nnNNyEbkfKJTBjA7CRP9gCZTMUY3MMbOAtCUC4iXDhZiYAS0GHXHg2ILSohM3ZYNsuARjS0GcMcZLJJGsKMMtLgisW9dS2gGtXLW15/R9f/ujsPVyTs97TsuSLf38+Ty/5/t+v+e5vJcDAwwwwP806g+RG9+szr7YFrlDvmaYmCBjImYfZW0trjFfdyOqkaojcQ7WHq443avYBnPjbjn5UzO+BRa62myoBeOlpsLJ5f0T4H0Lj/usvshkBcBdwHWduw3tjJSuOS7Y0qnZBz4wrCIcyt598uDu891lx+6tK5JR3r39CvEsz40/tXjSuasNLhPvY/fWFUXP1R012W6goLv5XnDAXKEXPC9WMyGvsOTG+fOzOxcIm9zL+Eg8bBO6CwY3vqf+pmhl7aGOX0hfS2dsAkYItrReGHI8d3ZhfqYigQOMq6y708n/EDQr04slRlNMvJObV/TDTEaHgxRF955caWbbgtZn4sOw5ybmFQ6JQzydgSlnILq3dhFmv+Tame9Mb+s/Ib0GiO6pvwXTy/TTcXstSBpgbPnZ65C/Hxj6X/Qzynw19dJvfrvX3LkhaQCFWouBKf1kLCh3Zr/+q3eRvQI0AnalPWZQD6xrWvzVLjfChOs6ur9mHO2UXFuvCRlJ9Ym3w6UlTzRmNd8ffXRXMzDcYF9TweR7Ew1IOANqD68n+M2pXzGYLuO1ia2jxgep7xmg3EKGLe2jj2pk1U52sY86KemxhMar9jYfNypDvT3O+Wvdzx73QuH4dA/qPE83hEN2H7AeyOqT2wT0COA5tyCDM9MXtjxUWlIreIswU32EgHDIzmG2xqTbBfuAaN9t/4ceS0gwN20VURYpK24TfABM7dY7Cum3MhbJ2UMZ+kxKgk1suWlq1EYqf/G8mbYn1ruCWIOnFuCNNPV7pcsFv15+NAs0Jj0JVVrN3xcAo1MVIn4g2evp6fdOlwDnQoNzSPOxQfjHZZoZpNbgGxJ/Skc/FV028T8LXq6fkv/nkekIDG2KtFwYxpyg9fF21xJylrowIF0C3DDz6LC2tvB5Ol79mglwYpwfbjswOyKUcoMK/hgKMZ3+8991CdUcqbgINAmOCy0OIiDjnpiL70M0pyg10HYZyzI1m4gEp4b+ajC1PcynQCyAxugsP3uFsJWAl7TK2Ir8MYYtzNRsIhIE8I8CIRf3b8X0cRARYRt8FEG6DTjRrfsc8IBz/qtmerGvhrvTI4CDvQByzAc/2eeN7kjGK5itkW/fw/cnmbjLnKYJ3QRM881VAWMDaH0OPOktW9VGgLfAHgX1ue7diafsLKaHIp6mx8O2ERgWMEihORWCLsg4hjHMsGlBjNCx/Ha0jsjZFFlRUmhwjAAvUz2XUEWFZ+JVYGQszN3AjoDmOzMCyAO7mWDm3/AtNCO2tuy98IqSAwbPcvXGKE5I7Ew2MOFNK2fOosnO3DGgSWiOya/CNCn9HKnQxzivJL7m2RioFGx2p84zmDaeHT3p19yu9qQKyTpy8wo2GnoS2YvO2O+jt/rReZ2MH3256unDLhLZDHZPp74WUJl5g55pWhz9PJVQL9PrNoM9iGmlGb836TFhz6TrVHAJ7DmT+0gwEfxBLC+ujEdz1znsN2CRK6W+sF3x2OUfD972VL4XYjAdGzqVfnJyZxfMMul9wAzmYcyT2BDUvMHp0Licb8aWFy8xNB90xuR/Kl+PIq7v5OJtfLc2Urb6K4KnzWxbw6HKl4JcI+WD24S8goVClcAl52yeZ5oh4wVgSEpx475YSdlcxMNJEv4FtDa0pbjZOSsF8sF+3lBVuSqIeQjwZa6xqvI14BHget/XQUxDnbxZEkdSjW0dM+YA4oEEXafN7Pt6fv2CcNnq+52zw0C+iR0NVZWrg5oPFACgoWrPdvP1HeALYdvMwj/BsyVCi4BPko2TCxskfHR7Nqu0OCscbz0mtBRA6PHGP+x5OEl93wIANH5Y8Y5n4Zmgw4YtNKdjhi0MOVsacnazxDrgPaAGaAMY1HQmH9jVTeqyu9RSLukxIFvwDzP79qmqis3pGL9KJt88NWF20WI5/yns3/8R/M2MN510wPM5me3TEAv73xXa5A0fM8dWPLHMZPMFjWZuU6Rs9b3AIxjb2lsGbz7zye++yMR8pgE6KCoK5Tb4SzAVGswj+aa+AGxVx8xFEVPx9Vl2nJ1XHt/7RL98dZ6S/+Cg9vjlO8zXrSZyZOQYijrsS4MLErXm2xELu0ONBytO9sc1BxhggP8T/gV0Z3bopSEc6QAAAABJRU5ErkJggg==
EOF

    if [ -d "$placeholder_dir" ];then
        hasimgs=$(ls "$placeholder_dir" | egrep "jpeg|jpg|png|gif" -c )
        if [ $hasimgs -lt 1 ]; then
            if [ ! -f "$placeholder_img" ];then
                echo "$DEFAULT_COVER" | base64 --decode > "$cachedir/default_cover.png"
                placeholder_img="$cachedir/default_cover.png"
                placeholder_dir=""      # the directory didn't have images
            fi
        else
            placeholder_img=""
        fi
    else
        if [ ! -f "$placeholder_img" ];then
            echo "$DEFAULT_COVER" | base64 --decode > "$cachedir/default_cover.png"
            placeholder_img="$cachedir/default_cover.png"
        fi
    fi

    # Logic here - if there's a placeholder directory with png or jpg in it, 
    # use that.  If not, see if there's a specific placeholder image. If not,
    # then output one.

}

##############################################################################
# Show help on cli
##############################################################################

display_help() {
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
}

##############################################################################
# Big updating artist function
##############################################################################

update_artist() {
    
    cacheartist=$(printf "%s/%s-artist.jpg" "$cachedir" "$EscapedArtist")
    cachecover=$(printf "%s/%s-%s-album.jpg" "$cachedir" "$EscapedArtist" "$EscapedAlbum")    

    ######################################################################
    #  Artist image
    ######################################################################
    if [[ ! -f "$cacheartist" ]] ;then
       

        if [ -z "$IMG_URL" ];then    
            API_URL="https://api.deezer.com/search/artist?q=$EscapedArtist" && API_URL=${API_URL//' '/'%20'}
            IMG_URL=$(curl -s "$API_URL" | jq -r '.data[0] | .picture_big ')
        
            #deezer outputs a wonky url if there's no image match, this checks for it.
            # https://e-cdns-images.dzcdn.net/images/artist//500x500-000000-80-0-0.jpg
            check=$(awk 'BEGIN{print gsub(ARGV[2],"",ARGV[1])}' "$IMG_URL" "//")
            if [ "$check" != "1" ]; then
                IMG_URL=""
            fi
        fi

        if [ ! -z "$LastfmAPIKey" ] && [ -z "$IMG_URL" ];then  # deezer first, then lastfm
            METHOD=artist.getinfo
            API_URL="https://ws.audioscrobbler.com/2.0/?method=$METHOD&artist=$EscapedArtist&api_key=$LastfmAPIKey&format=json" && API_URL=${API_URL//' '/'%20'}
            IMG_URL=$(curl -s "$API_URL" | jq -r ' .artist | .image ' | grep -B1 -w "extralarge" | grep -v "extralarge" | awk -F '"' '{print $4}')            
        fi           
        
        wget -q "$IMG_URL" -O "$tempartist"
        bob=$(file "$tempartist" | head -1)  #It really is an image
        sizecheck=$(wc -c "$tempartist" | awk '{print $1}')
        if [[ "$bob" == *"image data"* ]];then
            if [ "$sizecheck" != "4195" ];then
                convert "$tempartist" "$cacheartist"
                rm "$tempartist"
            fi
        fi
        rm "$tempartist"
    fi
 
    
}

##############################################################################
# Big updating cover function
##############################################################################

update_cover() {

    IFS=$'\t' mpd_array=( $(mpc --format "\t%artist%\t%album%\t%file%\t") );
    isPlaying=$(echo "${mpd_array[3]}" | awk -F ']' '{print $1}' | grep -e '^\[p' -c)

    if [ "$isPlaying" -gt 0 ];then
        rm -f "$cachedir"/nowplaying.album.jpg
        SongFile=$(echo "$MusicDir/${mpd_array[2]}")
        AlbumDir=$(dirname "$SongFile")
        ##########################################################################
        # Test for existing cache
        ##########################################################################
        EscapedArtist=$(echo "${mpd_array[0]}" | sed -e 's/[/()&]//g')
        EscapedAlbum=$(echo "${mpd_array[1]}" | sed -e 's/[/()&]//g')
        cacheartist=$(printf "%s/%s-artist.jpg" "$cachedir" "$EscapedArtist")
        cachecover=$(printf "%s/%s-%s-album.jpg" "$cachedir" "$EscapedArtist" "$EscapedAlbum")

    
        update_artist

        if [[ ! -f "$cachecover" ]] ;then

            ##########################################################################
            # Get local cover art first
            ##########################################################################
            CoverImage=$(echo "$AlbumDir/folder.jpg")
            if [ ! -f "$CoverImage" ];then
                CoverImage=$(echo "$AlbumDir/cover.jpg")
                if [ ! -f "$CoverImage" ];then
                    CoverImage=$(echo "$AlbumDir/folder.png")
                    if [ ! -f "$CoverImage" ];then
                        CoverImage=$(echo "$AlbumDir/cover.png")
                        if [ ! -f "$CoverImage" ]; then
                            TempString=$(ls "$AlbumDir" | egrep "jpeg|jpg|png|gif" | head -n 1)
                            CoverImage=$(echo "$AlbumDir/$TempString")
                        fi
                    fi
                fi
            fi
            ##########################################################################
            # Attempt to extract cover art from MP3 if not in musicdir
            ##########################################################################
            
            if [ ! -f "$CoverImage" ];then
                ffmpeg -i "$SongFile" $tempcover -y &> /dev/null
                STATUS=$?
                # Check if the file has a embbeded album art
                if [ $STATUS -eq 0 ];then
                    CoverImage=$(echo "$tempcover")
                fi
            fi
            ##########################################################################
            # Attempt to get coverart from CoverArt Archive or Deezer
            ##########################################################################
            MBID=""
            IMG_URL=""
            API_URL=""   
            
            if [ ! -f "$CoverImage" ];then
                MBID=$(ffmpeg -i "$SongFile" 2>&1 | grep "MusicBrainz Album Id:" | awk -F ': ' '{print $2}')
                if [ "$MBID" = '' ] || [ "$MBID" = 'null' ];then
                    API_URL="http://api.deezer.com/search/autocomplete?q=${mpd_array[0]}-${mpd_array[1]}" && API_URL=${API_URL//' '/'%20'}
                    IMG_URL=$(curl -s "$API_URL" | jq -r '.playlists.data[0] | .picture_big')
                else
                    API_URL="http://coverartarchive.org/release/$MBID/front"
                    IMG_URL=$(curl "$API_URL" | awk -F ': ' '{print $2}')
                fi
                
                if [ "$IMG_URL" = '' ] || [ "$IMG_URL" = 'null' ];then
                    echo "Not on CoverArt Archive or Deezer"
                else
                    # I don't know why curl hates me here.
                    #curl -o "$tempcover" "$IMG_URL"
                    wget -q "$IMG_URL" -O "$tempcover"
                    if [ -f "$tempcover" ];then
                        CoverImage=$(echo "$tempcover")
                    fi
                fi
            fi
            ##########################################################################
            # Copy our found file to the cache
            ##########################################################################
            if [[ ! -f "$cachecover" ]] ; then
                if [ -f "$CoverImage" ];then
                
                    # use convert instead of copy here so it doesn't matter if it
                    # downloaded/found a png or jpg or jpeg
                    convert "$CoverImage" "$cachecover"
                    convert "$CoverImage"  -resize "$display_size" "$cachedir"/nowplaying.album.jpg
                fi
            fi   
        else
            convert "$cachecover" -resize "$display_size" "$cachedir"/nowplaying.album.jpg
        fi
        if [ ! -f "$cachedir"/nowplaying.album.jpg ];then
            if [ ! -z "$placeholder_dir" ];then
                TempString=$(ls "$placeholder_dir" | egrep "jpeg|jpg|png|gif" | shuf | head -n 1)
                CoverImage=$(echo "$placeholder_dir/$TempString")
                convert "$CoverImage" -resize "$display_size" "$cachedir"/nowplaying.album.jpg
            else
                phi=$(which imgholder.sh)
                if [ -f "$phi" ];then
                    bob=$($phi -p picsum -o "$tempcover" )
                    if [ -f "$tempcover" ];then
                        convert "$tempcover" -resize "$display_size" "$cachedir"/nowplaying.album.jpg
                    else
                        convert "$tempcover" -resize "$display_size" "$cachedir"/nowplaying.album.jpg
                    fi
                fi
            fi
        fi
    fi
}




pre_exit() {
	# Get the proccess ID of vindauga and kill it.
    # We are dumping the output of kill to /dev/null
    # because if the user quits sxiv before they
    # exit vindauga, an error will be shown
    # from kill and we dont want that
    if [ -f /tmp/sxiv.pid ];then
        kill -9 $(cat /tmp/sxiv.pid) &> /dev/null
        rm /tmp/sxiv.pid
    fi
    if [ -f /tmp/vconky.pid ];then    
        kill -9 $(cat /tmp/vconky.pid) &> /dev/null
        rm /tmp/vconky.pid
    fi
}

killing() {
    
pre_exit
VPID=$(cat /tmp/vindauga.pid)
rm /tmp/vindauga.pid
kill -9 "$VPID" &> /dev/null

exit
}

main() {

	# Flag to run some commands only once in the loop
	FIRST_RUN=true

	while true; do
        
		update_cover
        if [ ! -f "$cachedir"/nowplaying.album.jpg ];then
            convert "$placeholder_img" -resize "$display_size" "$cachedir"/nowplaying.album.jpg
        fi
        
        if [ "$NoSXIV" = "false" ];then
            
            # Resetting SXIVPID if it tries to scroll *just* as we change 
            # covers. You will want to set a fixed position in your rc.xml
            if [ ! -z "$SXIVPID" ];then
                if ! ps -p "$SXIVPID" > /dev/null 
                then
                    FIRST_RUN=true
                fi
            fi
            
            if [ $FIRST_RUN == true ]; then
                FIRST_RUN=false
                # Display the album art using sxiv
                geometrystring=$(printf "%sx%s+%s+%s" "$display_size" "$display_size" "$XCoord" "$YCoord")
                sxiv -g "$geometrystring" -b "$cachedir"/nowplaying.album.jpg -S 2 -N "vindauga" &
                echo $! >/tmp/sxiv.pid
                SXIVPID=$(echo $!)
			fi
			# Save the process ID so that we can kill
			# sxiv when the user exits the script

        else
            if [ "$DynamicConky" = "true" ]; then

                # Resetting Conky if need be
                if [ ! -z "$VCONKYPID" ];then
                    if ! ps -p "$VCONKYPID" > /dev/null 
                    then
                        FIRST_RUN=true
                    fi
                fi
                if [ $FIRST_RUN == true ]; then
                    FIRST_RUN=false 
                    conky -c "$ConkyFile" &
                    echo $! >/tmp/vconky.pid
                    VCONKYPID=$(echo $!)

                fi
            fi
		fi

        if [ "$RunOnce" = "true" ];then
            break
        fi

		# Waiting for an event from mpd; play/pause/next/previous
		# this is lets vindauga use less CPU :)
		mpc idle &> /dev/null
   done
}


while [ $# -gt 0 ]; do
option="$1"
    case $option
    in
    -c) RunOnce="true"
    shift ;;   
    -h) display_help
    exit
    shift ;;         
    -z) DynamicConky="true"
    shift ;;      
    -y) NoSXIV="true"
    shift ;;       
    -k) killing
    shift ;;    
    esac
done

echo "$$" > /tmp/vindauga.pid

init
# Disable CTRL-Z because if we allowed this key press,
# then the script would exit but, sxiv would still be
# running
trap "" SIGTSTP

trap pre_exit EXIT
main
