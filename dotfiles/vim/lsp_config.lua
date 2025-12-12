opts = {noremap=true, silent=true}

vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '\\<CR>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<localleader>t', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'J', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
end

local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function()
    metals = require("metals")
    cfg = metals.bare_config()
    cfg.init_options.statusBarProvider = "on"
    cfg.settings = {
      metalsBinaryPath = "/home/cam/.local/share/coursier/bin/metals"
    }
    metals.initialize_or_attach(cfg)
    vim.api.nvim_set_keymap('n', '<localleader>t', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_set_keymap('n', 'J', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  end,
  group = nvim_metals_group,
})

vim.lsp.config('rust_analyzer', {on_attach=on_attach})
vim.lsp.config('hls', {
  on_attach=on_attach,
  settings={haskell={plugin={stan={globalOn=false}}}}
})
vim.lsp.config('pyright', {on_attach=on_attach})
-- require('idris2').setup({server={on_attach=on_attach}})
