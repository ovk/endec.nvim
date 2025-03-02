local M = {}

--- Decode URL-encoded string.
--- On failure, second return parameter will contain error message.
---
--- @param encoded string
--- @return string, string?
M.decode = function(encoded)
    if #encoded == 0 then
        return "", nil
    end

    -- This approach doesn't generate error if the string was encoded incorrectly,
    -- instead it decodes parts that can be decoded.
    -- Seems like that's more practical thing to do in the context of this plugin.
    return encoded:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end), nil
end

--- Encode string using URL encoding (aka percent encoding).
---
--- @param plain string
--- @return string, string?
M.encode = function(plain)
    if #plain == 0 then
        return "", nil
    end

    -- Substitute all "unsafe" characters with their codes.
    -- See RFC3986 2.3.
    return plain:gsub("([^%w%-%.~_])", function(c)
        -- For multi-byte characters, each byte is encoded.
        local bytes = { string.byte(c, 1, #c) }
        local encoded = {}
        for _, b in ipairs(bytes) do
            table.insert(encoded, string.format("%%%02X", b))
        end
        return table.concat(encoded)
    end),
        nil
end

return M
