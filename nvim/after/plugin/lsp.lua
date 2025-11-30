require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = {
		'lua_ls',		-- Lua LS
		'pyright', 		-- Python LS
		'ruff',			-- ruff linter
		'omnisharp', 	-- C# LS, REQUIRES .NET 6.0 SDK TO BUILD
		'jdtls',		-- Java LS
		'clangd',		-- C/C++ LS
		'rust_analyzer',-- Rust LS
	};
	automatic_enable = false
})



-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('*', {
  capabilities = cmp_capabilities,
  -- you could also define `on_attach`, `root_markers`, etc here
})

-- Lua language server settings
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
    },
  },
})

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
--
-- Configure jdtls
vim.lsp.config('jdtls', {
  cmd = { 'jdtls' },
  root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-21',
            path = '/usr/lib/jvm/java-21-openjdk-amd64/',
          }
        }
      },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
    }
  },
})

-- enable servers
vim.lsp.enable('lua_ls') -- Lua LS
vim.lsp.enable('pyright') -- Python LS
vim.lsp.enable('ruff') -- ruff linter
vim.lsp.enable('jdtls') -- Java
vim.lsp.enable('clangd') -- C/C++
vim.lsp.enable('omnisharp') -- C#
vim.lsp.enable('rust_analyzer') -- Rust

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
  print('LSP virtual text ' .. (in_line and 'enabled' or 'disabled'))
end

vim.keymap.set('n', '<leader>te', ToggleLspErrors, { desc = 'Toggle LSP errors' })
