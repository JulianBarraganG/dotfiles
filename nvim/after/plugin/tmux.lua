vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { silent = true })
vim.keymap.set("n", "<C-\\>", ":TmuxNavigatePrevious<CR>", { silent = true })

-- The plugin's own terminal-mode maps (guarded by $TMUX) send `<C-w>:` to leave
-- the terminal, which is Vim 8 syntax -- nvim has no termwinkey, so <C-w> and
-- the following `:<C-U> TmuxNavigateLeft<cr>` get typed straight into the job.
-- Override them with nvim's real escape, <C-\><C-n>.
for key, dir in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
	vim.keymap.set("t", "<C-" .. key .. ">", function()
		if vim.bo.filetype == "fzf" then
			return "<C-" .. key .. ">"
		end
		return "<C-\\><C-n><Cmd>TmuxNavigate" .. dir .. "<CR>"
	end, { expr = true, replace_keycodes = true, silent = true })
end
