# My dotfiles

This dir contains the dotfiles for my system(s)

## Requirements

Ensure you have the following installed on your system:

### Git

```
brew install git
```

### Stow
```
brew install stow
```

### RipGrep

```
brew install ripgrep
```

### Obsidian
```
install via searching for on google
```

### fzf
```
brew install fzf
```

### tmux
```
brew install tmux
```

### zoxide
```
brew install zoxide
```

### direnv
```
brew install direnv
```
### pyenv
```
brew install pyenv
```

### Terminal emulator

Either one works with these dotfiles; both configs use the coolnight palette.

wezterm (config: `.wezterm.lua` + `.config/wezterm/`, adds a tab-bar status HUD):
```
brew install --cask wezterm
```

Ghostty (config: `.config/ghostty/`, see its README for what does not port
from wezterm -- mainly the status HUD, since Ghostty has no scripting API):
```
brew install --cask ghostty
```

The HUD readouts themselves are terminal-agnostic (`hud`, `pi-usage`,
`term-dash` in `bin/`); tmux draws them in its status bar, so they show up in
whichever terminal you use.

## Installation

First, check out the dotfiles repo into your $HOME directory using git

```
$ git clone git@github.com/coopdloop/dotfiles.git
$ cd dotfiles
```

Please make sure the scripts in bin are executable by owner or respective group:
```
chmod 700 ./bin/*
```

Please read this documentation if using tmux:
```
https://github.com/tmux-plugins/tpm
```

Nerd font:

```
brew install font-meslo-lg-nerd-font
```

then use GNU stow to create symlinks

```
$ stow .
```

Re-run `stow --restow .` after adding files to the repo (it does not notice new
files on its own). `.stowrc` keeps pi's scratch dir and VCS junk out of `$HOME`.

If stow ever fails with `bad interpreter: /usr/bin/perl5.30`, its shebang points
at a perl that no longer exists -- `brew reinstall stow` fixes it (or run
`perl /opt/homebrew/bin/stow --restow .` as a stopgap).
