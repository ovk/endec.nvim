local config = require("endec.config")

local M = {}

--- Setup key mappings.
M.setup = function()
    -- <Plug> placeholders
    local plugmaps = {
        { name = "Decode Base64", lhs = "<Plug>(endec-decode-base64)", func = "op_decode_base64" },
        { name = "Decode Base64 (popup)", lhs = "<Plug>(endec-pdecode-base64)", func = "op_pdecode_base64" },
        { name = "Encode Base64", lhs = "<Plug>(endec-encode-base64)", func = "op_encode_base64" },

        { name = "Decode Base64URL", lhs = "<Plug>(endec-decode-base64url)", func = "op_decode_base64url" },
        { name = "Decode Base64URL (popup)", lhs = "<Plug>(endec-pdecode-base64url)", func = "op_pdecode_base64url" },
        { name = "Encode Base64URL", lhs = "<Plug>(endec-encode-base64url)", func = "op_encode_base64url" },

        { name = "Decode URL", lhs = "<Plug>(endec-decode-url)", func = "op_decode_url" },
        { name = "Decode URL (popup)", lhs = "<Plug>(endec-pdecode-url)", func = "op_pdecode_url" },
        { name = "Encode URL", lhs = "<Plug>(endec-encode-url)", func = "op_encode_url" },
    }

    for _, mapping in ipairs(plugmaps) do
        vim.keymap.set("n", mapping.lhs, function()
            vim.go.operatorfunc = "v:lua.require'endec'." .. mapping.func
            return "g@"
        end, {
            desc = mapping.name,
            silent = true,
            expr = true,
        })
    end

    -- Keymaps
    local keymaps = {
        {
            name = "Decode Base64",
            lhs = config.keymaps.decode_base64_inplace,
            normal = "<Plug>(endec-decode-base64)",
            visual = function()
                require("endec").vdecode("base64", false)
            end,
        },
        {
            name = "Decode Base64 (popup)",
            lhs = config.keymaps.decode_base64_popup,
            normal = "<Plug>(endec-pdecode-base64)",
            visual = function()
                require("endec").vdecode("base64", true)
            end,
        },
        {
            name = "Encode Base64",
            lhs = config.keymaps.encode_base64_inplace,
            normal = "<Plug>(endec-encode-base64)",
            visual = function()
                require("endec").vencode("base64")
            end,
        },

        {
            name = "Decode Base64URL",
            lhs = config.keymaps.decode_base64url_inplace,
            normal = "<Plug>(endec-decode-base64url)",
            visual = function()
                require("endec").vdecode("base64url", false)
            end,
        },
        {
            name = "Decode Base64URL (popup)",
            lhs = config.keymaps.decode_base64url_popup,
            normal = "<Plug>(endec-pdecode-base64url)",
            visual = function()
                require("endec").vdecode("base64url", true)
            end,
        },
        {
            name = "Encode Base64URL",
            lhs = config.keymaps.encode_base64url_inplace,
            normal = "<Plug>(endec-encode-base64url)",
            visual = function()
                require("endec").vencode("base64url")
            end,
        },

        {
            name = "Decode URL",
            lhs = config.keymaps.decode_url_inplace,
            normal = "<Plug>(endec-decode-url)",
            visual = function()
                require("endec").vdecode("url", false)
            end,
        },
        {
            name = "Decode URL (popup)",
            lhs = config.keymaps.decode_url_popup,
            normal = "<Plug>(endec-pdecode-url)",
            visual = function()
                require("endec").vdecode("url", true)
            end,
        },
        {
            name = "Encode URL",
            lhs = config.keymaps.encode_url_inplace,
            normal = "<Plug>(endec-encode-url)",
            visual = function()
                require("endec").vencode("url")
            end,
        },
    }

    for _, mapping in ipairs(keymaps) do
        if #mapping.lhs > 0 then
            vim.keymap.set("n", mapping.lhs, mapping.normal, { desc = mapping.name })
            vim.keymap.set("x", mapping.lhs, mapping.visual, { desc = mapping.name, silent = true })
        end
    end
end

return M
