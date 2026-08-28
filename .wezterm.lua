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

local PI_USAGE = wezterm.home_dir .. "/.config/wezterm/bin/pi-usage"

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
-- ---------------------------------------------------------------------------
config.keys = {
	{
		key = "u",
		mods = "CMD|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = {
				"/bin/sh",
				"-c",
				PI_USAGE .. " --days 14 --no-cache; echo; echo 'press q to close'; "
					.. "read _ 2>/dev/null || sleep 30",
			},
		}),
	},
}

-- and finally, return the configuration to wezterm
return config
