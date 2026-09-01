local ghci = require("griffithai.ghci")

vim.keymap.set("n", "<leader>hl", ghci.load, { buffer = true, desc = "Load buffer into ghci" })
vim.keymap.set("n", "<leader>hr", ghci.reload, { buffer = true, desc = "Reload ghci" })
