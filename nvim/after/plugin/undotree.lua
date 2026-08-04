vim.keymap.set("n", "<leader>ut", vim.cmd.UndotreeToggle, { desc = "Undotree toggle" })

-- Put the cursor in the undotree window when it opens, so you can navigate the
-- tree immediately instead of having to <C-w> into it first.
vim.g.undotree_SetFocusWhenToggle = 1
