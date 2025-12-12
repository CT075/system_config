require("mason").setup()
require("mason-lspconfig").setup()

vim.diagnostic.config({ virtual_text = true })

opts = {noremap=true, silent=true}

vim.api.nvim_set_keymap('n', '<localleader>w', '<cmd>ToggleWhitespace<CR><cmd>ToggleWhitespace<CR>', opts)

vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '\\<CR>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<localleader>t', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'J', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<localleader>c', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
end

local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function()
    metals = require'metals'
    metals_config = metals.bare_config()
    vim.api.nvim_set_keymap('n', '<localleader>t', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_set_keymap('n', 'J', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    metals_config.settings = {
      metalsBinaryPath = '/home/cam/.local/share/coursier/bin/metals',
    }
    vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local lvl = ({ "ERROR", "WARN", "INFO", "LOG" })[result.type]
      -- send to :messages instead of popup
      vim.notify(
        string.format("[%s] %s", client and client.name or "LSP", result.message),
        vim.log.levels[lvl]
      )
    end
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    on_attach(client, bufnr)
  end
})

require('idris2').setup({server={on_attach=on_attach}})

for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end

vim.lsp.config('rust_analyzer', {on_attach=on_attach})
vim.lsp.config('hls', {
  on_attach=on_attach,
  settings={haskell={plugin={stan={globalOn=false}}}}
})
vim.lsp.config('pyright', {on_attach=on_attach})

vim.lsp.enable('hls')
