local utils = require("endec.utils")
local config = require("endec.config")

local M = {}

--- Calculate popup window size given the content.
---
--- @param lines string[]
--- @return table
local function popup_size(lines)
    -- Calculate size required to fit content
    local size = { width = 0, height = #lines }

    for _, line in ipairs(lines) do
        size.width = math.max(size.width, #line)
    end

    -- Restrict by window size
    size.width = math.min(size.width, vim.api.nvim_win_get_width(0) - 8)
    size.height = math.min(size.height, vim.api.nvim_win_get_height(0) - 2)

    -- Restrict according to config
    size.width = utils.clamp(size.width, config.popup.width.min, config.popup.width.max)
    size.height = utils.clamp(size.height, config.popup.height.min, config.popup.height.max)

    return size
end

--- Create popup window with content.
--- Callback function will be executed on writing to the popup window buffer
--- (with current popup content passed to it).
---
--- @param title string
--- @param position number[]
--- @param lines string[]
--- @param clbk function
M.create = function(title, position, lines, clbk)
    -- Create a setup scratch buffer for the popup window
    local bufnr = vim.api.nvim_create_buf(false, true)
    assert(bufnr, "Failed to create popup buffer")

    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
    vim.api.nvim_buf_set_name(bufnr, "endec")

    -- Set buffer content
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)

    -- Create and setup popup window
    local size = popup_size(lines)
    local wincfg = {
        relative = "win",
        bufpos = position,
        row = 0,
        col = 0,
        width = size.width,
        height = size.height,
        style = "minimal",
        anchor = "SW",
        border = config.popup.border,
        title = config.popup.show_title and title or nil,
        title_pos = "center",
        noautocmd = false,
    }

    -- Flip anchor if there isn't enough vertical space
    if position[1] - size.height - 2 < 0 then
        wincfg.anchor = "NW"
        wincfg.row = 1
    end

    local winnr = vim.api.nvim_open_win(bufnr, config.popup.enter, wincfg)
    assert(winnr, "Failed to create popup window")

    if config.popup.transparency > 0 then
        vim.api.nvim_set_option_value("winblend", config.popup.transparency, { scope = "local", win = winnr })
    end

    vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { scope = "local", win = winnr })

    for _, lhs in ipairs(config.popup.close_on) do
        vim.api.nvim_buf_set_keymap(
            bufnr,
            "n",
            lhs,
            "<cmd>lua vim.api.nvim_win_close(" .. winnr .. ", false)<CR>",
            { noremap = true }
        )
    end

    -- Set auto command to intercept buffer write
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        buffer = bufnr,
        callback = function()
            local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            clbk(content)

            vim.api.nvim_set_option_value("modified", false, { buf = 0 })
        end,
    })

    vim.api.nvim_set_option_value("modified", false, { buf = 0 })
end

return M
