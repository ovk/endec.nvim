local ctrl_v = vim.api.nvim_replace_termcodes("<C-v>", true, false, true)

local set_content = function(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end
local assert_content = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end
local set_cursor = function(pos)
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

describe("Visual mode", function()
    before_each(function()
        vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
    end)

    it("decodes visual selection", function()
        set_content({ "Foo", "(QmFy)", "Baz" })
        set_cursor({ 2, 2 })
        vim.cmd("normal! v")
        set_cursor({ 2, 5 })
        vim.cmd("normal gyb")

        assert_content({ "Foo", "(Bar)", "Baz" })
    end)

    it("decodes visual line selection", function()
        set_content({ "Foo", "T25lClR3b", "wpUaHJlZQ==", "Baz" })
        set_cursor({ 2, 3 })
        vim.cmd("normal! V")
        set_cursor({ 3, 3 })
        vim.cmd("normal gyb")

        assert_content({ "Foo", "One", "Two", "Three", "Baz" })
    end)

    it("decodes visual block selection", function()
        set_content({ "Foo", "SGVs", "bG8g", "V29y", "bGQh", "Baz" })
        set_cursor({ 2, 1 })
        vim.cmd("normal! " .. ctrl_v)
        set_cursor({ 5, 4 })
        vim.cmd("normal gyb")

        assert_content({ "Foo", "Hello World!", "Baz" })
    end)

    it("encodes visual selection", function()
        set_content({ "Foo", "(Bar)", "Baz" })
        set_cursor({ 2, 2 })
        vim.cmd("normal! v")
        set_cursor({ 2, 4 })
        vim.cmd("normal gB")

        assert_content({ "Foo", "(QmFy)", "Baz" })
    end)

    it("encodes visual line selection", function()
        set_content({ "Foo", "One", "Two", "Three", "Baz" })
        set_cursor({ 2, 3 })
        vim.cmd("normal! V")
        set_cursor({ 4, 3 })
        vim.cmd("normal gB")

        assert_content({ "Foo", "T25lClR", "3bwpUaH", "JlZQ==", "Baz" })
    end)

    it("encodes visual block selection", function()
        set_content({ "Foo", "One", "Two", "Three", "Baz" })
        set_cursor({ 2, 1 })
        vim.cmd("normal! " .. ctrl_v)
        set_cursor({ 4, 5 })
        vim.cmd("normal gB")

        assert_content({ "Foo", "T25lClR", "3bwpUaH", "JlZQ==", "Baz" })
    end)
end)
