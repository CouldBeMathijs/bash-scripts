# A Few Bash Scripts
## clip.sh
Copies a file or output from a command to the clipboard.  
_Depends on_ `wl-copy` _when using Wayland, or_ `xclip` _when using X.org, also works over ssh_

## flake-update.
Pulls down the latest changes made on a nix flake.  
_Depends on_ `nix` `nh` `git` and `jq`

## topdf.sh
Generates pdf's for all .tex files in the current directory (but no subdirectories thereof).   
_Depends on_ `pdflatex` _(which is not installed in the flake by default, as it takes a few gigabytes of space if latex wasn't already installed)_

## updategit.sh
Replaces all old github repo URL's with URL's pointing to my new GitHub username.  
_Depends on_ `git`_, must be personalized before use_

## zipper.sh
Stores all C++ header and source files except main.cpp in a zip, for easy uploading to INGInious or BlackBoard.  
_Depends on_ `zip`

## ziptotar.sh
Replaces all .zip's with equivalent .tar.xz files from the directory the script is ran downwards, .tar.xz is more space efficient, but be careful as some programs store files in zips and you do not want to overwrite those!  
_Depends on_ `tar` `unzip`

## replace-every.sh
Replaces all instances of <argument1> with <argument2> within plaintext file contents and file/directory names for every file withing the folder <argument3>


---------------------------------------------------------

*Scripts may be added or removed over time\
All of these scripts are under GPLv3*
