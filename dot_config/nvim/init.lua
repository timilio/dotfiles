-- Tangerine config
local config = {
    rtpdirs = {
        "plugin",
    },
    eval = { float = false },
    compiler = { float = false },
}

-- Bootstrap package manager and fennel compiler
local function bootstrap(url)
    local name = url:gsub(".*/", "")
    local path = vim.fn.stdpath [[data]] .. "/site/pack/packer/start/" .. name

    local ok = nil
    if vim.fn.isdirectory(path) == 0 then
        print(name .. ": installing in data dir...")

        ok = vim.fn.system { "git", "clone", "--depth", "1", url, path }

        vim.cmd [[redraw]]
        print(name .. ": finished installing")
    end
    return ok
end

local pack = bootstrap("https://github.com/wbthomason/packer.nvim")

if bootstrap("https://github.com/udayvir-singh/tangerine.nvim") then
    require("tangerine").setup(config)
    vim.cmd("FnlCompile")
end

require("tangerine").setup(config)

if pack then
    vim.cmd("PackerSync")
end
