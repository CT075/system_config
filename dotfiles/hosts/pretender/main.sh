export HOST_FILES=(  )

export FZF_DEFAULT_COMMAND='rg --files --hidden'

export PATH=$PATH:/home/cam/.local/bin
source "$HOME/.cargo/env"
source "$HOME/.ghcup/env"

export DEVKITPRO=/opt/devkitpro
export DEVKITARM=${DEVKITPRO}/devkitARM
export PATH=$PATH:${DEVKITPRO}/tools/bin
export PATH=$PATH:${DEVKITPRO}/devkitARM/bin
export PATH=$PATH:$HOME/.idris2/bin:$HOME/.pack/bin

export PATH=$PATH:/home/cam/bin
export PATH=$PATH:/home/cam/.local/share/coursier/bin
source /home/cam/.local/share/copper/cu-setup.sh

alias in='task add +in'

tickle () {
    deadline=$1
    shift
    in +tickle wait:$deadline $@
}
alias tick=tickle
alias think='tickle +1d'
