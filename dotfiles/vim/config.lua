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
vim.keymap.set("n", "<C-k>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():next() end)
