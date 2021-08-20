# vindauga

Download and display album art or display embedded (or folder-based) album art using a bash script; a largely rewritten fork of kunst

![vindauga logo](https://raw.githubusercontent.com/uriel1998/vindauga/master/vindauga.png "logo")

![Output example](https://raw.githubusercontent.com/uriel1998/vindauga/master/output.gif "Example output")

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [How to use](#4-how-to-use)
 5. [Album Art Cache](#5-album-art-cache)
 6. [Using With Conky](#6-using-with-conky)
 7. [Using With SXIV](#7-using-with-sxiv) 
 8. [TODO](#9-todo)

***

## 1. About

`vindauga` is a program (and probably daemon) that finds or extracts (if needed) 
the album art for the currently playing song in `mpd`, and then displays it in 
a little window or as part of a `conky` display.

It is a (largely rewritten) fork of [kunst](https://github.com/sdushantha/kunst) 
by Siddharth Dushantha. There were some behaviors of `kunst` that I wanted to 
fix and improve upon, so I created `vindauga`.  There is also a great debt to 
[this blog post](http://lmazy.verrech.net/2011/01/cover-art-with-conky-and-mpd/) 
by "Raphael" for the `conky` bits.

`vindauga` does not loop on a timer. Instead it waits for `mpd` to send a "player" 
event. When it receives a "player" event, it wakes up and takes action. This makes 
`vindauga` really lightweight as a daemon. 

When `vindauga` wakes up, it looks at the currently playing track from `mpd`. It 
then checks its own cache of album artwork (see below for details), then the 
music folder, then embedded artwork, then the CoverArt Archive (if the music 
has the MusicBrainz ID embedded), then Deezer. It can also use [sacad](https://github.com/desbma/sacad) as
an album art provider.

If none of those exist, it checks if there is a configured local directory 
with images in it designated as placeholder images. If that doesn't exist, it 
checks for a designated placeholder image. 

If that doesn't exist, it will use the optional `simple_placeholder_images` to 
download a nice picture from online and use that as a temporary album cover. 

If *that* doesn't exist, then it decodes a built in default album image to 
the cache directory.

At that point, `sxiv` or `conky` can display the image.

The filestructure in the cache is meant to be fairly straightforward and 
obvious so that the images may be used (if desired) with other programs.

`vindauga` means "window".


## 2. License

This project is licensed under the MIT license. For the full license, see `LICENSE`.

## 3. Prerequisites

### These may already be installed on your system.

 * `curl` command-line tool for getting data using HTTP protocol. `curl` can be found on major Linux distributions.
 * `wget` command-line tool for getting data using HTTP protocol. `wget` can be found on major Linux distributions.
 * `grep` command-line tool used for parsing downloaded XML data. `grep` can be found on major Linux distributions.
 * `sed` command-line tool for parsing string data. `sed` can be found on major Linux distributions.
 * `awk` command-line tool for parsing string data. `awk` can be found on major Linux distributions.
 * `ffmpeg` command-line tool for parsing string data. `ffmpeg` can be found on major Linux distributions.
 * `imagemagick` command-line tool for parsing string data. `imagemagick` can be found on major Linux distributions.

### You may have to install these

 * `base64` command-line tool for encoding/decoding data. `base64` can be found on major Linux distributions.
 * `mpc` command-line tool for controlling mpd. `mpc` can be found on major Linux distributions.
 * `mpd`, the music player daemon. `mpd` can be found on major Linux distributions.
 * `jq` command-line tool for parsing JSON data. `jq` can be found on major Linux distributions or on [GitHub](https://github.com/stedolan/jq)

### You do not have to choose all or any of these.

 * [Optional] `sacad`, the smart automatic cover downloader.  `sacad` is on [Github](https://github.com/desbma/sacad).
 * [Optional] `ionice`, to lower the io priority of the script. `ionice` can be found on major Linux distributions.
 * [Optional] `sxiv`, the Simple X Image Viewer, available in most major distributions or on [GitHub](https://github.com/muennich/sxiv)
 * [Optional] `conky`, a light-weight system monitor for X available in most major distributions or on [GitHub](https://github.com/brndnmtthws/conky)
 * [Optional] `simple_placeholder_images` to subsitute in generic images found online when cover art is not found. Available on [GitHub](https://github.com/uriel1998/simple_placeholder_images),[GitLab](https://gitlab.com/uriel1998/simple_placeholder_images), or my [personal repository](https://git.faithcollapsing.com/simple_placeholder_images)

## 4. How to use

 * As a daemon: Execute `vindauga.sh` from the terminal. It is safe to run it as `vindauga.sh &` and use the `-k` switch to kill a running vindauga process. 
 * If `ionice` is detected, it is automatically applied to the current script.
 * To run it once (for example, from within a `conky` configuration), execute `vindauga.sh -c` . Note that this is almost certainly less efficient than running it as a daemon.
 * To not call `sxiv`, execute `vindauga -y`.
 * To invoke vindauga's control of its conky window, execute `vindauga -z` - though realistically you should probably `vindauga -y -z`.
 * To kill an existing background `vindauga`, execute `vindauga -k`. This will kill both the instance of `sxiv` in use and the background script.

 For example, as I use the conky interface, I have two keybinds.  One calls `vindauga -y -z`.  That starts vindauga and the conky interface. The other calls `vindauga -k` and kills the process efficiently.  You can even do this in a single script. For example, a single binding that calls `vindauga_toggle.sh` will start the conky process and daemon, and a second run of it will turn it off.

### Multiple MPD Hosts
    
`vindauga` can handle watching two different MPD instances.  I have one for 
[streaming and whole-house audio](https://ideatrash.net/2020/06/weekend-project-whole-house-and-streaming-audio-for-free-with-mpd.html), 
and a second on my laptop.  In the ini file, I configured my *laptop* 
instance as *MPDHost1* and the remote instance as *MPDHost2*.  If 
MPDHost1 is running, that's what displays.  If it is *not* running, then 
MPDHost2 is shown (it's always on).  If I start playing on MPDHost1 again, 
`vindauga` will automatically switch back to showing MPDHost1.  It rechecks 
the *process* for the idle loop for both hosts every "interval" (set in the 
ini file) seconds. 

If MPDHost2 is not set, it just checks MPDHost1 by default.

### vindauga.ini

### ** NOTE **  The ini format has changed since version 0.9 

The file `vindauga.ini` goes in `$HOME\.config`. 

```
# Music Dir
musicdir=/home/USER/music
# Cache Dir
cachedir=/home/USER/.cache/vindauga
# Placeholder Image
placeholder_img=
# Placeholder Directory
placeholder_dir=/home/USER/vault/albumcovers
# Display Size
display_size=
#SXIV X position
XCoord=500
#SXIV Y position
YCoord=100
#Conkyfile Location
ConkyFile=/home/USER/.conky/vindauga_conkyrc
#Last FM API Key
LastfmAPIKey=
#MPD Hosts 
MPDHost1=password@localhost
MPDHost2=pass@remotehost
#WebCover Base
webcovers=
interval=
conkybin=

```

### ** NOTE **  The ini format has changed since version 0.9 

## 5. Album Art Cache

The cache - by default in `$HOME/.cache/vindauga` - stores the discovered and 
cached album art in the format:

`[ArtistName]-[AlbumName].album.jpg`

This is deliberately *very* similar to the way `Ario` and other programs store 
the information.

For example, a partial list of my cache is:

```
Aesthetic Perfection-Love Like Lies.album.jpg
Asking Alexandria-A Lesson Never Learned.album.jpg
Avatar-Hail the Apocalypse.album.jpg
Fear Factory-Demanufacture.album.jpg
Front Line Assembly-Echoes.album.jpg
In Flames-I, the Mask.album.jpg
Kidneythieves-Zerøspace.album.jpg
KMFDM-Naïve: Hell to Go.album.jpg
Ministry-ΚΕΦΑΛΗΞΘ.album.jpg
Nine Inch Nails-24.24.2.2527 [Deceased].album.jpg
Skinny Puppy-Mind: The Perpetual Intercourse.album.jpg
THE FEVER 333-STRENGTH IN NUMB333RS.album.jpg
Throbbing Gristle-The First Annual Report of Throbbing Gristle.album.jpg
外山雄三-Civilization V.album.jpg

```

When there is a special character - `/()&` - it is completely omitted in 
writing the cache filename. This is intentional behavior to minimize the 
number of times that the program chokes. (Hopefully zero!)

The album and artist image are obtained from Deezer or Last.fm (if you obtain a
last.fm [API key](https://www.last.fm/api) and put it in the config file) and 
stored in the cache directory.  If [sacad](https://github.com/desbma/sacad) is 
in your `$PATH` it will attempt to get album art using that provider.

If you use the `ffixer_covers.sh` file, it will softlink from the music directory. 
This is obviously superior in terms of space saved.

## 6. Using with Conky

I have enclosed a basic configuration for `conky` (as seen in the video above) 
that has the information and layout that I want. You can obviously incorporate 
this into your own conky or edit it to your aesthetic delight.  Editing `conky` 
configurations is well past the scope of this document.

See the file `vindauga_conkyrc` for the example.  It includes both the base image 
seen in the screenshot below as well as an XCF file if you wish to design your 
own.  If you have a newer version of conky, with the lua-style formatted config, 
use `vindauga_conkyrc_newformat` instead.

The conkyfile will have the MPD host and password settings dynamically changed 
(by `sed`) by `vindauga`! 

![Output example](https://raw.githubusercontent.com/uriel1998/vindauga/master/updated_vindauga_conky.png "Example output")

## 7. Using with SXIV

In `kunst`, the call to `sxiv` does not include the `-S 2` switch. On my Debian 
system, without that switch, `sxiv` does not change the image once loaded. 

Unfortunately, if `sxiv` tries to reload the image at the same time that a new 
one is being loaded, it aborts. There is a PID check built in to `vindauga` 
that relaunches `sxiv` if it's closed. If it is relaunched, it loads back to 
the default location (or location specified in the rc file).

### SXIV and OpenBox

I use this configuration with my OpenBox:

```
    <application class="Sxiv">
        <focus>yes</focus>
        <layer>above</layer>
        <decor>no</decor>
        <skip_pager>yes</skip_pager>
        <skip_taskbar>yes</skip_taskbar>
        <desktop>all</desktop>
    </application>  
```    

Or if you don't want to move it around, and have it be below other windows:

```
    <application class="Sxiv">
        <focus>no</focus>
        <layer>below</layer>
        <decor>no</decor>
        <skip_pager>yes</skip_pager>
        <skip_taskbar>yes</skip_taskbar>
        <monitor>1</monitor>        
        <position>
            <x>1075</x>
            <y>380</y>
        </position>        
        <desktop>all</desktop>
    </application>       
```

## 8. Todo

 * Write folder.jpg and cover.jpg to music directories, if desired.
 * Embed found album art, if desired.
 * Create script to retrieve artwork without or using `vindauga`
 * Incorporate makefile for those who want it?
 * Automatically softlink data for Ario / GMPC
 * Automatically softlink albumart for cantata
 * Plugin for file output
