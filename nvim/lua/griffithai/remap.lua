--[[ Costum Remappings ]]--
require("griffithai.toggle_copilot")

vim.g.mapleader = " "

-- Copilot enable/disable
vim.keymap.set({"n","i","v","x"}, "<leader>cp", ToggleCopilot, { desc = "Toggle Copilot" })


vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>")

-- Move highlighted lines around with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Pasting over highlighted text doesn't yank content, by using leader p
vim.keymap.set("x", "<leader>p", '"_dP')

-- Leader yank and normal yank remaps
vim.keymap.set("n", "<leader>y", '"+y') -- Yank to system clipboard in normal mode
vim.keymap.set("v", "<leader>y", '"+y') -- Yank to system clipboard in visual mode
vim.keymap.set("n", "<leader>Y", '"+Y') -- cap Y yanks to system clipboard

-- Worst place in the universe
vim.keymap.set("n", "Q", "<nop>")

