require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",		-- Lua LS
		"pyright", 		-- Python LS
		"harper_ls",		-- C/C++ and more LS
		"fsautocomplete",	-- F#
		"ruff",			-- ruff linter
	};
	automatic_enable = false
})



-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lspconfig_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)
-- LSP reserves some space in the sign column, disable it
vim.opt.signcolumn = 'no'

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
		vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
		vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
		vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
		vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
		vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
		vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
		vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
		vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
		vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
	end,
})

-- You'll find a list of language servers here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

local cmp = require('cmp')

require("lspconfig").lua_ls.setup {}
require("lspconfig").pyright.setup {}
require("lspconfig").harper_ls.setup {}
require("lspconfig").fsautocomplete.setup {}

cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
	},
	snippet = {
		expand = function(args)
			-- You need Neovim v0.10 to use vim.snippet
			vim.snippet.expand(args.body)
		end,
	},
	mapping = {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
})

-- Configure diagnostics
vim.diagnostic.config({
	signs = false, -- Disable signs in the gutter
	underline = true, -- Underline errors and warnings
	virtual_text = false, -- Disable virtual text
	update_in_insert = false, -- Don't update diagnostics in insert mode
})

-- For toggling LSP in line error messages
local in_line = false

-- Function to toggle LSP signs
function ToggleLspErrors()
  in_line = not in_line
  vim.diagnostic.config({ virtual_text = in_line })
  print("LSP virtual text " .. (in_line and "enabled" or "disabled"))
end

vim.keymap.set("n", "<leader>te", ToggleLspErrors, { desc = "Toggle LSP errors" })

