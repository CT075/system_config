# Stylus

Userstyles for the Stylus extension in Vivaldi, one `.user.css` per style in
`styles/`. The repo is the source of truth and Stylus pulls from it. Edits go
in a file here, never in the Stylus editor.

Stylus itself keeps styles in the extension's IndexedDB, which nothing outside
the browser can read or write. What links that to this directory is the URL you
install a style from. Open `file:///home/cam/sys_base/config/stylus/styles/whatever.user.css`
in Vivaldi, Stylus takes over the page with an install button, and it keeps
that file URL as the style's update source. "Check for updates" then refetches
this file.

`file:` is allowed there, and Stylus treats it as localhost and skips its usual
same-version check, so an edit lands without needing a `@version` bump.

## The one thing not to do

Don't put `@updateURL` in a file here.

The usercss metadata parser only accepts `http` and `https` for it, so a
`file:` URL is a parse error and the install fails outright with "Invalid URL
protocol". An `https` one parses fine and is worse: it overrides the URL you
installed from, so Stylus goes back to userstyles.world for updates and
overwrites your edits with upstream's copy on the next check.

`scripts/stylus-sync` strips the line if one turns up, which it does whenever
you paste a style in from somewhere else.

## One-time setup

Open `vivaldi://extensions`, find Stylus, and check **Allow access to file
URLs**. Nothing below resolves without it, installing or updating.

## Setting up on a new machine

`scripts/stylus-sync` prints an install URL per style:

```
$ scripts/stylus-sync
file:///home/cam/sys_base/config/stylus/styles/selection-colours.user.css
```

Open each one in Vivaldi and install. That stays manual, Stylus has no API for
it. Nothing here bakes in an absolute path, so a checkout somewhere else just
prints different URLs.

## Bringing existing styles in

Stylus > Manage > Export writes a JSON blob of everything it has.
`scripts/stylus-import` splits that into files:

```
$ scripts/stylus-import ~/System/stylus-2026-09-20-19-05.json
```

Usercss styles come out verbatim minus their `@updateURL`. Older section-based
styles get a metadata block synthesised over their rules, since Stylus won't
install a file without `@name`, `@namespace` and `@version`. Element 0 of the
export is Stylus's own settings rather than a style, and gets dropped.

Filenames come from the style's name, or its Stylus rename if it has one. A
name that leaves nothing behind once it's slugged, `?` say, falls back to the
first domain the style matches and then to Stylus's internal id. Rename the
file to whatever you'd rather call it.

Then delete the originals from Stylus's Manage page and reinstall from the URLs
`scripts/stylus-sync` prints. Skipping the delete leaves two copies of every
style fighting over the same pages.

## Adding a style

Copy `template.user.css` into `styles/`, write it, run `scripts/stylus-sync`,
open the URL it prints.

## Changing a style

Edit the file, then hit "Check for updates" on that style in Stylus. There's a
global one on the Manage page that does all of them at once.

## What doesn't sync

Whether a style is enabled, and any `@var` values configured through Stylus's
UI. Both live in the extension, not in the file. Stylus's own sync (Manage >
Sync, backed by Dropbox, OneDrive or WebDAV) is the thing that carries those,
and it composes fine with this: it syncs the installed copies, this repo owns
the source.
