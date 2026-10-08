# dotfiles and other things

by Cameron Wong (cam@camdar.io)

Inspired heavily by [Jake Zimmerman](https://github.com/jez/dotfiles).

## Installation

One way or another, get scripts/init onto the host system. Running that script
should clone this repo onto the system and make all the necessary symlinks.

On a sway host, two more steps, both once per clone and neither able to
bootstrap itself:

    scripts/link-sway      # symlinks ~/.config/sway, i3status, kanshi, swaync
    scripts/install-hooks  # core.hooksPath -> hooks/, so pulls relink

After that the linker reruns itself: it links the `~/.config/sway/environment`
that start-sway sources before launching sway, and hooks/ reruns it on every
pull, merge and branch switch. A link added by a later commit lands without
anyone remembering it needs to.

Note that this isn't really designed for use by people that aren't me, so just
cloning the repo and running with it is probably not going to work.
