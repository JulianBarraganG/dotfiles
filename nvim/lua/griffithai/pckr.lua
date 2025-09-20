local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath('data') .. '/pckr/pckr.nvim'

  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

require('pckr').add{

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    requires = { {'nvim-lua/plenary.nvim'} }
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
  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' };
  'nvim-treesitter/playground';
  'nvim-lua/plenary.nvim';
  'ThePrimeagen/harpoon';
  'mbbill/undotree';
  'tpope/vim-fugitive'; -- git

  -- File explorer (replace netrw)
  {
	'stevearc/oil.nvim',
  	requires = {'echasnovski/mini.icons', 'nvim-tree/nvim-web-devicons' }
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
}

