# WezTerm background

Drop an image in this folder (`~/.config/wezterm/backgrounds/`) and it is picked
up automatically on the next config reload (`Cmd+Shift+R`).

- Supported: `.png .jpg .jpeg .gif .webp .bmp`
- If several images are present, the **alphabetically first** one wins. Prefix
  with a number (`01-nebula.jpg`) to pick, or just keep one file here.
- No image here → falls back to the solid `#011423` background.
- Wallpapers are `.gitignore`d by default. `mystic-city.webp` is an exception and
  is committed so a fresh clone has a working background out of the box. Add
  more exceptions with `!filename.ext` in `.gitignore` if you want to track them.

Tuning lives in `.wezterm.lua` (search for `background`):

- `hsb.brightness` — lower = darker/more readable (default `0.04`)
- `opacity` — the image layer's own alpha (default `0.92`)
- `config.window_background_opacity` — whole-window translucency vs. the desktop

The image is scaled with `Cover`, so it fills the window (including full-screen)
without distortion and re-fits on resize.
