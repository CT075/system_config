export MODULE_NAME="rider_aliases"
export MODULE_DEPS=()

module_exec() {
  alias pacman="sudo pacman"
  alias sml="rlwrap smlnj"
  alias ocaml="rlwrap ocaml"
  alias ll="ls -l"
  alias la="ls -a"
  alias rebootwifi="sudo systemctl restart wpa_supplicant; sudo systemctl restart NetworkManager"
  alias arm-gcc="/opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc"
  alias arm-gcc2="/opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc-5.3.0"
  alias arm-as="/opt/devkitpro/devkitARM/bin/arm-none-eabi-as"
  alias ghci="stack ghci"
  alias runhaskell="stack runhaskell"
}

