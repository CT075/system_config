lspconfig = require'lspconfig'
completion_callback = require'completion'.on_attach

lspconfig.rust_analyzer.setup{on_attach=completion_callback}

