local set_content = function(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end
local assert_content = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end
local set_cursor = function(pos)
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

describe("Normal mode", function()
    before_each(function()
        vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
    end)

    it("decodes a word in-place", function()
        set_content({ "Foo", "QmFy", "Baz" })
        set_cursor({ 2, 1 })
        vim.cmd("normal gybaw")

        assert_content({ "Foo", "Bar", "Baz" })
    end)

    it("decodes a line in-place", function()
        set_content({ "Foo", "SGVsbG8gV29ybGQh", "Baz" })
        set_cursor({ 2, 1 })
        vim.cmd("normal gyb$")

        assert_content({ "Foo", "Hello World!", "Baz" })
    end)

    it("decodes a paragraph in-place", function()
        set_content({ "Foo", "", "SGVsb", "G8gV29", "ybGQh", "", "Baz" })
        set_cursor({ 4, 3 })
        vim.cmd("normal gybap")

        assert_content({ "Foo", "", "Hello World!", "", "Baz" })
    end)

    it("encodes a word in-place", function()
        set_content({ "Foo", "Bar", "Baz" })
        set_cursor({ 2, 1 })
        vim.cmd("normal gBaw")

        assert_content({ "Foo", "QmFy", "Baz" })
    end)

    it("encodes a line in-place", function()
        set_content({ "Foo", "Hello World!", "Baz" })
        set_cursor({ 2, 1 })
        vim.cmd("normal gB$")

        assert_content({ "Foo", "SGVsbG8gV29ybGQh", "Baz" })
    end)

    it("encodes a paragraph in-place", function()
        set_content({ "Foo", "", "Hello", "World", "!", "", "Baz" })
        set_cursor({ 4, 3 })
        vim.cmd("normal gBap")

        assert_content({ "Foo", "", "SGVsbG8", "KV29ybG", "QKIQ==", "", "Baz" })
    end)
end)
