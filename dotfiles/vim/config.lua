require'nvim-treesitter'.install { 'latex', 'rust', 'haskell' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'latex', 'rust', 'haskell' },
  callback = function() vim.treesitter.start() end,
})

require'lualine'.setup {
  options = {
    theme = 'molokai',
    component_separators = '',
    icons_enabled = false
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}

harpoon = require'harpoon'
harpoon:setup({settings={save_on_toggle = true}})

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,
  {desc = "Harpoon add file"})
vim.keymap.set("n", "<C-e>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, {desc = "Harpoon quick menu"})
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():next() end)

local function attrs(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h or {}
end
local function hex(n) return n and string.format("#%06x", n) or nil end

local function current_value(list)
  local ok, v = pcall(function()
    return list.config.create_list_item(list.config).value
  end)
  return ok and v or nil
end

local function setup_highlights()
  icon_hl_cache = {} -- colors may have changed
  local normal, tab, fill = attrs("Normal"), attrs("TabLine"), attrs("TabLineFill")
  local sel, func = attrs("TabLineSel"), attrs("Function")
  local warn = attrs("DiagnosticWarn")
  if not warn.fg then warn = attrs("WarningMsg") end

  local active_bg   = hex(normal.bg) or hex(sel.bg)
  local active_fg   = hex(normal.fg) or hex(sel.fg)
  local inactive_bg = hex(tab.bg) or hex(fill.bg)
  local inactive_fg = hex(tab.fg) or active_fg
  local fill_bg     = hex(fill.bg) or inactive_bg
  local accent_fg   = hex(func.fg) or active_fg
  local warn_fg     = hex(warn.fg) or accent_fg

  local set = vim.api.nvim_set_hl
  set(0, "HarpoonActive",      { fg = active_fg,   bg = active_bg, bold = true })
  set(0, "HarpoonInactive",    { fg = inactive_fg, bg = inactive_bg })
  set(0, "HarpoonFill",        { bg = fill_bg })
  set(0, "HarpoonAccent",      { fg = accent_fg,   bg = active_bg })
  set(0, "HarpoonModActive",   { fg = warn_fg,     bg = active_bg })
  set(0, "HarpoonModInactive", { fg = warn_fg,     bg = inactive_bg })
end

function _G.HarpoonTabClick(minwid, _clicks, _button, _mods)
  local ok, hp = pcall(require, "harpoon")
  if ok then hp:list():select(minwid) end
end

function _G.HarpoonTabline()
  local ok, hp = pcall(require, "harpoon")
  if not ok then return "%#HarpoonFill#" end
  local list = hp:list()
  local current = current_value(list)

  -- Exact modified lookup by absolute buffer name.
  local modified = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].modified then
      local n = vim.api.nvim_buf_get_name(b)
      if n ~= "" then modified[n] = true end
    end
  end

  local parts, shown = {}, 0
  for i = 1, list._length do
    local it = list.items[i]
    if it ~= nil then
      shown = shown + 1
      local active = current and it.value == current
      local body = active and "%#HarpoonActive#" or "%#HarpoonInactive#"

      local name = vim.fn.fnamemodify(it.value, ":t")
      if name == "" then name = "[No Name]" end

      local icon = ""
      if has_devicons then
        local glyph, group =
          devicons.get_icon(name, name:match("%.([%w_]+)$"), { default = true })
        if glyph then
          icon = "%#" .. icon_hl(group, active) .. "#" .. glyph .. body .. " "
        end
      end

      local is_mod = modified[vim.fn.fnamemodify(it.value, ":p")]
      local right
      if is_mod then
        right = (active and "%#HarpoonModActive#" or "%#HarpoonModInactive#")
          .. "\u{25CF}" .. body -- ●
      else
        right = "\u{2715}" -- ✗
      end

      local lead = active and ("%#HarpoonAccent#\u{258E}" .. body .. " ") -- ▎
        or (body .. "  ")

      name = name:gsub("%%", "%%%%")

      parts[#parts + 1] = lead
        .. "%" .. i .. "@v:lua.HarpoonTabClick@"
        .. icon .. shown .. " " .. name .. " "
        .. "%X"
        .. body .. "%" .. i .. "@v:lua.HarpoonTabClose@"
        .. right .. " "
        .. "%X"
    end
  end

  if #parts == 0 then return "%#HarpoonFill#" end
  return table.concat(parts) .. "%#HarpoonFill#"
end

local function harpoon_delete(value)
  local list = harpoon:list()

  -- Dense snapshot in display order (skip holes).
  local items = {}
  for i = 1, list._length do
    if list.items[i] ~= nil then items[#items + 1] = list.items[i] end
  end

  local pos
  for i, it in ipairs(items) do
    if it.value == value then pos = i break end
  end
  if not pos then return end

  -- Next file, or previous if we deleted the last tab. Capture before mutating.
  local target = items[pos + 1] or items[pos - 1]

  -- Rebuild without the deleted item (dense, no holes).
  table.remove(items, pos)
  list.items = items
  list._length = #items

  if target then
    local _, idx = list:get_by_value(target.value)
    list:select(idx)
  else
    vim.cmd("enew")
  end
end

function _G.HarpoonTabClose(minwid)
  local it = harpoon:list().items[minwid]
  if it then harpoon_delete(it.value) end
end

setup_highlights()
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.HarpoonTabline()"

vim.keymap.set("n", "<leader>d", function()
  harpoon_delete(current_value(harpoon:list()))
end, { desc = "Harpoon: delete current file, go to next" })

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("HarpoonAutoAdd", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then return end
    if vim.api.nvim_buf_get_name(args.buf) == "" then return end
    harpoon:list():add()
  end,
})
