-- Cheatsheets for things :Telescope keymaps can't show you.
--
-- Built-in Vim commands like `za` are compiled into the editor, not registered
-- as keymaps, so nothing that enumerates the keymap table will ever list them.
-- This is the fallback for those.

local sections = {
	{
		"Toggle / open / close (cursor)",
		{
			{ "za", "toggle the fold under the cursor" },
			{ "zA", "toggle it, and every fold nested inside" },
			{ "zo", "open the fold under the cursor" },
			{ "zO", "open it, and every fold nested inside" },
			{ "zc", "close the fold under the cursor" },
			{ "zC", "close it, and every fold nested inside" },
			{ "zv", "open just enough folds to reveal the cursor line" },
		},
	},
	{
		"Whole file",
		{
			{ "zR", "open ALL folds" },
			{ "zM", "close ALL folds" },
			{ "zr", "open one more level everywhere" },
			{ "zm", "close one more level everywhere" },
			{ "zi", "toggle folding on / off entirely" },
		},
	},
	{
		"Navigation",
		{
			{ "zj", "jump down to the start of the next fold" },
			{ "zk", "jump up to the end of the previous fold" },
			{ "[z", "jump to the start of the current open fold" },
			{ "]z", "jump to the end of the current open fold" },
		},
	},
	{
		"In this config",
		{
			{ "json", "folds come from treesitter, so every {} and [] is a fold" },
			{ "", "files open fully expanded (foldenable = false)" },
			{ ":h fold-commands", "the full official reference" },
		},
	},
}

local function open_cheatsheet(title)
	local lines, marks = {}, {}
	local keyw = 0
	for _, section in ipairs(sections) do
		for _, row in ipairs(section[2]) do
			keyw = math.max(keyw, #row[1])
		end
	end

	for i, section in ipairs(sections) do
		if i > 1 then
			lines[#lines + 1] = ""
		end
		marks[#marks + 1] = { #lines, 0, -1, "Title" }
		lines[#lines + 1] = "  " .. section[1]
		for _, row in ipairs(section[2]) do
			local key = row[1]
			lines[#lines + 1] = string.format("    %-" .. keyw .. "s   %s", key, row[2])
			if key ~= "" then
				marks[#marks + 1] = { #lines - 1, 4, 4 + #key, "Identifier" }
			end
		end
	end

	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	width = math.min(width + 2, vim.o.columns - 4)
	local height = math.min(#lines, vim.o.lines - 6)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local ns = vim.api.nvim_create_namespace("griffithai_cheatsheet")
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], {
			end_col = m[3] == -1 and #lines[m[1] + 1] or m[3],
			hl_group = m[4],
		})
	end

	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " " .. title .. "   (q to close) ",
		title_pos = "center",
	})

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
end

vim.keymap.set("n", "<leader>fc", function()
	open_cheatsheet("Fold commands")
end, { desc = "Cheatsheet: fold commands" })
