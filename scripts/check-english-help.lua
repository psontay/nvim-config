-- Headless behavior checks for the English learning interface.
-- Run: nvim --headless -c "luafile scripts/check-english-help.lua"
-- This checks real Snacks windows and picker results, not terminal rendering.
vim.api.nvim_exec_autocmds("UIEnter", {})

vim.defer_fn(function()
  local ok, err = xpcall(function()
    local kh = require("custom.keyhelp")
    assert(#kh.items() == 333, "KeyHelp entry count changed")
    local function text(buf)
      return table.concat(vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false), "\n")
    end
    for _, key in ipairs({ "e", "ciw", "d" }) do
      vim.cmd("KeyHelp " .. key)
      assert(text():find("# " .. key .. "  —", 1, true), "No detail view for " .. key)
      assert(text():find("**Example:**", 1, true), "No English example for " .. key)
      vim.cmd.close()
    end
    for n = 1, 4 do
      vim.cmd("KeyHelp level " .. n)
      assert(text():find("# Level " .. n, 1, true), "Missing level " .. n)
      assert(text():find("Tip:", 1, true) or text():find("Pattern:", 1, true), "Missing English learning tip")
      vim.cmd.close()
    end
    local notify = vim.notify
    local notice
    vim.notify = function(message)
      notice = message
    end
    vim.cmd("KeyHelp level 0")
    vim.notify = notify
    assert(notice == "Choose a learning level from 1 to 4.", "Invalid level was not handled")
    for _, query in ipairs({ "ciw", "delete", "window", "register", "rename", "debug", "Movement" }) do
      kh.pick(query)
      assert(
        vim.wait(3000, function()
          return #Snacks.picker.get() > 0
        end, 10),
        "Picker did not open"
      )
      local picker = Snacks.picker.get()[1]
      assert(picker, "No picker for " .. query)
      assert(
        vim.wait(5000, function()
          return not picker:is_active()
        end, 10),
        "Picker timed out: " .. query
      )
      local results = picker:items()
      if query == "ciw" then
        assert(
          vim.iter(results):any(function(entry)
            return entry.item.key == "ciw"
          end),
          "Exact key entry missing"
        )
      end
      assert(#results > 0 and #results < 333, "Search was not filtered: " .. query)
      assert(
        vim.iter(results):any(function(entry)
          return entry.text:lower():find(query:lower(), 1, true) ~= nil
        end),
        "No matching English text: " .. query
      )
      io.stdout:write(string.format("PASS search %-10s %d results\n", query, #results))
      picker:close()
    end
    local select = vim.ui.select
    local selections
    vim.ui.select = function(items, opts, callback)
      selections = { items = items, opts = opts, callback = callback }
    end
    vim.cmd("KeyHelp docs")
    vim.ui.select = select
    assert(selections and #selections.items == 3, "Documentation menu changed")
    assert(selections.opts.prompt == "Configuration documentation", "Menu is not English")
    for _, choice in ipairs(selections.items) do
      selections.callback(choice)
      assert(vim.bo.modifiable == false and vim.bo.readonly, "Document is not protected while reading")
      assert(vim.api.nvim_buf_get_name(0) == choice[2], "Wrong document opened")
      vim.cmd.close()
    end
    vim.cmd("KeyHelp guides")
    assert(
      vim.wait(3000, function()
        return #Snacks.picker.get() > 0
      end, 10),
      "Guide picker did not open"
    )
    local picker = Snacks.picker.get()[1]
    assert(picker and picker:cwd():match("/NEOVIM_GUIDES$"), "Wrong guide directory")
    assert(
      vim.wait(5000, function()
        return not picker:is_active()
      end, 10),
      "Guide picker timed out"
    )
    local index
    for _, item in ipairs(picker:items()) do
      if item.file:match("00_INDEX%.txt$") then
        index = item
      end
    end
    assert(index, "Guide index is missing from the picker")
    picker:action("confirm")
    assert(
      vim.wait(3000, function()
        return vim.api.nvim_buf_get_name(0):find("/NEOVIM_GUIDES/", 1, true) ~= nil
      end, 10),
      "Guide did not open"
    )
    if not picker.closed then
      picker:close()
    end
    vim.cmd.edit(vim.fn.stdpath("config") .. "/NEOVIM_GUIDES/00_INDEX.txt")
    for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      local col = line:find("01_SURVIVAL.txt", 1, true)
      if col then
        vim.api.nvim_win_set_cursor(0, { row, col - 1 })
        break
      end
    end
    vim.api.nvim_feedkeys("gf", "xt", false)
    assert(vim.api.nvim_buf_get_name(0):match("/01_SURVIVAL%.txt$"), "Guide cross-reference did not open with gf")
    io.stdout:write(
      "PASS: 333 entries, key details, four levels, English search, docs menu, guide picker, gf navigation\n"
    )
  end, debug.traceback)
  if not ok then
    io.stdout:write("FAIL: " .. err .. "\n")
  end
  vim.cmd(ok and "qall!" or "cquit 1")
end, 1500)
