lspconfig = require'lspconfig'
completion_callback = require'completion'.on_attach

lspconfig.pyls.setup{on_attach=completion_callback}
lspconfig.rust_analyzer.setup{on_attach=completion_callback}

