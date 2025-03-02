local M = {}

--- Get visually selected text and range describing the selection.
---
--- @return { from: integer[], to: integer[], lines: string[] } | nil
M.get_visual_selection = function()
    local vmode = vim.fn.visualmode()
    if vmode ~= "v" and vmode ~= "V" and vmode ~= "\22" then
        return nil
    end

    local from = vim.fn.getpos("'<")
    local to = vim.fn.getpos("'>")
    local lines = vim.fn.getregion(from, to, { type = vmode })

    -- End char index returned by `getpos` could be beyond the actual last character,
    -- so make sure it's in range.
    local endCharIdx = math.min(to[3], M.last_char_idx(to[2]))

    return { from = { from[2], from[3] }, to = { to[2], endCharIdx }, lines = lines }
end

--- Clamp number in [min, max] range.
---
--- @param value number
--- @param min number
--- @param max number
--- @return number
M.clamp = function(value, min, max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

--- Split string into an array of lines.
--- Lines can be separated either with '\r', '\n' or '\r\n'.
---
--- @param text string
--- @return string[]
M.split_lines = function(text)
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    return vim.split(text, "\n", { plain = true, trimempty = false })
end

--- Wrap string such that it takes 'n' lines.
--- If it's impossible to evenly divide the text into 'n' lines, the last line will be shorter.
--- This function doesn't produce empty lines (if 'n' > length of 'str').
---
--- @param str string
--- @param n integer
--- @return string[]
M.wrap = function(str, n)
    local len = #str
    local part_len = math.max(1, math.floor(len / n))
    local remainder = (len > n) and (len % n) or 0
    local idx = 1
    local parts = {}

    for i = 1, n do
        if idx > len then
            break
        end

        local size = part_len + (i <= remainder and 1 or 0)
        local part = str:sub(idx, idx + size - 1)

        table.insert(parts, part)

        idx = idx + size
    end

    return parts
end

--- Get end of line character for the current buffer.
---
--- @return string
M.get_eol = function()
    local ff = vim.bo.fileformat

    if ff == "dos" then
        return "\r\n"
    elseif ff == "mac" then
        return "\r"
    else
        return "\n"
    end
end

--- Get position of the mark (row, col) from the current buffer.
--- Line/column indices are 1-based.
---
--- @return integer[] | nil
M.get_mark = function(mark)
    local pos = vim.api.nvim_buf_get_mark(0, mark)
    if pos[1] == 0 then
        return nil
    end
    return { pos[1], pos[2] + 1 }
end

--- Get index of the last character (1-based) in a line (specified by 1-based index).
---
--- @param line integer
--- @return integer
M.last_char_idx = function(line)
    return vim.fn.col({ line, "$" }) - 1
end

return M
