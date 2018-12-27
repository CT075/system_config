#!/usr/bin/zsh

# Main configuration file for a host (lancer)
# Mostly just a skeleton file listing host-specific scripts and various other
# useful exports

export HOST_FILES=( aliases.sh )
export SMLNJ_HOME="/usr/lib/smlnj"
export DEVKITARM="/opt/devkitpro/devkitARM"
export PATH=$PATH:/home/cam/.local/bin/
export EDITOR=vim
export VISUAL=vim

eval `opam config env`

