-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- my coolnight colorscheme
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 17

config.enable_tab_bar = true

-- config.window_decorations = "RESIZE"
config.window_background_opacity = 0.76
config.macos_window_background_blur = 10
config.default_cursor_style = "SteadyUnderline"

-- ---------------------------------------------------------------------------
-- Eye candy
-- ---------------------------------------------------------------------------
config.animation_fps = 60
config.max_fps = 120
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseOut"
config.text_background_opacity = 0.95
config.window_padding = { left = 12, right = 12, top = 8, bottom = 4 }
config.inactive_pane_hsb = { saturation = 0.7, brightness = 0.6 } -- dim unfocused panes
config.window_frame = {
	font = wezterm.font({ family = "MesloLGS Nerd Font Mono", weight = "Bold" }),
	font_size = 13.0,
}

-- ---------------------------------------------------------------------------
-- Background: solid coolnight base, plus the first image found in
-- ~/.config/wezterm/backgrounds/ (see that folder's README). Scaled to Cover
-- so it fills the window in full-screen without distortion.
-- ---------------------------------------------------------------------------
local function first_background_image()
	local dir = wezterm.home_dir .. "/.config/wezterm/backgrounds"
	local ok, entries = pcall(wezterm.read_dir, dir)
	if not ok or not entries then
		return nil
	end
	table.sort(entries)
	for _, path in ipairs(entries) do
		if path:lower():match("%.png$")
			or path:lower():match("%.jpe?g$")
			or path:lower():match("%.gif$")
			or path:lower():match("%.webp$")
			or path:lower():match("%.bmp$")
		then
			return path
		end
	end
	return nil
end

config.background = {
	{ source = { Color = "#011423" }, width = "100%", height = "100%" },
}

local bg_image = first_background_image()
if bg_image then
	table.insert(config.background, {
		source = { File = bg_image },
		width = "Cover",
		height = "Cover",
		horizontal_align = "Center",
		vertical_align = "Middle",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		opacity = 0.92,
		hsb = { brightness = 0.04, saturation = 0.9, hue = 1.0 },
	})
end

-- ---------------------------------------------------------------------------
-- Status HUD
--   left  : pi (AI assistant) token usage / cost for the day
--   right : workspace · load · battery · clock
-- ---------------------------------------------------------------------------
local PALETTE = {
	workspace = "#a277ff",
	load = "#FFE073",
	battery = "#44FFB1",
	battery_low = "#E52E2E",
	clock = "#0FC5ED",
	sep = "#214969",
	pi = "#44FFB1",
	pi_up = "#FFE073",
	pi_down = "#0FC5ED",
}

local BIN = wezterm.home_dir .. "/.config/wezterm/bin"
local PI_USAGE = BIN .. "/pi-usage"
local TERM_DASH = BIN .. "/term-dash"

-- Throttle the (blocking) scan: refresh pi usage at most every 30s.
local pi_cache = { text = "󰚩 pi …", at = 0 }

local function pi_usage()
	local now = os.time()
	if now - pi_cache.at >= 30 then
		local ok, stdout = pcall(wezterm.run_child_process, { PI_USAGE, "--oneline" })
		if ok and stdout and #stdout > 0 then
			pi_cache.text = stdout:gsub("%s+$", "")
		end
		pi_cache.at = now
	end
	return pi_cache.text
end

wezterm.on("update-status", function(window, _)
	local text = pi_usage()
	-- tint the whole segment by trend direction
	local color = PALETTE.pi
	if text:find("↑") then
		color = PALETTE.pi_up
	elseif text:find("↓") then
		color = PALETTE.pi_down
	end
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = PALETTE.sep } },
		{ Text = " " },
		{ Foreground = { Color = color } },
		{ Text = text .. "  " },
		{ Foreground = { Color = PALETTE.sep } },
		{ Text = "│ " },
	}))
end)

-- Throttle the (blocking) sysctl call: refresh load average at most every 5s.
local load_cache = { value = "…", at = 0 }

local function load_average()
	local now = os.time()
	if now - load_cache.at >= 5 then
		local ok, stdout = pcall(wezterm.run_child_process, { "sysctl", "-n", "vm.loadavg" })
		if ok and stdout then
			-- stdout looks like: { 1.98 2.05 2.15 }
			local one = stdout:match("{%s*([%d%.]+)")
			if one then
				load_cache.value = one
			end
		end
		load_cache.at = now
	end
	return load_cache.value
end

local function battery()
	local info = wezterm.battery_info()
	if not info or #info == 0 then
		return nil, false
	end
	local b = info[1]
	local pct = b.state_of_charge * 100
	local icon = "󰁹"
	if b.state == "Charging" then
		icon = "󰂄"
	elseif pct <= 10 then
		icon = "󰁺"
	elseif pct <= 30 then
		icon = "󰁼"
	elseif pct <= 60 then
		icon = "󰁾"
	elseif pct <= 90 then
		icon = "󰂀"
	end
	return string.format("%s %.0f%%", icon, pct), pct <= 20 and b.state ~= "Charging"
end

wezterm.on("update-status", function(window, _)
	local cells = {}

	local function push(color, text)
		table.insert(cells, { Foreground = { Color = color } })
		table.insert(cells, { Text = text })
	end
	local function sep()
		push(PALETTE.sep, "  ")
	end

	push(PALETTE.workspace, "󱂬 " .. window:active_workspace())
	sep()
	push(PALETTE.load, "󰓅 " .. load_average())

	local bat, low = battery()
	if bat then
		sep()
		push(low and PALETTE.battery_low or PALETTE.battery, bat)
	end

	sep()
	push(PALETTE.clock, "󰥔 " .. wezterm.strftime("%a %d %b  %H:%M"))
	table.insert(cells, { Text = " " })

	window:set_right_status(wezterm.format(cells))
end)

-- ---------------------------------------------------------------------------
-- Keys
--   CMD+SHIFT+U : full pi usage breakdown (last 14 days) in a scratch tab
--   CMD+SHIFT+D : combined dashboard -- system HUD + pi usage -- in a scratch tab
-- ---------------------------------------------------------------------------
local function scratch(cmd)
	return wezterm.action.SpawnCommandInNewTab({
		args = {
			"/bin/sh",
			"-c",
			cmd .. "; printf '\\n  press any key to close '; "
				.. "stty raw -echo 2>/dev/null; dd bs=1 count=1 >/dev/null 2>&1; "
				.. "stty sane 2>/dev/null",
		},
	})
end

config.keys = {
	{ key = "U", mods = "CMD|SHIFT", action = scratch(PI_USAGE .. " --days 14 --no-cache") },
	{ key = "D", mods = "CMD|SHIFT", action = scratch(TERM_DASH) },
}

-- and finally, return the configuration to wezterm
return config
