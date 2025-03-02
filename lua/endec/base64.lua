local M = {}

--- Decode Base64 encoded string.
--- On failure, second return parameter will contain error message.
---
--- @param encoded string
--- @return string, string?
M.decode = function(encoded)
    if #encoded == 0 then
        return "", nil
    end

    -- Use native (C) decoding function
    local status, result = pcall(vim.base64.decode, encoded)

    if status then
        return result, nil
    else
        return "", result
    end
end

--- Decode Base64URL encoded string (RFC 4648 § 5).
--- On failure, second return parameter will contain error message.
---
--- @param encoded string
--- @return string, string?
M.decode_url_safe = function(encoded)
    if #encoded == 0 then
        return "", nil
    end

    -- Unmap URL-safe characters
    encoded = encoded:gsub("-", "+"):gsub("_", "/")

    -- Restore padding, if missing
    if encoded:sub(-1) ~= "=" then
        local padding = #encoded % 4
        if padding > 0 then
            encoded = encoded .. string.rep("=", 4 - padding)
        end
    end

    -- Decode as regular Base64
    return M.decode(encoded)
end

--- Encode string into Base64 string.
---
--- @param plain string
--- @return string, string?
M.encode = function(plain)
    if #plain == 0 then
        return "", nil
    end

    -- Use native encoding function
    return vim.base64.encode(plain)
end

--- Encode string into Base64URL string.
---
--- @param plain string
--- @return string, string?
M.encode_url_safe = function(plain)
    if #plain == 0 then
        return "", nil
    end

    -- Encode as regular Base64
    local encoded = M.encode(plain)

    -- Map unsafe characters to URL-safe replacements
    encoded = encoded:gsub("+", "-"):gsub("/", "_")

    -- Remove padding, since '=' characters will be percent-encoded otherwise.
    encoded = encoded:gsub("=", "")

    return encoded, nil
end

return M
