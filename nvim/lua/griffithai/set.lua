vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8 -- keep 8 lines below cursor

vim.opt.updatetime = 50 -- default 4000, by setting to 50, it will update the swap file every 50ms

-- Tabs & Indentation
vim.opt.shiftwidth = 4 -- Indent by 4 spaces
vim.opt.tabstop = 4 -- think this is needed
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Filetype detection for formats nvim doesn't know about
-- JSON Lines / NDJSON are just JSON values one per line
vim.filetype.add({
    extension = {
        jsonl = "json",
        ndjson = "json",
    },
})

-- Never conceal quotes/escapes in JSON (the builtin syntax does this by default)
vim.g.vim_json_conceal = 0

-- Override all ftplugins to :set fo-=c as well as r and o
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})
