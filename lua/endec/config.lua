local M = {}

local config = {
    -- Key mappings.
    -- Set any mapping to empty string to disable it.
    keymaps = {
        -- Set to `false` to disable all default mappings.
        defaults = true,

        -- Decode Base64 in-place (normal mode)
        decode_base64_inplace = "gyb",

        -- Decode Base64 in-place (visual mode)
        vdecode_base64_inplace = "gyb",

        -- Decode Base64 in a popup (normal mode)
        decode_base64_popup = "gb",

        -- Decode Base64 in a popup (visual mode)
        vdecode_base64_popup = "gb",

        -- Encode Base64 in-place (normal mode)
        encode_base64_inplace = "gB",

        -- Encode Base64 in-place (visual mode)
        vencode_base64_inplace = "gB",

        -- Decode Base64URL in-place (normal mode)
        decode_base64url_inplace = "gys",

        -- Decode Base64URL in-place (visual mode)
        vdecode_base64url_inplace = "gys",

        -- Decode Base64URL in a popup (normal mode)
        decode_base64url_popup = "gs",

        -- Decode Base64URL in a popup (visual mode)
        vdecode_base64url_popup = "gs",

        -- Encode Base64URL in-place (normal mode)
        encode_base64url_inplace = "gS",

        -- Encode Base64URL in-place (visual mode)
        vencode_base64url_inplace = "gS",

        -- Decode URL in-place (normal mode)
        decode_url_inplace = "gyl",

        -- Decode URL in-place (visual mode)
        vdecode_url_inplace = "gyl",

        -- Decode URL in a popup (normal mode)
        decode_url_popup = "gl",

        -- Decode URL in a popup (visual mode)
        vdecode_url_popup = "gl",

        -- Encode URL in-place (normal mode)
        encode_url_inplace = "gL",

        -- Encode URL in-place (visual mode)
        vencode_url_inplace = "gL",
    },

    -- Popup window settings
    popup = {
        -- Whether to enter popup window on open or no
        enter = true,

        -- Whether to show window title (with encoding type) or not
        show_title = true,

        -- Border style, as specified in 'nvim_open_win'.
        -- Normally, one of: 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
        border = "rounded",

        -- Pseudo-transparency (see 'winblend').
        -- Set to 0 to disable.
        transparency = 10,

        --- Popup window width limits
        width = { min = 10, max = 80 },

        --- Popup window height limits
        height = { min = 1, max = 50 },

        --- Keys to close the popup window. Any key from the lists closes it.
        close_on = { "<Esc>", "q" },
    },
}

--- Check if there are any keys present in "cfg" that are missing in "config".
--- Warns for each unknown key found.
---
--- @param cfg table
local function check_unknown_keys(cfg)
    local unknown_keys = {}

    local function check_keys(c, def, path)
        for key, val in pairs(c) do
            if type(key) == "string" then
                if def == nil or def[key] == nil then
                    table.insert(unknown_keys, path .. key)
                elseif type(val) == "table" then
                    check_keys(val, def[key], path .. key .. ".")
                end
            end
        end
    end

    check_keys(cfg, config, "")

    if #unknown_keys > 0 then
        vim.schedule(function()
            vim.notify(
                "Unknown key(s) detected in endec.nvim config:\n  " .. table.concat(unknown_keys, "\n  "),
                vim.log.levels.WARN
            )
        end)
    end
end

--- Apply configuration.
---
--- @param cfg table
M.setup = function(cfg)
    check_unknown_keys(cfg)

    if cfg.keymaps ~= nil and cfg.keymaps.defaults == false then
        config.keymaps = {}
    end

    local new = vim.tbl_deep_extend("force", {}, config, cfg or {})

    for _, key in ipairs(vim.tbl_keys(config)) do
        config[key] = nil
    end

    for key, value in pairs(new) do
        config[key] = value
    end
end

return setmetatable(config, { __index = M })
