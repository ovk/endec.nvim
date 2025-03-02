local path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/"
vim.opt.runtimepath:append(path)

require("endec").setup({})
