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

-- Tab bar -- also the home of the status HUD (right) and pi usage (left).
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.status_update_interval = 3000 -- refresh the HUD every 3s (avoid blocking main loop too often)
config.set_environment_variables = {
	PATH = wezterm.home_dir
		.. "/.pyenv/shims:"
		.. wezterm.home_dir
		.. "/.pyenv/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
}

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
--   right : cpu · ram · disk · clock
-- ---------------------------------------------------------------------------
local PALETTE = {
	cpu = "#FFE073",
	ram = "#a277ff",
	disk = "#44FFB1",
	git = "#E52E2E",
	clock = "#0FC5ED",
	sep = "#214969",
	pi = "#44FFB1",
	pi_up = "#FFE073",
	pi_down = "#0FC5ED",
}

local BIN = wezterm.home_dir .. "/.config/wezterm/bin"
local PI_USAGE = BIN .. "/pi-usage"
local TERM_DASH = BIN .. "/term-dash"

-- Per-window pi status: model + tokens/cost for the pi session in this pane's
-- cwd. Throttle the (blocking) scan: refresh at most every 15s, keyed by cwd
-- so switching projects updates promptly.
local pi_win_cache = {}

local function pi_window(dir)
	dir = dir or wezterm.home_dir
	local now = os.time()
	local c = pi_win_cache[dir]
	if not c or now - c.at >= 15 then
		c = c or { text = "" }
		local ok, success, stdout =
			pcall(wezterm.run_child_process, { PI_USAGE, "--window", dir })
		if ok and success and stdout and #stdout > 0 then
			c.text = stdout:gsub("%s+$", "")
		end
		c.at = now
		pi_win_cache[dir] = c
	end
	return c.text
end

-- Mini bar: filled █ + empty ░ in two colors
local BFULL = "\xe2\x96\x88" -- █
local BDIM = "\xe2\x96\x91" -- ░
local function mini_bar(pct, width)
	width = width or 6
	local n = math.floor(pct / 100 * width + 0.5)
	if n > width then n = width end
	if n < 0 then n = 0 end
	return string.rep(BFULL, n), string.rep(BDIM, width - n)
end

-- CPU: use sysctl load average instead of `top -l 1` which blocks for ~1s
local cpu_cache = { label = "...", pct = 0, at = 0 }

local function cpu_usage()
	local now = os.time()
	if now - cpu_cache.at >= 10 then
		local ok, success, stdout =
			pcall(wezterm.run_child_process, { "/usr/sbin/sysctl", "-n", "vm.loadavg" })
		if ok and success and stdout then
			local load1 = stdout:match("{%s*([%d%.]+)")
			if load1 then
				local ncpu_ok, _, ncpu_str = pcall(wezterm.run_child_process, { "/usr/sbin/sysctl", "-n", "hw.ncpu" })
				local ncpu = (ncpu_ok and tonumber(ncpu_str:match("%d+"))) or 8
				local p = tonumber(load1) / ncpu * 100
				cpu_cache.label = string.format("%.0f%%", p)
				cpu_cache.pct = math.min(p, 100)
			end
		end
		cpu_cache.at = now
	end
	return cpu_cache
end

-- RAM: cached every 10s
local ram_cache = { label = "...", pct = 0, at = 0 }

local function ram_usage()
	local now = os.time()
	if now - ram_cache.at >= 10 then
		local ok1, s1, total_str =
			pcall(wezterm.run_child_process, { "/usr/sbin/sysctl", "-n", "hw.memsize" })
		local ok2, s2, vmstat = pcall(wezterm.run_child_process, { "/usr/bin/vm_stat" })
		if ok1 and s1 and total_str and ok2 and s2 and vmstat then
			local total = tonumber(total_str:match("(%d+)"))
			local ps = tonumber(vmstat:match("page size of (%d+)")) or 16384
			local active = tonumber(vmstat:match("Pages active:%s+(%d+)")) or 0
			local wired = tonumber(vmstat:match("Pages wired down:%s+(%d+)")) or 0
			local compressed = tonumber(vmstat:match("Pages occupied by compressor:%s+(%d+)")) or 0
			if total and total > 0 then
				local used_gb = (active + wired + compressed) * ps / 1073741824
				local total_gb = total / 1073741824
				ram_cache.label = string.format("%.1f/%.0fG", used_gb, total_gb)
				ram_cache.pct = used_gb / total_gb * 100
			end
		end
		ram_cache.at = now
	end
	return ram_cache
