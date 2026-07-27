-- Applies to .json, .jsonc and (via vim.filetype.add in set.lua) .jsonl / .ndjson

-- Show quotes and escapes, never hide them
vim.opt_local.conceallevel = 0

-- Treesitter folding: za / zc to collapse an object, zR to open everything.
-- Files still open fully expanded.
if vim.fn.has("nvim-0.10") == 1 then
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.opt_local.foldenable = false
end

-- JSON is 2-space by convention, and jq emits 2-space
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true

-- Everything below is for real files only. The preview float re-uses this
-- filetype for its scratch buffer, and it shouldn't inherit the keymaps.
if vim.bo.buftype ~= "" then
	return
end

local ext = vim.fn.expand("%:e")
local is_lines = ext == "jsonl" or ext == "ndjson"

-- <leader>jf : reformat the buffer with jq.
-- Plain JSON gets pretty-printed; JSON Lines stays one record per line.
vim.keymap.set("n", "<leader>jf", function()
	if vim.fn.executable("jq") == 0 then
		vim.notify("jq is not installed", vim.log.levels.ERROR)
		return
	end
	local view = vim.fn.winsaveview()
	vim.cmd(is_lines and "silent %!jq -c ." or "silent %!jq .")
	if vim.v.shell_error ~= 0 then
		vim.cmd("silent undo")
		vim.notify("jq failed: invalid JSON", vim.log.levels.ERROR)
	end
	vim.fn.winrestview(view)
end, { buffer = true, desc = "JSON: format with jq" })

-- <leader>jl : pretty-print the record under the cursor, full screen.
-- This is the one that makes .jsonl readable.
vim.keymap.set("n", "<leader>jl", function()
	if vim.fn.executable("jq") == 0 then
		vim.notify("jq is not installed", vim.log.levels.ERROR)
		return
	end
	local out = vim.fn.systemlist({ "jq", "." }, vim.api.nvim_get_current_line())
	if vim.v.shell_error ~= 0 then
		vim.notify(table.concat(out, "\n"), vim.log.levels.ERROR)
		return
	end

	local source = vim.fn.expand("%:t")
	local lnum = vim.api.nvim_win_get_cursor(0)[1]

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	-- Cover the whole editor: no border, no background file showing through.
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = 0,
		col = 0,
		width = vim.o.columns,
		-- The winbar is drawn inside this height, so it needs no extra row
		height = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0),
		border = "none",
		zindex = 200,
	})

	-- Make it look like an ordinary window rather than a floating one
	vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:Normal"
	vim.wo[win].number = true
	vim.wo[win].relativenumber = true
	vim.wo[win].cursorline = true
	vim.wo[win].wrap = false
	vim.wo[win].winbar = table.concat({
		"%#Comment# jq . ",
		vim.fn.escape(source, "%"),
		":",
		lnum,
		"   %=q / <Esc> close   za fold ",
	})

	-- Set last: this fires the json ftplugin against the float, which brings
	-- treesitter highlighting and folding with it.
	vim.bo[buf].filetype = "json"

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
end, { buffer = true, desc = "JSON: pretty-print current line (jsonl)" })
