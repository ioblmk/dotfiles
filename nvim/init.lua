vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.sidescroll = 5
vim.opt.sidescrolloff = 10
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_winsize = 25
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1

--[[ Install vim-plug if missing
local plug_path = vim.fn.stdpath('data')..'/site/autoload/plug.vim'
if vim.fn.empty(vim.fn.glob(plug_path)) > 0 then
  vim.fn.system({
    "sh", "-c",
    "curl -fLo "..plug_path.." --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  })
end
--]]

-- Plugins via vim-plug
vim.cmd([[
call plug#begin('~/.local/share/nvim/plugged')

" LSP
Plug 'neovim/nvim-lspconfig'

" Fuzzy search
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'

Plug 'nvim-mini/mini.diff'

call plug#end()
]])

-- Apply the colorscheme
vim.cmd([[colorscheme habamax]])

-- LSP configuration
local lspconfig = vim.lsp
local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "hpp" },
  callback = function()
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd",
              "--background-index",
              "--clang-tidy",
              "--query-driver=*gcc.exe" },
      filetypes = { "c", "cpp", "h", "hpp" },
      capabilities = capabilities,
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }

    vim.api.nvim_buf_set_option(args.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})

-- Highlight trailing whitespaces
vim.cmd([[highlight ExtraWhitespace ctermbg=red guibg=red]])
vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
vim.opt.list = true
vim.opt.listchars = {
  trail = '·',
  tab = '» ',
}

-- Telescope keymaps
local telescope_status, telescope = pcall(require, "telescope.builtin")
if telescope_status then
    local root_dir = vim.fn.getcwd(-1, -1)

    vim.keymap.set("n", "<leader>/", telescope.current_buffer_fuzzy_find)
    vim.keymap.set("n", "<leader>fps", telescope.lsp_dynamic_workspace_symbols)
    vim.keymap.set("n", "<leader>fs", telescope.lsp_document_symbols)

    vim.keymap.set("n", "<leader>fg", function()
        telescope.live_grep({ cwd = root_dir })
    end)

    vim.keymap.set("n", "<leader>ff", function()
        telescope.find_files({ cwd = root_dir })
    end)

    vim.keymap.set('n', '<leader>fw', function()
        telescope.live_grep({
            cwd = root_dir,
            default_text = vim.fn.expand('<cword>')
        })
    end)
end

-- Mini.diff keymaps and sources setup
local diff_status, diff = pcall(require, 'mini.diff')
if diff_status then
    diff.setup({ source = {diff.gen_source.save(), diff.gen_source.git()} })

    -- Navigate forward/backward through changes
    vim.keymap.set('n', ']c', function() MiniDiff.goto_hunk('next') end, { desc = 'Next change' })
    vim.keymap.set('n', '[c', function() MiniDiff.goto_hunk('prev') end, { desc = 'Previous change' })
    vim.keymap.set('n', '<leader>do', function() MiniDiff.toggle_overlay() end, { desc = 'Toggle Diff Overlay' })
end

-- Open netrw in current file directory
vim.keymap.set("n", "<leader>e", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  local dir = vim.fn.expand("%:p:h")
  vim.cmd("Lex " .. dir)
end, { desc = "Toggle Lex" })

-- Move between windows using Alt
vim.keymap.set('n', '<A-h>',  '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<A-j>',  '<C-w>j', { desc = "Move to bottom window" })
vim.keymap.set('n', '<A-k>',    '<C-w>k', { desc = "Move to top window" })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = "Move to right window" })

