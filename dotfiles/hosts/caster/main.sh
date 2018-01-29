#!/usr/bin/zsh

# Main configuration file for a host (lancer)
# Mostly just a skeleton file listing host-specific scripts and various other
# useful exports

export HOST_FILES=( aliases.sh )
export SMLNJ_HOME="/usr/lib/smlnj"

eval `opam config env`

