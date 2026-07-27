local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon: mark current file" })
vim.keymap.set("n", "<c-e>", ui.toggle_quick_menu, { desc = "Harpoon: toggle menu" })

vim.keymap.set("n", "<C-t>", function() ui.nav_file(1) end, { desc = "Harpoon: go to file 1" })
vim.keymap.set("n", "<C-n>", function() ui.nav_file(2) end, { desc = "Harpoon: go to file 2" })
vim.keymap.set("n", "<C-s>", function() ui.nav_file(3) end, { desc = "Harpoon: go to file 3" })
vim.keymap.set("n", "<C-l>", function() ui.nav_file(4) end, { desc = "Harpoon: go to file 4" })
