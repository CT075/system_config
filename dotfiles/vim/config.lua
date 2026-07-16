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

vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
    vim.cmd('redrawtabline')
  end, {desc = "Harpoon add file"})
vim.keymap.set("n", "<C-e>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, {desc = "Harpoon quick menu"})
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end)
vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end)
vim.keymap.set("n", "<leader>8", function() harpoon:list():select(8) end)
vim.keymap.set("n", "<leader>9", function() harpoon:list():select(9) end)

local icon_hl_cache = {}

local function attrs(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h or {}
end
local function hex(n) return n and string.format("#%06x", n) or nil end

local function setup_highlights()
  icon_hl_cache = {}
  local normal, tab, fill = attrs("Normal"), attrs("TabLine"), attrs("TabLineFill")
  local sel, func = attrs("TabLineSel"), attrs("Function")
  local warn = attrs("DiagnosticWarn"); if not warn.fg then warn = attrs("WarningMsg") end
  local special, comment = attrs("Special"), attrs("Comment")

  local active_bg   = hex(normal.bg) or hex(sel.bg)
  local active_fg   = hex(normal.fg) or hex(sel.fg)
  local inactive_bg = hex(tab.bg) or hex(fill.bg)
  local inactive_fg = hex(tab.fg) or active_fg
  local fill_bg     = hex(fill.bg) or inactive_bg
  local accent_fg   = hex(func.fg) or active_fg
  local warn_fg     = hex(warn.fg) or accent_fg
  local soft_fg     = hex(special.fg) or hex(comment.fg) or inactive_fg

  local set = vim.api.nvim_set_hl
  set(0, "HarpoonActive",      { fg = active_fg,   bg = active_bg, bold = true })
  set(0, "HarpoonInactive",    { fg = inactive_fg, bg = inactive_bg })
  set(0, "HarpoonFill",        { bg = fill_bg })
  set(0, "HarpoonAccent",      { fg = accent_fg,   bg = active_bg })
  set(0, "HarpoonModActive",   { fg = warn_fg,     bg = active_bg })
  set(0, "HarpoonModInactive", { fg = warn_fg,     bg = inactive_bg })
  -- soft entry: same backgrounds, distinct (italic) accent color
  set(0, "HarpoonSoftActive",   { fg = soft_fg, bg = active_bg,   italic = true, bold = true })
  set(0, "HarpoonSoftInactive", { fg = soft_fg, bg = inactive_bg, italic = true })
  set(0, "HarpoonSoftAccent",   { fg = soft_fg, bg = active_bg })
end

-- devicon color composited onto the (active/inactive) tab background
local function icon_hl(group, active)
  local key = group .. (active and "A" or "I")
  if icon_hl_cache[key] then return icon_hl_cache[key] end
  local name = "HarpoonIcon" .. key:gsub("%W", "")
  vim.api.nvim_set_hl(0, name, {
    fg = hex(attrs(group).fg),
    bg = hex(attrs(active and "HarpoonActive" or "HarpoonInactive").bg),
  })
  icon_hl_cache[key] = name
  return name
end

setup_highlights()

--------------------------------------------------------------------------------
-- Shared state + helpers
--------------------------------------------------------------------------------
-- The "soft" entry: most recent non-harpooned file. Shown in the tabline,
-- cyclable, but replaced whenever another non-harpooned file is entered.
local soft = nil -- { value = <root-relative path> } | nil

local function current_value(list)
  local ok, v = pcall(function()
    return list.config.create_list_item(list.config).value
  end)
  if not ok or v == nil or v == "" then return nil end
  return v
end

local function value_in_list(list, value)
  if not value then return false end
  local _, idx = list:get_by_value(value)
  return idx ~= nil
end

-- Returns the soft entry only if it's set and NOT already a real list item;
-- clears it if it has since been harpooned.
local function get_soft(list)
  if not soft then return nil end
  if value_in_list(list, soft.value) then soft = nil return nil end
  return soft
end

local function open_value(value)
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.fnamemodify(value, ":p")))
end

