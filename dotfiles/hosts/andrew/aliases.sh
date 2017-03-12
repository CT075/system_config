export MODULE_NAME="andrew_aliases"
export MODULE_DEPS=()

module_exec() {
  alias killz='killall -9 '
  alias hidden='ls -a | grep "^\..*"'
  alias rm='rm -v'
  alias cp='cp -v'
  alias mv='mv -v'
  alias shell='ps -p $$ -o comm='
  alias sml='rlwrap sml'
  alias math='rlwrap MathKernel'
  alias coin='rlwrap coin'

  alias ll='ls -l'
  alias la='ls -a'

  alias cc='gcc -Wall -W -ansi -pedantic -O2 '
  alias valgrind-leak='valgrind --leak-check=full --show-reachable=yes'
}
export module_exec

