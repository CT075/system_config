# Making $mod+w/e/r follow the monitors that are actually there

Status: planned, not built. Written 2026-09-21, alongside the hotplug work in
`scripts/display` and `scripts/present`.

## What's there now

`dotfiles/hosts/pretender/sway.conf` ends with three literals:

```
set $out_left  "Dell Inc. DELL P2422H D599FQ3"
set $out_main  "Dell Inc. DELL P2422H D599FQ3"
set $out_right "AU Optronics 0xF99A Unknown"
```

and `config.d/64-bindings-output.conf` spends them six times, three for
`focus output` and three for `move workspace to output`. Sway expands them once,
at parse time, so the bindings are frozen to whatever panels the host file
happened to name on the day it was written.

The file already says why:

> Sway can't be asked which panel is physically leftmost, so the host says.

That was true of the question as asked. It isn't true of the question sway can
answer, which is where each output currently sits. `swaymsg -t get_outputs`
returns a `rect` per output, in logical pixels, after scale and transform. Sort
by `rect.x` and "leftmost" falls out.

## Why it needs fixing

Three failure modes, in increasing order of annoyance.

Undocked, `$out_left` and `$out_main` both name a monitor that isn't plugged in.
`$mod+w` and `$mod+e` become no-ops, sway logs a warning about an unknown output
per press, and the only key that works is `$mod+r`.

Docked at an unfamiliar desk, or plugged into a classroom projector, none of the
three name the new panel. You can see the output, you can't focus it, and you
can't throw a workspace onto it without going to the mouse.

And the host file carries a hand-sync obligation with `hosts/pretender/kanshi`,
which `scripts/init-sway-host` prints as a to-do at the end of every run:

> still to fill in by hand:
>   $out_left / $out_main / $out_right, and the kanshi profiles.

Two files that have to agree, with nothing checking that they do.

## What "main" means, which is the whole problem

`left` and `right` are geometry and the compositor knows them. `main` isn't.

On pretender docked, main is the Dell: it's at x=0, and it's the one with the
keyboard in front of it. Undocked, main is the laptop panel. So main is neither
"the internal display" nor "the leftmost" nor "the biggest" (eDP-1 is
1920x1200, the Dell is 1920x1080, so biggest picks wrong). It's a preference,
and a preference has to be declared.

The declaration can be smaller than three literals, though. One ordered list per
host:

```
set $out_preference "Dell Inc. DELL P2422H D599FQ3" eDP-1
```

read as "main is the Dell when the Dell is here, otherwise the laptop, otherwise
whatever's leftmost". Docked and undocked both come out right, and the classroom
case degrades to the fallback instead of to nothing.

## The design

A script, `scripts/focus-output`, symlinked to `~/.config/sway/focus-output` by
`link-sway` the way `wallpaper` and `notifyd` already are.

```
focus-output <left|main|right> [--move] [preference...]
```

It reads `swaymsg -t get_outputs`, keeps the entries with `.active == true`,
sorts them by `.rect.x`, and resolves the slot:

- `left` is the first
- `right` is the last
- `main` is the first name in `preference...` that matches a connected output,
  by connector name or by `make model serial`, falling back to the first

Then it runs `focus output <name>`, or `move workspace to output <name>` with
`--move`. Matching an output by its description means quoting a string with
spaces through swaymsg, which `hosts/pretender/kanshi` already has to care
about; the script should target `.name` (the connector) once it has resolved
which output it means, since by then the drift that made descriptions necessary
doesn't matter any more.

Sway substitutes variables at parse time, so the preference list reaches the
script as ordinary arguments:

```
bindsym $mod+w exec ~/.config/sway/focus-output left
bindsym $mod+e exec ~/.config/sway/focus-output main $out_preference
bindsym $mod+r exec ~/.config/sway/focus-output right

bindsym $mod+Shift+w exec ~/.config/sway/focus-output left --move
bindsym $mod+Shift+e exec ~/.config/sway/focus-output main --move $out_preference
bindsym $mod+Shift+r exec ~/.config/sway/focus-output right --move
```

`scripts/display`, built for the hotplug work, already enumerates and sorts
outputs to decide where to put an unknown panel. That enumeration is the same
query with the same sort, so whichever of the two gets written second should
lift it rather than write it again. A shared `scripts/lib/outputs.sh` sourced by
both is the obvious shape if it grows past a single jq expression.

## What changes

- New: `scripts/focus-output`.
- `dotfiles/sway/config.d/64-bindings-output.conf`: six bindings rewritten, and
  the comment about the host asserting geometry deleted, since it stops being
  true.
- `dotfiles/hosts/*/sway.conf`: `$out_left`/`$out_main`/`$out_right` replaced by
  one `$out_preference`. Nine host files, but only the ones with a `sway.conf`
  actually matter; `pretender` is currently the only one.
- `scripts/init-sway-host`: generate `set $out_preference eDP-1` instead of the
  three `TODO` placeholders, and drop `$out_*` from the closing "still to fill
  in by hand" message. The kanshi profiles stay on that list.
- `scripts/link-sway`: one more `link` line.

## Things to decide before building

Whether `$mod+e` should keep meaning "main" at all. The alternative is to make
it "the next output to the right, wrapping", which needs no host hook whatsoever
and scales past three heads, at the cost of the key no longer being an absolute
destination. That's a real ergonomic change and not obviously an improvement, so
the plan above keeps `main`.

What a single-output machine should do. Three keys that all resolve to the same
panel is the current behaviour and it's fine, but the script should exit quietly
rather than calling `focus output` on the output that's already focused.

## Testing

The failure this fixes only shows up with hardware attached, so:

1. Undocked, all six bindings should resolve to eDP-1 and do nothing visible.
2. Docked, `$mod+w`/`$mod+e` should reach the Dell and `$mod+r` the laptop, which
   is exactly what the literals do today. This is the regression check.
3. Plugged into anything else, all six should reach something, with `main`
   landing on the fallback.

`swaymsg -t get_outputs | jq -r '.[] | select(.active) | "\(.rect.x)\t\(.name)"' | sort -n`
is the one-liner for checking what the script should be seeing.
