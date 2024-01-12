-- Tangerine config
local config = {
    vimrc = vim.fn.stdpath("data") .. "/fnl/init.fnl",
    eval = { float = false },
    compiler = { float = false },
}

-- Bootstrap package manager and fennel compiler
local function bootstrap(url, extra)
    local name = url:gsub(".*/", "")
    local path = vim.fn.stdpath("data") .. "/lazy/" .. name

    local ok = nil
    if not vim.loop.fs_stat(path) then
        print(name .. ": installing in data dir...")

        ok = vim.fn.system({ "git", "clone", "--filter=blob:none", url, extra, path })

        vim.cmd("redraw")
        print(name .. ": finished installing")
    end

    vim.opt.rtp:prepend(path)

    return ok
end

bootstrap("https://github.com/folke/lazy.nvim", "--branch=stable")

if bootstrap("https://github.com/udayvir-singh/tangerine.nvim", "--quiet") then
    require("tangerine").setup(config)
    vim.cmd("FnlCompile")
end

require("tangerine").setup(config)

require("init")
