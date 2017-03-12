# Bits and pieces taken from other people's bashrc files on andrew afs

export MODULE_NAME="andrew_util"
export MODULE_DEPS=()

module_exec() {

mesg n

afsperms(){ find $1 -type d -exec fs sa {} $2 $3 \; ; }
get_cs_afs_access() {
  # Script to give a user with an andrew.cmu.edu account access to cs.cmu.edu
  # See https://www.cs.cmu.edu/~help/afs/cross_realm.html for information.

  # Get tokens. This might create the user, but I'm not sure that that's
  # reliable, so we'll also try to do pts createuser.
  aklog cs.cmu.edu

  pts createuser $(whoami)@ANDREW.CMU.EDU -cell cs.cmu.edu 2>&1 | grep -v "Entry for name already exists"

  aklog cs.cmu.edu

  echo "Be sure to add aklog cs.cmu.edu & to your ~/.bashrc"
}
}
export module_exec