end

-- Git branch: cached every 10s
local git_cache = { branch = "", at = 0 }

local function git_branch(pane)
	local now = os.time()
	if now - git_cache.at >= 10 then
		local cwd = pane:get_current_working_dir()
		local dir = cwd and cwd.file_path or wezterm.home_dir
		local ok, success, stdout = pcall(
			wezterm.run_child_process,
			{ "/usr/bin/git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }
		)
		if ok and success and stdout then
			git_cache.branch = stdout:gsub("%s+$", "")
		else
			git_cache.branch = ""
		end
		git_cache.at = now
	end
	return git_cache.branch
end

-- Disk: cached every 60s
local disk_cache = { label = "...", pct = 0, at = 0 }

local function disk_usage()
	local now = os.time()
	if now - disk_cache.at >= 60 then
		local ok, success, stdout = pcall(wezterm.run_child_process, { "/bin/df", "-h", "/" })
		if ok and success and stdout then
			local total, used, _, pct = stdout:match("\n%S+%s+(%S+)%s+(%S+)%s+(%S+)%s+(%d+)%%")
			if pct then
				disk_cache.label = used .. "/" .. total
				disk_cache.pct = tonumber(pct)
			end
		end
		disk_cache.at = now
	end
	return disk_cache
end

wezterm.on("update-status", function(window, pane)
	-- ---- left: per-window pi model + session usage -----------------------
	local cwd = pane and pane:get_current_working_dir()
	local dir = cwd and cwd.file_path or wezterm.home_dir
	local pi_text = pi_window(dir)
	if pi_text == "" then
		window:set_left_status("")
	else
		window:set_left_status(wezterm.format({
			{ Foreground = { Color = PALETTE.sep } },
			{ Text = " " },
			{ Foreground = { Color = PALETTE.pi } },
			{ Text = pi_text .. "  " },
			{ Foreground = { Color = PALETTE.sep } },
			{ Text = "\xe2\x94\x82 " },
		}))
	end

	-- ---- right: cpu · ram · disk · clock ---------------------------------
	local cells = {}
	local function push(color, text)
		table.insert(cells, { Foreground = { Color = color } })
		table.insert(cells, { Text = text })
	end
	local function sep()
		push(PALETTE.sep, "  ")
	end

	local cpu = cpu_usage()
	local ram = ram_usage()
	local dsk = disk_usage()
	local cf, ce = mini_bar(cpu.pct, 6)
	local rf, re = mini_bar(ram.pct, 6)
	local df, de = mini_bar(dsk.pct, 6)

	push(PALETTE.cpu, "CPU " .. cpu.label .. " ")
	push(PALETTE.cpu, cf)
	push(PALETTE.sep, ce)
	sep()
	push(PALETTE.ram, "RAM " .. ram.label .. " ")
	push(PALETTE.ram, rf)
	push(PALETTE.sep, re)
	sep()
	push(PALETTE.disk, "DSK " .. dsk.label .. " ")
	push(PALETTE.disk, df)
	push(PALETTE.sep, de)

	local branch = git_branch(pane)
	if branch ~= "" then
		sep()
		push(PALETTE.git, "\xee\x9c\xa5 " .. branch)
	end

	sep()
	push(PALETTE.clock, wezterm.strftime("%a %d %b  %H:%M"))
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
