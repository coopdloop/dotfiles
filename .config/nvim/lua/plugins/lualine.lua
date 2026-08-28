local function git_blame_line()
  local gitsigns = package.loaded.gitsigns
  if not gitsigns then return "" end
  local blame = gitsigns.get_current_line_blame()
  if not blame or blame == "" then return "" end
  -- truncate to keep statusline clean
  if #blame > 60 then
    blame = blame:sub(1, 57) .. "..."
  end
  return blame
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {
      { 'buffers' },
    },
    lualine_b = {
      'branch',
      'diff',
    },
    lualine_c = {
      {
        git_blame_line,
        color = { fg = "#6c7086", gui = "italic" },
      },
    },
    lualine_x = {
      {
        require("noice").api.statusline.mode.get,
        cond = require("noice").api.statusline.mode.has,
        color = { fg = "#ff9e64" },
      },
      'diagnostics',
    },
    lualine_y = { 'filetype' },
    lualine_z = { 'location' },
  },
}
