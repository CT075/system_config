#!/usr/bin/zsh

# Main configuration file for a host (andrew AFS)

HOST_FILES=( "aliases.sh" "scripts.sh" )
export HOST_FILES

# for various CMU classes, etc
export PATH=$PATH:/afs/andrew/course/15/122/bin
export PATH=$PATH:/usr/lib/smlnj/bin
export PATH=$PATH:/afs/andrew/course/15/150/bin
export PATH=$PATH:/afs/cs/academic/class/15210-s17/mlton-spoonhower/build/bin
export PATH=$PATH:/usr/local/depot/ispc-v1.9.1-linux

# prompt/etc

setopt PROMPT_SUBST
precmd() { curDir=`pwd | sed -e "s!$HOME!~!" | sed -re "s!([^/])[^/]+/!\1/!g"` }
PROMPT='%D{[%H:%M:%S]}%F{yellow}%n%F{default} at %F{green}%m%f%F{default}$ '
RPROMPT='%F{red}$curDir'

# Allow us to use github properly
unset SSH_ASKPASS

