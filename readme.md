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

## Installation

First, check out the dotfiles repo into your $HOME directory using git

```
$ git clone git@github.com/coopdloop/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```
