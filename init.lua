-- Basic Editor Settings
vim.cmd([[
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set nu
]])

vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.api.nvim_set_option("clipboard", "unnamedplus")

-- Install Lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Setup with Lazy.nvim
local plugins = {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "neovim/nvim-lspconfig" },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        }
    },
    { "lambdalisue/vim-suda" }
}

require("lazy").setup(plugins, {})

-- Theme Configuration
require("catppuccin").setup()
vim.cmd("colorscheme catppuccin")

-- Treesitter Configuration
require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "rust" },
    highlight = { enable = true },
    indent = { enable = true }
})

-- LSP Setup
local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup({})
lspconfig.pyright.setup({})
lspconfig.eslint.setup({})
lspconfig.clangd.setup({})

-- Completion Engine Setup (nvim-cmp)
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete({}),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
})

-- Neo-tree Setup
require("neo-tree").setup()

-- NeoTree Toggle Logic with Window Tracking
local NeoTreeOpen = false
local NeoTreeWindowID = nil

local function IsNeoTreeFocused()
    return NeoTreeWindowID and vim.api.nvim_win_is_valid(NeoTreeWindowID) and vim.api.nvim_get_current_win() == NeoTreeWindowID
end

local function ToggleNeoTree()
    if NeoTreeOpen and IsNeoTreeFocused() then
        vim.cmd("q")
        NeoTreeOpen = false
    else
        vim.cmd("Neotree")
        NeoTreeWindowID = vim.api.nvim_get_current_win()
        NeoTreeOpen = true
    end
end

-- Keymap to Toggle Neo-tree
vim.keymap.set("n", "<C-n>", ToggleNeoTree)
