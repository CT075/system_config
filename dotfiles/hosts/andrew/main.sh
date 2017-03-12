#!/usr/bin/zsh

# Main configuration file for a host (andrew AFS)

HOST_FILES=( "aliases.sh" "scripts.sh" )
export HOST_FILES

# for various CMU classes, etc
export PATH=$PATH:/afs/andrew/course/15/122/bin
export PATH=$PATH:/usr/lib/smlnj/bin

# prompt/etc
PROMPT='%D{[%H:%M:%S]}%F{yellow}%n%F{default}@%F{green}%m%f%F{default}:%(4~|%-1~/.../%2~|%3~)$ '

