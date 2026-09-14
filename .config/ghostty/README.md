# Ghostty

coolnight port of `~/.wezterm.lua`. Everything else in this repo (`.zshrc`,
`.tmux.conf`, `bin/`, `.config/nvim`) is terminal-agnostic and needs no changes.

## Set up

```bash
brew install --cask ghostty
cd ~/dotfiles
stow --restow .          # links .config/ghostty -> ~/.config/ghostty
```

Then launch Ghostty. `Cmd+Shift+R` reloads the config; `Cmd+Shift+,` opens it in
your default editor.

`--restow` matters: stow does not notice files you add to the repo later, and
`.stowrc` keeps junk (this repo's `.pi/tasks/`, VCS metadata) out of `$HOME`.
Because whole directories like `.config/ghostty` and `bin` are linked as one
symlink, edits *inside* them land in `$HOME` immediately — only new top-level
entries need a restow.

Verify what Ghostty actually parsed:

```bash
ghostty +show-config | grep -E 'theme|font-size|background-opacity'
ghostty +list-themes | grep -i coolnight
ghostty +list-fonts | grep -i meslo          # exact family name, if the font is missing
ghostty +list-keybinds | grep 'cmd+shift'    # check for collisions
```

## What ported, and what could not

| wezterm (`~/.wezterm.lua`)              | Ghostty (`config`)                                              |
| --------------------------------------- | --------------------------------------------------------------- |
| `config.colors` (coolnight)             | `themes/coolnight`, selected with `theme = coolnight` — **no extension**, Ghostty treats the name as a literal filename (`ghostty +list-themes` proves it) |
| `font` / `font_size`                    | `font-family` / `font-size`                                     |
| `window_background_opacity` + blur      | `background-opacity` + `background-blur`                        |
| `window_padding`                        | `window-padding-x` / `window-padding-y = 8, 4`                  |
| `default_cursor_style = SteadyUnderline`| `cursor-style = underline`, `cursor-style-blink = false`        |
| `inactive_pane_hsb` (dim unfocused)     | `unfocused-split-opacity` + `split-divider-color`               |
| `use_fancy_tab_bar`                     | `macos-titlebar-style = tabs` (tabs merged into the titlebar)   |
| `config.background` + auto-picked image | `background-image = ?backgrounds/coolnight.png` (fixed name — see `backgrounds/README.md`) |
| `set_environment_variables` PATH        | dropped: `.zshrc` already exports pyenv/homebrew/`~/bin`        |
| `CMD+SHIFT+U` / `CMD+SHIFT+D` scratch tabs | `keybind … = text:…\n` — types the command into the current terminal (Ghostty cannot spawn a command in a new tab) |
| `animation_fps`, `cursor_blink_ease_*`  | no equivalent (Ghostty does not animate the cursor blink)       |
| **status HUD** (`update-status` Lua)    | **not here** — Ghostty has no status bar and no scripting. Moved to `~/bin/hud`, drawn by tmux |

### The HUD, relocated

The wezterm bar (pi tokens/cost on the left; CPU · RAM · disk · branch · clock on
the right) is a Lua callback drawing into the tab bar. Ghostty's config is
declarative, so the readouts moved to a script instead:

```bash
~/bin/hud                      # CPU 86% █████░  RAM 12.4G █████░  DSK 17G/228G ███░░░  Mon 12:56
~/bin/hud --ansi branch cpu    # any subset, in colour
~/bin/hud --tmux …             # tmux #[fg=…] styles, for status-left/right
```

`.tmux.conf` already calls it in `status-right` next to `pi-usage --window`, so
**run tmux inside Ghostty and the whole HUD comes back** — in any terminal,
including wezterm's own tmux sessions. Same glyphs, bars and coolnight colours as
the Lua; segments are terser because that row is shared with the window list.

Prefer it in the prompt instead? `pi-usage --oneline` and `hud --ansi` both fit a
powerlevel10k segment, e.g. in `.zshrc`:

```bash
RPROMPT='$(~/bin/hud --ansi cpu ram disk clock)'   # cached scan, ~80ms
```

And `CMD+SHIFT+H` runs the HUD once in the current terminal (no tmux needed).

## Per-machine tweaks

`config` ends with `config-file = ?local.conf`. Create
`~/.config/ghostty/local.conf` (i.e. `dotfiles/.config/ghostty/local.conf`, it is
gitignored) for anything machine-specific — a different `font-size`, a laptop-only
`background-opacity`. Later files override earlier ones.

## Shared scripts

`pi-usage`, `term-dash` and the new `hud` live in this repo's `bin/`, which stow
links to `~/bin` and `.zshrc` puts on `$PATH` — so all three terminals call them
by plain name, and nothing references `~/.config/wezterm/bin/` any more. The
backgrounds folder stayed under `.config/wezterm/` (only the Lua scans it).

`pi-usage` now starts with `#!/usr/bin/env python3` instead of a pinned pyenv
path, so a pyenv version bump can no longer break the status bar.
