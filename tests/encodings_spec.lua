-- Base64 tests
describe("Base64", function()
    -- Encoding
    it("properly encodes data", function()
        -- Test vectors from RFC 4648 section 10
        local b64 = require("endec.base64")

        local encoded, err = b64.encode("")
        assert.is_nil(err)
        assert.equals("", encoded)

        assert.equals("Zg==", b64.encode("f"))
        assert.equals("Zm8=", b64.encode("fo"))
        assert.equals("Zm9v", b64.encode("foo"))
        assert.equals("Zm9vYg==", b64.encode("foob"))
        assert.equals("Zm9vYmE=", b64.encode("fooba"))
        assert.equals("Zm9vYmFy", b64.encode("foobar"))
    end)

    -- Decoding
    it("properly decodes data", function()
        -- Test vectors from RFC 4648 section 10
        local b64 = require("endec.base64")

        local plain, err = b64.decode("")
        assert.is_nil(err)
        assert.equals("", plain)

        assert.equals("f", b64.decode("Zg=="))
        assert.equals("fo", b64.decode("Zm8="))
        assert.equals("foo", b64.decode("Zm9v"))
        assert.equals("foob", b64.decode("Zm9vYg=="))
        assert.equals("fooba", b64.decode("Zm9vYmE="))
        assert.equals("foobar", b64.decode("Zm9vYmFy"))
    end)

    -- Errors
    it("handles errors", function()
        local b64 = require("endec.base64")

        local plain, err = b64.decode("@")
        assert.equals("Invalid input", err)
        assert.equals("", plain)

        plain, err = b64.decode("Zm8")
        assert.equals("Invalid input", err)
        assert.equals("", plain)
    end)
end)

-- Base64URL tests
describe("Base64URL", function()
    -- Encoding
    it("properly encodes data", function()
        local b64 = require("endec.base64")

        local encoded, err = b64.encode_url_safe("<????>fo")
        assert.is_nil(err)
        assert.equals("PD8_Pz8-Zm8", encoded)

        assert.equals("PD8_Pz8-Zm9vYg", b64.encode_url_safe("<????>foob"))
    end)

    -- Decoding
    it("properly decodes data", function()
        local b64 = require("endec.base64")

        local plain, err = b64.decode_url_safe("PD8_Pz8-Zm8")
        assert.is_nil(err)
        assert.equals("<????>fo", plain)

        assert.equals("<????>foob", b64.decode_url_safe("PD8_Pz8-Zm9vYg"))
    end)

    -- Errors
    it("handles errors", function()
        local b64 = require("endec.base64")

        local plain, err = b64.decode_url_safe("@")
        assert.equals("Invalid input", err)
        assert.equals("", plain)

        plain, err = b64.decode_url_safe("Zm8==")
        assert.equals("Invalid input", err)
        assert.equals("", plain)
    end)
end)

-- URL encoding tests
describe("URL", function()
    -- Encoding
    it("properly encodes data", function()
        local url = require("endec.url")

        local encoded, err = url.encode("")
        assert.is_nil(err)
        assert.equals("", encoded)

        assert.equals("foobar-._~", url.encode("foobar-._~"))
        assert.equals("foo%3Dbar%2F%20%40%25", url.encode("foo=bar/ @%"))
    end)

    -- Decoding
    it("properly decodes data", function()
        local url = require("endec.url")

        local plain, err = url.decode("")
        assert.is_nil(err)
        assert.equals("", plain)

        assert.equals("foobar-._~", url.decode("foobar-._~"))
        assert.equals("foo=bar/ @%", url.decode("foo%3Dbar%2F%20%40%25"))
        assert.equals("technically_invalid%X_%_C21", url.decode("technically_invalid%X_%_%4321"))
    end)
end)
