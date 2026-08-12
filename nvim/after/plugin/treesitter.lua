-- nvim-treesitter `main` branch.
--
-- The old `require'nvim-treesitter.configs'.setup{}` API is master-only and does
-- not exist here. On main the plugin only installs parsers/queries; turning on
-- highlighting and indentation per buffer is the user's job.
--
-- Parsers now live in stdpath('data')/site/parser, not in the plugin directory,
-- so they survive plugin reinstalls.

local ts = require('nvim-treesitter')

ts.setup()

local parsers = {
	"python", "c", "cpp", "c_sharp", "java", "javascript", "typescript",
	"lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "bash",
	-- No "jsonc": main dropped that parser, the json one covers it
	"json", "yaml", "toml",
}

-- Install anything missing. ts.install() is async, so this does not block
-- startup; it is a no-op once everything is present.
--
-- The main branch builds parsers by shelling out to `tree-sitter build`, so
-- without the CLI every install fails. Bail out early rather than re-downloading
-- 17 grammars and printing 17 errors on every startup. Install the CLI with
-- `cargo install tree-sitter-cli` (0.26.1+; apt ships 0.20.8, too old, and
-- upstream advises against the npm build).
--
-- Note that nvim itself bundles parsers for c, lua, markdown, markdown_inline,
-- query, vim and vimdoc, so those filetypes -- and LSP hover boxes -- keep their
-- highlighting with no CLI and no parsers installed here.
if vim.fn.executable('tree-sitter') == 1 then
	local installed = ts.get_installed('parsers')
	local missing = vim.tbl_filter(function(lang)
		return not vim.tbl_contains(installed, lang)
	end, parsers)

	if #missing > 0 then
		ts.install(missing, { summary = true })
	end
end

-- LaTeX keeps the vim regex syntax: vimtex depends on it for indentation and
-- concealment, and treesitter highlighting conflicts with it.
local skip = { tex = true, latex = true, plaintex = true, context = true }

vim.api.nvim_create_autocmd('FileType', {
	desc = 'Enable treesitter highlighting and indentation where a parser exists',
	callback = function(event)
		if skip[event.match] then
			return
		end

		-- Errors when no parser is installed for this filetype; that is the
		-- normal case for plenty of buffers, so failure is not interesting.
		if not pcall(vim.treesitter.start, event.buf) then
			return
		end

		vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
