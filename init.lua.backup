-- relative line numbers
vim.wo.relativenumber = true
vim.g.mapleader = " "

vim.g.have_nerd_font = true

-- indenting with 2 spaces
-- use spaces instead of tab characters
vim.cmd("set expandtab")
-- determines width of tab character in spaces
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


-- Lazy.nvim package manager setup
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
                window = {
                    width = 25,
                },
                filesystem = {
                    filtered_items = {
                        visible = true,
                        show_hidden_count = true,
                        hide_dotfiles = false,
                        hide_gitignored = true,
                    }
                },
            },
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim"
            }
        },
        { "williamboman/mason.nvim" },
        {
            -- supermaven-nvim plugin with detailed configuration
            "supermaven-inc/supermaven-nvim",
            config = function()
                require("supermaven-nvim").setup({
                    keymaps = {
                        accept_suggestion = "<Tab>",
                        clear_suggestion = "<C-]>",
                        accept_word = "<C-j>",
                    },
                    ignore_filetypes = { cpp = true }, -- or { "cpp", }
                    color = {
                        suggestion_color = "#9BA0B2",
                        cterm = 244,
                    },
                    log_level = "off", -- set to "off" to disable logging completely
                    disable_inline_completion = false, -- disables inline completion for use with cmp
                    disable_keymaps = false, -- disables built-in keymaps for more manual control
                    condition = function()
                        return false
                    end -- Condition to stop supermaven
                })
            end,
        }
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

-- Function to toggle focus between Neo-tree and the editor
local function toggle_neotree_focus()
    if vim.g.neo_tree_open then
        -- Check if Neo-tree is currently focused
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_ft = vim.api.nvim_buf_get_option(buf, "filetype")

        if buf_ft == "neo-tree" then
            -- If Neo-tree is focused, switch to the previous window
            vim.cmd('wincmd p')
        else
            -- If the editor is focused, switch to Neo-tree
            vim.cmd('Neotree focus')
        end
    else
        -- Open Neo-tree if it's not open
        vim.cmd('Neotree filesystem reveal left')
        vim.g.neo_tree_open = true
    end
end

-- Automatically open Neo-tree on startup but keep editor focused
vim.cmd('Neotree filesystem reveal left')  -- Open Neo-tree

-- Use vim.schedule to ensure focus switch happens after Neo-tree opens
vim.schedule(function()
    vim.cmd('wincmd p')  -- Go back to the editor window
end)

vim.g.neo_tree_open = true  -- Ensure the state variable is set to true

-- Map the minus key to toggle focus between Neo-tree and the editor
vim.keymap.set('n', '-', toggle_neotree_focus)

-- Function to override :wqa behavior if Neo-tree is focused
local function save_quit_all_override()
    -- Check if Neo-tree is currently focused
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_ft = vim.api.nvim_buf_get_option(buf, "filetype")

    if buf_ft == "neo-tree" then
        -- If Neo-tree is focused, force save all and quit
        vim.cmd('wqa!')
    else
        -- Otherwise, perform normal save and quit all
        vim.cmd('wqa')
    end
end

-- Define custom command SaveQuitAllOverride
vim.api.nvim_create_user_command('SaveQuitAllOverride', save_quit_all_override, {})

-- Map the plus key to SaveQuitAllOverride
vim.keymap.set('n', '=', save_quit_all_override, { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>s', ':SupermavenToggle<CR>', { noremap = true, silent = true }) 

require("mason").setup()
