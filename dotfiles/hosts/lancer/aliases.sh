export MODULE_NAME="lancer_aliases"
export MODULE_DEPS=()

module_exec() {
  alias pacman="sudo pacman"
  alias sml="rlwrap sml"
  alias ll="ls -l"
  alias la="ls -a"
  alias rebootwifi="sudo systemctl restart wpa_supplicant; sudo systemctl restart NetworkManager"
}

