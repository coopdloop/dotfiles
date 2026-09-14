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

`stow` from Homebrew is currently broken on this machine (its shebang asks for
`/usr/bin/perl5.30`, which no longer exists). Either reinstall it, or run it
through the system perl:

```bash
brew reinstall stow                          # fixes the shebang
perl /opt/homebrew/bin/stow --restow .       # works without reinstalling
```

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
| `config.colors` (coolnight)             | `themes/coolnight.conf`, selected with `theme = coolnight`       |
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
| **status HUD** (`update-status` Lua)    | **not possible** — Ghostty has no status bar and no scripting   |

### The HUD gap

The wezterm bar (pi tokens/cost on the left; CPU · RAM · disk · branch · clock on
the right) is a Lua callback drawing into the tab bar. Ghostty's config is
declarative, so that has to live somewhere that *can* run code:

- **tmux** — already partly done: `.tmux.conf` appends
  `pi-usage --window "#{pane_current_path}"` to `status-right`. Run tmux inside
  Ghostty and the pi half of the HUD comes along for free, in any terminal.
  The system half is a `status-right` segment away (`sysctl -n vm.loadavg`,
  `df -h /`, `date`).
- **zsh / powerlevel10k** — `pi-usage --oneline` is a one-liner by design, so it
  fits a prompt segment. Example right-prompt hook, if you want it in `.zshrc`:

  ```bash
  # pi usage in the right prompt (cheap: pi-usage caches its scan for 30s)
  RPROMPT='$(~/.config/wezterm/bin/pi-usage --oneline 2>/dev/null)'
  ```
- **on demand** — the `CMD+SHIFT+U` / `CMD+SHIFT+D` keybinds above.

## Per-machine tweaks

`config` ends with `config-file = ?local.conf`. Create
`~/.config/ghostty/local.conf` (i.e. `dotfiles/.config/ghostty/local.conf`, it is
gitignored) for anything machine-specific — a different `font-size`, a laptop-only
`background-opacity`. Later files override earlier ones.

## Shared scripts, honest caveat

`pi-usage` and `term-dash` are still invoked from `~/.config/wezterm/bin/`,
because that is where `.wezterm.lua` expects them. They are not wezterm-specific
— moving them to `bin/` (already on `$PATH` via `.zshrc`) would be the tidy
follow-up: update the `BIN` path in `.wezterm.lua`, then the two keybind lines
here and the `status-right` line in `.tmux.conf` become plain `pi-usage` /
`term-dash`.

`pi-usage` also hardcodes its interpreter
(`/Users/lariat/.pyenv/versions/3.12.3/bin/python3`); `#!/usr/bin/env python3`
would survive a pyenv version bump.
