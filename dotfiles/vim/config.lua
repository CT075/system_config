treesitter = require('nvim-treesitter')

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

require'bufferline'.setup { options = {
  numbers = "none",
  show_buffer_icons = false,
  show_buffer_close_icons = false,
}}
