--[[ Costum Remappings ]]--
require("griffithai.toggle_copilot")

vim.g.mapleader = " "

-- Copilot enable/disable
vim.keymap.set("n", "<leader>cp", ToggleCopilot, { desc = "Toggle Copilot" })

vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open Oil file explorer" })

-- Move highlighted lines around with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Pasting over highlighted text doesn't yank content, by using leader p
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste over selection without yanking it" })

-- Leader yank and normal yank remaps
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })


-- Worst place in the universe
vim.keymap.set("n", "Q", "<nop>", { desc = "Disabled (was Ex mode)" })
