# endec.nvim

A simple Neovim plugin for encoding and decoding text.
Supports Base64, Base64URL and URL-encoding (percent-encoding).

<div align="center">
  <img src="https://github.com/user-attachments/assets/c0261a85-c860-48a3-9d93-fe4240308414" />
</div>

## Features

- Encode and decode:
  - Base64 ([RFC 4648 section 4](https://datatracker.ietf.org/doc/html/rfc4648#section-4))
  - Base64 URL safe ([RFC 4648 section 5](https://datatracker.ietf.org/doc/html/rfc4648#section-5))
  - URL encoding / percent encoding ([RFC3986 section 2.1](https://datatracker.ietf.org/doc/html/rfc3986#section-2.1))
- Perform encoding/decoding in-place or view decoded text in a popup window.
    - Editing the decoded text in the popup, and writing back automatically re-encodes it.

## Requirements

This plugin requires **Neovim v0.10** or newer (leveraging built-in Base64 support).

## Installation

Installation instructions for popular plugin managers:

### Lazy.nvim
```lua
{
    "ovk/endec.nvim",
    event = "VeryLazy",
    opts = {
        -- Override default configuration here
    }
}
```

### packer.nvim

```lua
use({
    "ovk/endec.nvim",
    config = function()
        require("endec").setup({
            -- Override default configuration here
        })
    end
})
```

## Usage

There are three core operations (available for each encoding):

- Decode text in-place
- Decode text and show it in a popup window
- Encode text in place

The default key mappings setup so that these operations can either be triggered in:

- *Normal mode*: for example, `gb{motion}` to decode Base64 and show decoded text in a popup (more specific example - `gbi"` to "decode Base64 inside quotes").
- *Visual mode*: for example, `gB` to Base64-encode visually selected text.

### EOL

The encoded text can contain encoded EOL characters, which can be either Unix, Windows or Mac style.
However, when re-encoded, the plugin will use buffer's current EOL as specified by `fileformat`.
If preserving the original EOL in the encoded text is absolutely necessary, some other tool should be used.

### Multi-line Blocks

When re-encoding block of text that consists of multiple lines, the plugin tries to keep number of lines the same.
For example, if a block of five lines of Base64 is selected, decoded in a popup and then re-encoded back,
the plugin will try to keep it at same five lines, but the lines will be shorter/longer, depending on how the text was edited.

## Configuration

The default configuration options are specified and documented [here](https://github.com/ovk/endec.nvim/blob/main/lua/endec/config.lua).

By default, all key mappings for all encodings are enabled, but any default mapping can be disabled by setting the corresponding mapping to and empty string
(for example - `encode_url_inplace = ""`).

### Default Key Mappings

The mappings below work for both visual and normal modes (mapping should be followed by a motion in normal mode).

| Mapping | Description |
| --- | --- |
| `gb` | Decode *Base64* in a popup |
| `gyb` | Decode *Base64* in-place |
| `gB` | Encode *Base64* in-place |
| `gs` | Decode *Base64URL* in a popup |
| `gys` | Decode *Base64URL* in-place |
| `gS` | Encode *Base64URL* in-place |
| `gl` | Decode *URL* in a popup |
| `gyl` | Decode *URL* in-place |
| `gL` | Encode *URL* in-place |

