local utils = require("endec.utils")
local popup = require("endec.popup")
local config = require("endec.config")
local keymap = require("endec.keymap")
local base64 = require("endec.base64")
local url = require("endec.url")

local M = {}

--- Lookup table for all known encodings.
local encodings = {
    base64 = { title = "Base64", encode = base64.encode, decode = base64.decode },
    base64url = { title = "Base64URL", encode = base64.encode_url_safe, decode = base64.decode_url_safe },
    url = { title = "URL", encode = url.encode, decode = url.decode },
}

--- Get object for specific encoding by name.
---
--- @param encoding string
--- @return { title: string, encode: function, decode: function } | nil
local function get_encoding(encoding)
    if encoding == nil then
        vim.notify("valid encoding must be provided", vim.log.levels.ERROR)
        return nil
    end

    local enc = encodings[encoding]
    if enc == nil then
        vim.notify("unknown encoding: " .. encoding, vim.log.levels.ERROR)
    end

    return enc
end

--- Decode text at given range either in-place, or show it in a popup window.
--- In case of popup, writing to popup buffer encodes its content and writes it back
--- to the original range.
---
--- @param from integer[]
--- @param to integer[]
--- @param lines string[]
--- @param encoding string
--- @param show_popup boolean
local function decode_range(from, to, lines, encoding, show_popup)
    local enc = get_encoding(encoding)
    if enc == nil then
        return
    end

    -- Clean up and decode text
    local plain, err = enc.decode(string.gsub(table.concat(lines), "%s+", ""))
    if err ~= nil then
        vim.notify("failed to decode selection using " .. encoding .. " encoding: " .. err, vim.log.levels.ERROR)
        return
    end

    if show_popup then
        -- Open popup with decoded lines
        local decoded_lines = utils.split_lines(plain)
        local bufnr = vim.fn.bufnr()
        local cursor = vim.fn.getcursorcharpos()
        local popup_pos = { cursor[2] - 1, cursor[3] }

        popup.create(enc.title, popup_pos, decoded_lines, function(popup_lines)
            -- Join lines using popup buffer new line type.
            -- Not ideal, since original line endings may be lost, but at least gives
            -- user an option to override.
            local popup_text = table.concat(popup_lines, utils.get_eol())

            -- Encode text from the popup buffer
            local encoded, eerr = enc.encode(popup_text)
            if eerr ~= nil then
                vim.notify(
                    "failed to encode selection using " .. encoding .. " encoding: " .. eerr,
                    vim.log.levels.ERROR
                )
                return
            end

            -- Wrap encoded text so that it takes same number of lines as before.
            -- Not ideal, as lines may end up being too long/short, but at least
            -- this behavior feels somewhat intuitive.
            local wrapped_text = utils.wrap(encoded, to[1] - from[1] + 1)

            -- Write re-encoded text back to the original buffer
            vim.api.nvim_buf_set_text(bufnr, from[1] - 1, from[2] - 1, to[1] - 1, to[2], wrapped_text)
        end)
    else
        -- Write decoded text back to the original buffer
        vim.api.nvim_buf_set_text(0, from[1] - 1, from[2] - 1, to[1] - 1, to[2], utils.split_lines(plain))
    end
end

--- Encode text (in-place) at given range using given encoding.
---
--- @param from integer[]
--- @param to integer[]
--- @param lines string[]
--- @param encoding string
local function encode_range(from, to, lines, encoding)
    local enc = get_encoding(encoding)
    if enc == nil then
        return
    end

    -- Join lines using buffer's newline character
    local text = table.concat(lines, utils.get_eol())

    -- Encode and wrap text
    local encoded, err = enc.encode(text)
    if err ~= nil then
        vim.notify("failed to encode selection using " .. encoding .. " encoding: " .. err, vim.log.levels.ERROR)
        return
    end

    local wrapped_text = utils.wrap(encoded, to[1] - from[1] + 1)

    -- Write re-encoded text back to the original buffer
    vim.api.nvim_buf_set_text(0, from[1] - 1, from[2] - 1, to[1] - 1, to[2], wrapped_text)
end