-- Ordered virtual tab list: real harpoon items, then the soft entry.
local function combined(list)
  local arr = {}
  for i = 1, list._length do
    local it = list.items[i]
    if it ~= nil then arr[#arr + 1] = { value = it.value, kind = "list", idx = i } end
  end
  local s = get_soft(list)
  if s then arr[#arr + 1] = { value = s.value, kind = "soft" } end
  return arr
end

local function goto_last_or_blank(list)
  local last
  for i = 1, list._length do if list.items[i] then last = i end end
  if last then list:select(last) else vim.cmd("enew") end
end

-- Delete a harpoon entry by value; if it's the current buffer, move like a tab.
local function harpoon_delete(value)
  local list = harpoon:list()

  local items = {}
  for i = 1, list._length do
    if list.items[i] ~= nil then items[#items + 1] = list.items[i] end
  end

  local pos
  for i, it in ipairs(items) do if it.value == value then pos = i break end end
  if not pos then return false end

  local was_current = (value == current_value(list))
  local target = items[pos + 1] or items[pos - 1]

  table.remove(items, pos)
  list.items = items
  list._length = #items

  if was_current then
    if target then
      local _, idx = list:get_by_value(target.value)
      list:select(idx)
    else
      local s = get_soft(list)
      if s then open_value(s.value) else vim.cmd("enew") end
    end
  end
  vim.cmd("redrawtabline")
  return true
end

-- Clear the soft entry; if we're currently sitting on it, move away first.
local function clear_soft()
  if not soft then return end
  local list = harpoon:list()
  local on_soft = (soft.value == current_value(list))
  soft = nil
  if on_soft then goto_last_or_blank(list) end
  vim.cmd("redrawtabline")
end

local function close_current()
  local list = harpoon:list()
  local buf = vim.api.nvim_get_current_buf()
  local val = current_value(list)

  if value_in_list(list, val) then
    harpoon_delete(val)
    return
  end

  local s = get_soft(list)
  if s and val and s.value == val then
    clear_soft()
    return
  end

  -- (C) untracked buffer (terminal, help, [No Name], etc.): move to a tab, drop it.
  local last
  for i = 1, list._length do if list.items[i] then last = i end end
  if last then list:select(last)
  elseif s then open_value(s.value)
  else vim.cmd("enew") end

  if vim.api.nvim_buf_is_valid(buf) and buf ~= vim.api.nvim_get_current_buf() then
    pcall(vim.api.nvim_buf_delete, buf, { force = false })
  end
  vim.cmd("redrawtabline")
end

-- Cycle through harpoon items + the soft entry.
local function cycle(delta)
  local list = harpoon:list()
  local arr = combined(list)
  if #arr == 0 then return end
  local cur = current_value(list)
  local pos
  for i, e in ipairs(arr) do if e.value == cur then pos = i break end end
  local np = (pos == nil) and (delta > 0 and 1 or #arr)
                          or (((pos - 1 + delta) % #arr) + 1)
  local e = arr[np]
  if e.kind == "list" then list:select(e.idx) else open_value(e.value) end
end

function _G.HarpoonTabClick(minwid) harpoon:list():select(minwid) end
function _G.HarpoonTabClose(minwid)
  local it = harpoon:list().items[minwid]
  if it then harpoon_delete(it.value) end
end
function _G.HarpoonSoftClick()
  local s = get_soft(harpoon:list())
  if s then open_value(s.value) end
end
function _G.HarpoonSoftClose() clear_soft() end

function _G.HarpoonTabline()
  local ok, hp = pcall(require, "harpoon")
  if not ok then return "%#HarpoonFill#" end
  local list = hp:list()
  local current = current_value(list)

  local modified = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].modified then
      local n = vim.api.nvim_buf_get_name(b)
      if n ~= "" then modified[n] = true end
    end
  end

  -- Renders one tab. `is_soft` swaps highlight groups; `label` is the shown
  -- number (or nil -> "~" marker). `arg` is the click minwid.
  local function build_tab(value, active, is_soft, label, open_fn, close_fn, arg)
    local body = is_soft
      and (active and "%#HarpoonSoftActive#" or "%#HarpoonSoftInactive#")
      or  (active and "%#HarpoonActive#"     or "%#HarpoonInactive#")

    local name = vim.fn.fnamemodify(value, ":t")
    if name == "" then name = "[No Name]" end

    local right
    if modified[vim.fn.fnamemodify(value, ":p")] then
      right = (active and "%#HarpoonModActive#" or "%#HarpoonModInactive#") .. "\u{25CF}" .. body
    else
      right = "\u{2715}" -- ✗
    end

    local accent
    if active then
      accent = (is_soft and "%#HarpoonSoftAccent#" or "%#HarpoonAccent#") .. "\u{258E}" .. body .. " "
    else
      accent = body .. "  "
    end

    local tag = (label and (label .. " ") or "\u{223C} ")
    name = name:gsub("%%", "%%%%")

    return accent
      .. "%" .. arg .. "@v:lua." .. open_fn .. "@" .. tag .. name .. " %X"
      .. body .. "%" .. arg .. "@v:lua." .. close_fn .. "@" .. right .. " %X"
  end

  local parts, shown = {}, 0
  for i = 1, list._length do
    local it = list.items[i]
    if it ~= nil then
      shown = shown + 1
      local active = current and it.value == current
      parts[#parts + 1] =
        build_tab(it.value, active, false, tostring(shown), "HarpoonTabClick", "HarpoonTabClose", i)
    end
  end

  local s = get_soft(list)
  if s then
    local active = current and s.value == current
    parts[#parts + 1] =
      build_tab(s.value, active, true, nil, "HarpoonSoftClick", "HarpoonSoftClose", 0)
  end

  if #parts == 0 then return "%#HarpoonFill#" end
  return table.concat(parts) .. "%#HarpoonFill#"
end

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.HarpoonTabline()"

vim.keymap.set("n",  "<leader>d", close_current, { desc = "Close current buffer / tab" })

vim.keymap.set("n", "<C-j>", function() cycle(1) end,  { desc = "Harpoon: next tab" })
vim.keymap.set("n", "<C-k>", function() cycle(-1) end, { desc = "Harpoon: prev tab" })

local grp = vim.api.nvim_create_augroup("HarpoonTabline", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = grp,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then return end
    if vim.api.nvim_buf_get_name(args.buf) == "" then return end
    local list = harpoon:list()
    local val = current_value(list)
    if not val or value_in_list(list, val) then return end -- harpooned -> leave soft as-is
    if not soft or soft.value ~= val then
      soft = { value = val }
      vim.cmd("redrawtabline")
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", { group = grp, callback = setup_highlights })
vim.api.nvim_create_autocmd("BufModifiedSet", {
  group = grp,
  callback = function() vim.cmd("redrawtabline") end,
})
