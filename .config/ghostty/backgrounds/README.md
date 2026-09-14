# Ghostty backgrounds

Ghostty has no config-time directory scan (the config is not a programming
language), so this folder uses a **fixed filename** instead of wezterm's
"alphabetically first image wins":

```
~/.config/ghostty/backgrounds/coolnight.png
```

- PNG or JPEG only — `.webp` is **not** supported (unlike wezterm).
- `background-image = ?backgrounds/coolnight.png` in `../config` has a leading
  `?`, which means "optional": no warning if the file is missing, so the solid
  coolnight background is used.
- Relative paths in the config resolve against the config file's own directory,
  so `backgrounds/...` works whether Ghostty sees the stowed path or the real
  repo path.
- Per-split caveat: the image is drawn per-terminal, not per-window — heavy
  split users will see it repeated in each split.

To reuse the wezterm wallpaper — that repo keeps `mystic-city.webp` in git and
the PNG is local-only, so convert it once if you don't have it:

```bash
sips -s format png ~/.config/wezterm/backgrounds/mystic-city.webp \
     --out ~/.config/ghostty/backgrounds/coolnight.png
```

Tuning, all in `../config`:

- `background-image-opacity` — image alpha relative to the window opacity
  (default here `0.3`; raise for a more visible wallpaper)
- `background-image-fit` — `cover` | `contain` | `stretch` | `none`
- `background-image-position` — `center` and friends
- `background-opacity` — whole-window translucency vs. the desktop
