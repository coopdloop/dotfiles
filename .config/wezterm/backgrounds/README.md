# WezTerm background

Drop an image in this folder (`~/.config/wezterm/backgrounds/`) and it is picked
up automatically on the next config reload (`Cmd+Shift+R`).

- Supported: `.png .jpg .jpeg .gif .webp .bmp`
- If several images are present, the **alphabetically first** one wins. Prefix
  with a number (`01-nebula.jpg`) to pick, or just keep one file here.
- No image here → falls back to the solid `#011423` background.
- Images are `.gitignore`d, so wallpapers stay out of the dotfiles repo.

Tuning lives in `.wezterm.lua` (search for `background`):

- `hsb.brightness` — lower = darker/more readable (default `0.04`)
- `opacity` — the image layer's own alpha (default `0.92`)
- `config.window_background_opacity` — whole-window translucency vs. the desktop

The image is scaled with `Cover`, so it fills the window (including full-screen)
without distortion and re-fits on resize.
