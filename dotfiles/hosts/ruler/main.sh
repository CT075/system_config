#!/usr/bin/zsh

# Main configuration file for a host (lancer)
# Mostly just a skeleton file listing host-specific scripts and various other
# useful exports

export HOST_FILES=( aliases.sh )
export SMLNJ_HOME="/usr/lib/smlnj"
export DEVKITARM="/opt/devkitpro/devkitARM"
export PYTHONPATH="/home/cam/System/spaCy"
export PATH=$PATH:/home/cam/.local/bin/:/home/cam/sys_base/scripts/bask/bin:/home/cam/bin
export EDITOR=nvim
export VISUAL=nvim

eval `opam config env`

export SRC=/home/cam/Documents/src

function inittex () {
  name=$1
  if [ -z $name ]
  then
    echo "missing file name"
  fi
  cp -r $SRC/texformat $name
  sed -i s/\{fname\}/$name.tex/g $name/Makefile
  sed -i s@\{texpath\}@"$SRC/latex"@g $name/Makefile
  mv $name/template.tex $name/$name.tex
}

# for fe8u decomp
export LOCAL_PREFIX="tools/binutils/bin/"

