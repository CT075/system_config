require'nvim-treesitter'.install { 'latex', 'rust', 'haskell' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'latex', 'rust' },
  callback = function() vim.treesitter.start() end,
})

require'lualine'.setup {
  options = {
    theme = 'codedark',
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

-- One list per repo. Outside a repo there is nothing stable to key on, and a
-- persistent ~ list is mostly clutter, so those sessions get a scratch list that
-- never reaches disk. .jj is here for the non-colocated case; a jj repo that was
-- cloned with git alongside it matches on .git anyway.
local project_root = vim.fs.root(vim.uv.cwd(), { '.git', '.jj' })
local harpoon_root = project_root or vim.uv.cwd()
local SCRATCH_KEY = 'harpoon://scratch'

-- Entries are stored as absolute paths rather than relative to the root.
-- harpoon's own select() resolves a stored value through bufadd(), which is
-- cwd-relative, so a root-relative value breaks the moment nvim starts in a
-- subdirectory of the project. Path:make_relative hands back the path untouched
-- when it isn't under the given root, so naming a root nothing can live under
-- turns harpoon's normalization step into a no-op.
local NO_ROOT = '\0'

local function to_abs(value)
  if value:sub(1, 1) == '/' then return value end
  return harpoon_root .. '/' .. value
end

local function to_display(value)
  local prefix = harpoon_root .. '/'
  if value:sub(1, #prefix) == prefix then return value:sub(#prefix + 1) end
  return vim.fn.fnamemodify(value, ':~')
end

harpoon:setup {
  settings = {
    save_on_toggle = true,
    key = function() return project_root or SCRATCH_KEY end,
  },
  default = {
    get_root_dir = function() return NO_ROOT end,
    display = function(item) return to_display(item.value) end,
    -- Lines typed into the quick menu come back as displayed text, which reads
    -- as root-relative and has to go the other way.
    create_list_item = function(_, name)
      name = name and to_abs(name)
        or vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
      local pos = { 1, 0 }
      if vim.fn.bufnr(name, false) ~= -1 then
        pos = vim.api.nvim_win_get_cursor(0)
      end
      return { value = name, context = { row = pos[1], col = pos[2] } }
    end,
  },
}

-- The scratch list is read once at setup and never written back.
if not project_root then
  harpoon.data._data = {}
  harpoon.sync = function() end
end

-- Only real file buffers can be harpooned. Adding a [No Name] scratch buffer
-- gives an item whose value is "", which survives to disk and comes back as a
-- phantom tab that nothing can focus.
local function harpoonable(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

-- Dropped on load: blank entries persisted by older versions of this config, and
-- entries whose file is gone. Values written before the list was keyed on the
-- repo root are relative to whatever cwd added them, so they get resolved on the
-- way past.
harpoon:extend({
  LIST_CREATED = function(list)
    local items, changed = {}, false
    for i = 1, list._length do
      local it = list.items[i]
      local value = it and it.value
      if not value or value == "" then
        changed = true
      elseif not vim.uv.fs_stat(to_abs(value)) then
        changed = true
      else
        if to_abs(value) ~= value then
          it.value = to_abs(value)
          changed = true
        end
        items[#items + 1] = it
      end
    end
    if not changed then return end
    list.items, list._length = items, #items
    vim.schedule(function() harpoon:sync() end)
  end,
})

vim.keymap.set("n", "<C-e>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, {desc = "Harpoon quick menu"})

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
-- The tabline belongs to this session, not to the repo. Every file entered
-- becomes a tab, and :HarpoonEnter pulls in the harpoon list on top of that.
-- Closing a tab never touches harpoon, so a second nvim in the same repo can't
-- eat the persisted list.
local tabs = {} -- absolute paths, in display order

local function current_value()
  local v = vim.api.nvim_buf_get_name(0)
  if v == "" then return nil end
  return v
end

local function tab_index(value)
  if not value then return nil end
  for i, v in ipairs(tabs) do if v == value then return i end end
  return nil
end

local function add_tab(value)
  if not tab_index(value) then tabs[#tabs + 1] = value end
end

-- Harpooned files go through harpoon's select so the cursor lands where it was
-- last left. Anything else is a plain :edit.
local function open_value(value)
  local list = harpoon:list()
  local _, idx = list:get_by_value(value)
  if idx then list:select(idx)
  else vim.cmd.edit(vim.fn.fnameescape(value)) end
end

-- Drop a tab by value; if it's the current buffer, move like a tab.
local function tab_delete(value)
  local pos = tab_index(value)
  if not pos then return false end
  local was_current = (value == current_value())
  table.remove(tabs, pos)

  if was_current then
    local target = tabs[pos] or tabs[pos - 1]
    if target then open_value(target) else vim.cmd("enew") end
  end
  vim.cmd("redrawtabline")
  return true
end

local function close_current()
  local buf = vim.api.nvim_get_current_buf()
  local val = current_value()

  if tab_index(val) then
    tab_delete(val)
    return
  end

  -- Untracked buffer (terminal, help, [No Name], etc.): move to a tab, drop it.
  if #tabs > 0 then open_value(tabs[#tabs]) else vim.cmd("enew") end

  if vim.api.nvim_buf_is_valid(buf) and buf ~= vim.api.nvim_get_current_buf() then
    pcall(vim.api.nvim_buf_delete, buf, { force = false })
  end
  vim.cmd("redrawtabline")
end

-- ,d plus unloading the buffer, so re-entering it doesn't bring the tab back.
-- Refuses on unsaved changes rather than leaving a modified buffer with no tab.
local function delete_current()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
    return
  end
  close_current()
  if vim.api.nvim_buf_is_valid(buf) and buf ~= vim.api.nvim_get_current_buf() then
    pcall(vim.api.nvim_buf_delete, buf, {})
  end
end

local function cycle(delta)
  if #tabs == 0 then return end
  local pos = tab_index(current_value())
  local np = (pos == nil) and (delta > 0 and 1 or #tabs)
                          or (((pos - 1 + delta) % #tabs) + 1)
  open_value(tabs[np])
end

function _G.HarpoonTabClick(minwid)
  if tabs[minwid] then open_value(tabs[minwid]) end
end
function _G.HarpoonTabClose(minwid)
  if tabs[minwid] then tab_delete(tabs[minwid]) end
end

function _G.HarpoonTabline()
  local current = current_value()

  local modified = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].modified then
      local n = vim.api.nvim_buf_get_name(b)
      if n ~= "" then modified[n] = true end
    end
  end

  -- Renders tab number `i`; `i` doubles as the click minwid.
  local function build_tab(value, active, i)
    local body = active and "%#HarpoonActive#" or "%#HarpoonInactive#"

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
      accent = "%#HarpoonAccent#\u{258E}" .. body .. " "
    else
      accent = body .. "  "
    end

    name = name:gsub("%%", "%%%%")

    return accent
      .. "%" .. i .. "@v:lua.HarpoonTabClick@" .. i .. " " .. name .. " %X"
      .. body .. "%" .. i .. "@v:lua.HarpoonTabClose@" .. right .. " %X"
  end

  local parts = {}
  for i, v in ipairs(tabs) do
    parts[#parts + 1] = build_tab(v, v == current, i)
  end

  if #parts == 0 then return "%#HarpoonFill#" end
  return table.concat(parts) .. "%#HarpoonFill#"
end

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.HarpoonTabline()"

-- Pull the harpoon list into the tabline. Harpoon order goes first so <leader>N
-- means the same file it did last session; tabs opened before this keep their
-- relative order after it. Stays put unless the current buffer is a blank one.
vim.api.nvim_create_user_command("HarpoonEnter", function()
  local list = harpoon:list()
  local merged = {}
  for i = 1, list._length do
    local it = list.items[i]
    if it then merged[#merged + 1] = it.value end
  end
  if #merged == 0 then
    vim.notify("Harpoon: list is empty", vim.log.levels.WARN)
    return
  end
  for _, v in ipairs(tabs) do
    if not vim.tbl_contains(merged, v) then merged[#merged + 1] = v end
  end
  tabs = merged
  if not current_value() then open_value(tabs[1]) end
  vim.cmd("redrawtabline")
end, { desc = "Populate the tabline from the harpoon list" })

-- Every file is already a tab, so this only touches the persisted list.
vim.keymap.set("n", "<leader>a", function()
    if not harpoonable() then
      vim.notify("Harpoon: nothing to add, this buffer has no file", vim.log.levels.WARN)
      return
    end
    harpoon:list():add()
  end, {desc = "Harpoon add file"})

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    if tabs[i] then open_value(tabs[i]) end
  end, { desc = "Go to tab " .. i })
end

vim.keymap.set("n",  "<leader>d", close_current, { desc = "Close current buffer / tab" })
vim.keymap.set("n",  "<leader>D", delete_current, { desc = "Close tab and delete its buffer" })

vim.keymap.set("n", "<C-k>", function() cycle(1) end,  { desc = "Next tab" })
vim.keymap.set("n", "<C-j>", function() cycle(-1) end, { desc = "Prev tab" })

local grp = vim.api.nvim_create_augroup("HarpoonTabline", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = grp,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then return end
    if vim.api.nvim_buf_get_name(args.buf) == "" then return end
    local val = current_value()
    if tab_index(val) then return end
    add_tab(val)
    vim.cmd("redrawtabline")
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", { group = grp, callback = setup_highlights })
vim.api.nvim_create_autocmd("BufModifiedSet", {
  group = grp,
  callback = function() vim.cmd("redrawtabline") end,
})
