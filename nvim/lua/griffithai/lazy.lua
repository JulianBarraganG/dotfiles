-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
	  "git",
	  "clone",
	  "--filter=blob:none",
	  "--branch=stable",
	  lazyrepo,
	  lazypath
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { {'nvim-lua/plenary.nvim'} }
  };


  -- VimTeX
  {
    'lervag/vimtex',
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'zathura'
    end
  };

  -- Colorschemes
  { 'NLKNguyen/papercolor-theme', as = 'papercolor' };
  { 'catppuccin/nvim', as = 'catppuccin' };
  { 'folke/tokyonight.nvim', as = 'tokyonight' };

  -- Other Plugins
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' };
  'nvim-treesitter/playground';
  'nvim-lua/plenary.nvim';
  'ThePrimeagen/harpoon';
  'mbbill/undotree';
  'tpope/vim-fugitive'; -- git

  -- File explorer (replace netrw)
  {
	'stevearc/oil.nvim',
  	dependencies = {'echasnovski/mini.icons', 'nvim-tree/nvim-web-devicons' }
  };

  -- LSP
  'neovim/nvim-lspconfig';
  'hrsh7th/nvim-cmp';
  'hrsh7th/cmp-nvim-lsp';
  'hrsh7th/cmp-buffer';
  'hrsh7th/cmp-path';
  'hrsh7th/cmp-cmdline';
  'williamboman/mason.nvim';
  'williamboman/mason-lspconfig.nvim';

  -- Copilot
  'github/copilot.vim';
})
