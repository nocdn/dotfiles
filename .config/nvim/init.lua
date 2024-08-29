-- relative line numbers
vim.wo.relativenumber = true
vim.g.mapleader = " "

-- indenting with 2 spaces
-- use spaces instead of tab characters
vim.cmd("set expandtab")
-- determines width of tab character in spaced
vim.cmd("set tabstop=2")
-- controls how many spaces inserted when tab pressed
vim.cmd("set softtabstop=2")
-- defines number of spaces used for each level of indentation
vim.cmd("set shiftwidth=2")

-- lazy.nvim package manager

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"},
                           {"\nPress any key to exit..."}}, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.8',
            dependencies = {'nvim-lua/plenary.nvim'}
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate"
        },
        { "ThePrimeagen/vim-be-good" },
        {
            "nvim-neo-tree/neo-tree.nvim",
            opts = {
                filesystem = {
                    filtered_items = {
                        visible = true,
                        show_hidden_count = true,
                        hide_dotfiles = false,
                        hide_gitignored = true,
                        hide_by_name = {
                            -- '.git',
                            -- '.DS_Store',
                            -- 'thumbs.db',
                        },
                        never_show = {}
                    }
                },
            },
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons", -- recommended
                "MunifTanjim/nui.nvim" -- "3rd/image.nvim", -- Optional image support
            }
        },
        { "williamboman/mason.nvim" },
        { "supermaven-inc/supermaven-nvim" }
    },
    install = {
        colorscheme = {"habamax"}
    },
    checker = {
        enabled = false
    }
})

-- catppuccin color scheme
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

local configs = require("nvim-treesitter.configs")
configs.setup({
    ensure_installed = {"c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html"},
    sync_install = false,
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    }
})

config = function()
    require("supermaven-nvim").setup({})
end

-- Function to toggle Neo-tree
local function toggle_neotree()
    -- Use the vim.g.neo_tree_open variable to store the state
    if vim.g.neo_tree_open then
        -- If open, close it
        vim.cmd('Neotree close')
        vim.g.neo_tree_open = false
    else
        -- If closed, open it
        vim.cmd('Neotree filesystem reveal left')
        vim.g.neo_tree_open = true
    end
end

-- Map the minus key to toggle Neo-tree
vim.keymap.set('n', '-', toggle_neotree)

require("mason").setup()
