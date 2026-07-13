vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block"


vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "81"

vim.g.mapleader = " "

vim.g.netrw_list_hide = "*.pyc,__pycache__,.git/,node_modules,.*_cache/"
vim.g.netrw_bufsettings = "noma nomod nu rnu nobl nowrap ro"

vim.diagnostic.config({ virtual_text = true })

-- use safer shell for netrw
vim.opt.shell = "/bin/sh"

-- fix quoting issues
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- explicit commands for netrw
vim.g.netrw_localcopycmd = "cp"
vim.g.netrw_localcopycmdopt = "-r"
vim.g.netrw_localmovecmd = "mv"
vim.g.netrw_localrmcmd = "rm"

