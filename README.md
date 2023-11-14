# vindauga

Display album art or display embedded (or folder-based) album art using a bash script. Massively simplified.

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

`vindauga` is a program that finds the album art for the currently playing song 
in `audacious` or `mpd`, and then displays it in a little window or as part of 
a `conky` display.

`vindauga` now loops on a timer. 
it looks at the currently playing track from `audacious` first (because that's always local) 
and if that's not running, then `mpd`. It then looks in the music directory to find 
either `folder.jpg` or `cover.jpg`, and puts that in a cache directory for reading 
by conky or what have you. 


If *that* doesn't exist, then it decodes a built in default album image to 
the cache directory.

At that point, `sxiv` or `conky` can display the image.

`vindauga` means "window".

All the album-art *seeking* functionality should be found with `f_fixer_covers`, as 
outlined in [this blog post](https://ideatrash.net/sd d ;sdlkfjasdlfj ). 


## 2. License

This project is licensed under the MIT license. For the full license, see `LICENSE`.

## 3. Prerequisites

 * `imagemagick` command-line tool for parsing string data. `imagemagick` can be found on major Linux distributions.
 * `mpc` command-line tool for controlling mpd. `mpc` can be found on major Linux distributions.
 * `audtool` command-line tool for audacity. 

## 4. How to use


 * To run it once (for example, from within a `conky` configuration), execute `vindauga.sh -c` . Note that this is almost certainly less efficient than running it as a daemon.
 * To not call `sxiv`, execute `vindauga -y`.
 * To invoke vindauga's control of its conky window, execute `vindauga -z` - though realistically you should probably `vindauga -y -z`.

For example, as I use the conky interface, I have two keybinds.  One calls `vindauga -y -z`.  That starts vindauga and the conky interface. The other calls `vindauga -k` and kills the process efficiently.  You can even do this in a single script. For example, a single binding that calls `vindauga_toggle.sh` will start the conky process and daemon, and a second run of it will turn it off.

### MPD Hosts
    
It assumes your music directory is in `${HOME}/Music`, that your album art is 
named either `cover.jpg` or `folder.jpg` and that `mpc` is already 
set up correctly. 

It will attempt to use the environment variable `MPD_HOST`, and 
if it is not found, will examine ${HOME}/.bashrc to see if it is set there (if a 
non-login shell) and set it for the program. If you have a password set for MPD, 
you *must* use `MPD_HOST=Password@host` for it to work.

It will put the current cover in `${XDG_CACHE_HOME}/vindauga/nowplaying.album.png` 
after making the corners of the cover rounded. If you are also using [yadshow](https://link.to.yadshow),
it will symlink it so the two directories point to the same location to avoid duplicated effort.


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
