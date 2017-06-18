#!/usr/bin/zsh

# Main configuration file for a host (andrew AFS)

HOST_FILES=( "aliases.sh" )
export HOST_FILES

# prompt/etc
setopt PROMPT_SUBST
precmd() { curDir=`pwd | sed -e "s!$HOME!~!" | sed -re "s!([^/])[^/]+/!\1/!g"` }

PROMPT='%D{[%H:%M:%S]}%F{yellow}%n%F{default} at %F{green}%m%f%F{default}$ '
RPROMPT='%F{red}$curDir'