--- Internal function to serve as an 'operatorfunc'.
---
--- @param mode string
--- @param action "encode" | "decode"
--- @param encoding string
--- @param show_popup boolean
local function operator_callback(mode, action, encoding, show_popup)
    -- Get selection range
    local from = utils.get_mark("[")
    local to = utils.get_mark("]")
    if not from or not to then
        return
    end

    if mode == "line" then
        from[2] = 1
        to[2] = utils.last_char_idx(to[1])
    elseif mode ~= "char" then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, from[1] - 1, to[1], false)
    if #lines == 0 then
        return
    end

    -- With paragraphs, last empty line may be part of a paragraph (i.e. with 'ap')
    -- which feels a little counter-intuitive when writing re-encoded text back
    -- (adds an "extra" line).
    -- This workaround removes last line from selection if it's empty.
    if mode == "line" and #lines > 1 and lines[#lines] == "" then
        table.remove(lines)
        to[1] = to[1] - 1
        to[2] = utils.last_char_idx(to[1])
    end

    if #lines == 1 then
        lines[1] = string.sub(lines[1], from[2], to[2])
    else
        lines[1] = string.sub(lines[1], from[2])
        lines[#lines] = string.sub(lines[#lines], 1, to[2])
    end

    if action == "decode" then
        -- Decode in-place or in popup
        decode_range(from, to, lines, encoding, show_popup)
    elseif action == "encode" then
        -- Encode range in-place
        encode_range(from, to, lines, encoding)
    end
end

--- Decode visual selection either in-place or in popup window.
---
--- @param encoding string
--- @param show_popup boolean
M.vdecode = function(encoding, show_popup)
    -- Feed escape key to exit visual mode, if it's still active (to populate visual registers)
    local mode = vim.api.nvim_get_mode().mode
    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
    end

    -- Get visually selected text
    local selection = utils.get_visual_selection()
    if selection == nil then
        return
    end

    -- Decode and show popup
    decode_range(selection.from, selection.to, selection.lines, encoding, show_popup)
end

--- Encode visual selection (in-place) using given encoding.
---
--- @param encoding string
M.vencode = function(encoding)
    -- Feed escape key to exit visual mode, if it's still active (to populate visual registers)
    local mode = vim.api.nvim_get_mode().mode
    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
    end

    -- Get visually selected text
    local selection = utils.get_visual_selection()
    if selection == nil then
        return
    end

    -- Encode text in-place
    encode_range(selection.from, selection.to, selection.lines, encoding)
end

--- Operator to decode Base64 in-place.
---
--- @param mode string
M.op_decode_base64 = function(mode)
    operator_callback(mode, "decode", "base64", false)
end

--- Operator to decode Base64 in popup.
---
--- @param mode string
M.op_pdecode_base64 = function(mode)
    operator_callback(mode, "decode", "base64", true)
end

--- Operator to encode Base64.
---
--- @param mode string
M.op_encode_base64 = function(mode)
    operator_callback(mode, "encode", "base64", false)
end

--- Operator to decode Base64URL in-place.
---
--- @param mode string
M.op_decode_base64url = function(mode)
    operator_callback(mode, "decode", "base64url", false)
end

--- Operator to decode Base64URL in popup.
---
--- @param mode string
M.op_pdecode_base64url = function(mode)
    operator_callback(mode, "decode", "base64url", true)
end

--- Operator to encode Base64URL.
---
--- @param mode string
M.op_encode_base64url = function(mode)
    operator_callback(mode, "encode", "base64url", false)
end

--- Operator to decode URL in-place.
---
--- @param mode string
M.op_decode_url = function(mode)
    operator_callback(mode, "decode", "url", false)
end

--- Operator to decode URL in popup.
---
--- @param mode string
M.op_pdecode_url = function(mode)
    operator_callback(mode, "decode", "url", true)
end

--- Operator to encode URL.
---
--- @param mode string
M.op_encode_url = function(mode)
    operator_callback(mode, "encode", "url", false)
end

--- Initialize the plugin and set initial configuration.
---
--- @param cfg table
M.setup = function(cfg)
    if vim.fn.has("nvim-0.10") == 0 then
        -- Base 64 module was added in v0.10
        vim.notify("endec.nvim requires Neovim 0.10 or newer", vim.log.levels.WARN)
        return
    end

    config.setup(cfg)

    keymap.setup()
end

return M
