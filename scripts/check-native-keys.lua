-- Real native key behavior checks after the configured plugins load.
-- Run: nvim --headless -c "luafile scripts/check-native-keys.lua"
vim.api.nvim_exec_autocmds("UIEnter", {})
vim.defer_fn(function()
  local ok, err = xpcall(function()
    require("lazy").load({ plugins = { "blink.cmp", "mini.ai", "mini.surround" } })
    vim.opt.clipboard = "" -- A desktop clipboard is outside this test.
    vim.cmd.enew()
    vim.bo.buftype = "nofile"
    local function lines(value)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, value)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end
    local function keys(value)
      vim.api.nvim_feedkeys(vim.keycode(value), "xt", false)
    end
    local function text()
      return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    end
    for _, key in ipairs({ "j", "k", "H", "L", "n", "N", "s", "S", "f", "t", "ga", "gr" }) do
      assert(vim.fn.maparg(key, "n") == "", "Native key is mapped: " .. key)
    end
    assert(vim.fn.maparg("<C-k>", "i") == "", "Insert Ctrl-k is mapped")
    lines({ "one two three" })
    keys("e")
    assert(vim.api.nvim_win_get_cursor(0)[2] == 2, "e did not reach the word end")
    keys("wge")
    assert(vim.api.nvim_win_get_cursor(0)[2] == 2, "ge did not go back to the word end")
    keys("0d2w")
    assert(text() == "three", "d2w changed behavior")
    lines({ "alpha beta" })
    keys("ciwnew<Esc>w.")
    assert(text() == "new new", "ciw or dot repeat changed behavior")
    lines({ "" })
    keys("i<C-k>ae<Esc>")
    assert(text() == "æ", "Native digraph input failed")
    lines({ "foo", "bar", "foo", "bar", "foo" })
    vim.api.nvim_win_set_cursor(0, { 5, 0 })
    keys("?foo<CR>n")
    assert(vim.api.nvim_win_get_cursor(0)[1] == 1, "n did not follow backward search")
    lines({ "a", "b", "c", "d" })
    keys("qaA!<Esc>jq2@a")
    assert(text() == "a!\nb!\nc!\nd", "Macro recording or playback changed")
    vim.fn.setreg("a", "saved")
    lines({ "delete", "keep" })
    keys('"_dd"ap')
    assert(text() == "ksavedeep", "Register or black hole behavior changed")
    local count = #vim.api.nvim_tabpage_list_wins(0)
    keys("<C-w>v")
    assert(#vim.api.nvim_tabpage_list_wins(0) == count + 1, "Native window split failed")
    io.stdout:write(
      "PASS: native mappings, e/ge, d2w, ciw, dot, digraph, backward search, Macro, Registers, window split\n"
    )
  end, debug.traceback)
  if not ok then
    io.stdout:write("FAIL: " .. err .. "\n")
  end
  vim.cmd(ok and "qall!" or "cquit 1")
end, 1500)
