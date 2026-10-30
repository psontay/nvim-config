# KEYMAPS — Key reference

> Generated from `lua/custom/keyhelp/data.lua`, the same source used by `:KeyHelp`.
> Edit the source data, then run `nvim --headless -l scripts/gen-keymaps-doc.lua`.
> Verify Plugin and Custom mappings with `scripts/check-keyhelp.lua`. LSP mappings require attached Go and Java buffers.

**Leader** = `Space`. **Mode:** N=Normal, V=Visual, O=Operator-pending (after `d`/`c`/`y`), I=Insert, C=Command-line, T=Terminal.
The prefixes `i_`, `c_`, and `t_` mean: press the key in Insert, Command-line, or Terminal Mode.

**Native** = built into Vim/Neovim. **Plugin** = provided by LazyVim or a plugin. **Custom** = added by this configuration.

In Neovim: `<leader>hh` searches, `:KeyHelp e` explains a key, `<leader>h1` through `<leader>h4` open learning levels, and `<leader>hm` lists active mappings.

## Restored Vim and Neovim behavior

| Key | Current behavior | Previous override |
|---|---|---|
| `H` / `L` | Top / bottom visible text line | Buffer navigation (use `[b` / `]b`) |
| `n` / `N` | Follow / reverse the last search direction | Always forward / backward |
| `j` / `k` | Move by real lines | Screen-line movement with `gj` / `gk` |
| `s` / `S` | Change a character / line | Flash jumps (plugin disabled) |
| `f` `t` `;` `,` | Native character search within a line | Flash character search |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Native keys; `<C-l>` also clears search highlights | Window movement (use `<C-w>h/j/k/l`) |
| `<` `>` (Visual) | Shift and leave Visual Mode; dot repeats | Keep the selection |
| `grr` `grn` `gra` `gri` `grt` | Neovim LSP mappings | Blocked by the `gr` mapping with nowait |
| `ga` | Show character codes | Call hierarchy prefix (use `<leader>ci` / `<leader>cI`) |
| `i_<C-k>` | Enter a digraph (a character typed using two keys) | Signature help (use `i_<C-s>`) |
| `i_<C-s>` | Neovim signature help | Save file (`<C-s>` still saves in Normal / Visual Mode) |

## Level 1 — Survival

### Modes

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<Esc>` | Return to Normal Mode. In this setup, Normal Mode Esc also clears search highlights. | `Type text, then press <Esc> to use commands.` | I,V,C,O | Native |
| `<C-[>` | Return to Normal Mode, like Esc. | `Press <C-[> while typing.` | I,V,C,O | Native |
| `i` | Enter Insert Mode before the cursor. | `Press i, then type.` | N | Native |
| `a` | Enter Insert Mode after the cursor (append). | `Press a, then type.` | N | Native |
| `I` | Enter Insert Mode at the first non-blank character of the line. | `I// adds a comment marker at the start.` | N | Native |
| `A` | Enter Insert Mode at the end of the line. | `A; adds a semicolon at the end.` | N | Native |
| `o` | Open a new line below and enter Insert Mode. | `Press o, then write a new line of code.` | N | Native |
| `O` | Open a new line above and enter Insert Mode. | `Press O to add a comment above a function.` | N | Native |
| `v` | Start Visual Mode to select characters. | `v, then move, then press d, y, or c.` | N | Native |

### File

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `:w` | Save the file. | `:w; auto-save also writes files after editing.` | C | Native |
| `<C-s>` | Save the file. Formatting runs unless disabled, as it is for Java. | `<C-s> in Normal Mode or Visual Mode.` | N,V | Plugin |
| `:q` | Close this window. Exit Neovim if it is the last window. | `:q` | C | Native |
| `:q!` | Close this window and discard changes that are still unsaved. | `:q! cannot undo changes already written by auto-save.` | C | Native |
| `:wq` | Save the file, then close this window. | `:wq; :x writes only when the file has changed.` | C | Native |
| `:qa` | Quit all Neovim windows. | `:qa; <leader>qq also quits all windows.` | C | Native |
| `ZZ` | Save if changed, then close this window, like :x. | `ZZ` | N | Native |
| `ZQ` | Close without saving, like :q!. | `ZQ; auto-saved changes are already on disk.` | N | Native |
| `:e` | Open a file by its path. Tab completes the path. | `:e src/main/java/App.java; :e! reloads and discards unsaved changes.` | C | Native |
| `<leader><space>` | Find and open a project file with fuzzy search. | `Press Space twice, type usersvc, then press Enter.` | N | Plugin |

### Movement

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `h` | Move left by one character. | `5h moves left by five characters.` | N,V,O | Native |
| `j` | Move down by one real line. | `10j moves down ten lines; use the relative line numbers.` | N,V,O | Native |
| `k` | Move up by one real line. | `3k moves up three lines.` | N,V,O | Native |
| `l` | Move right by one character. | `4l moves right by four characters.` | N,V,O | Native |
| `w` | Move to the start of the next word. Punctuation can form a separate word. | `3w; dw deletes toward the next word; cw changes a word.` | N,V,O | Native |
| `b` | Move back to the start of this word or the previous word. | `2b; db deletes back to a word start.` | N,V,O | Native |
| `e` | Move to the end of the current or next word. | `3e; de deletes through the word end without its following space.` | N,V,O | Native |
| `0` | Move to the first column of the line. | `0; d0 deletes back to the first column, excluding the cursor.` | N,V,O | Native |
| `^` | Move to the first non-blank character of the line. | `^ skips indentation; c^ changes back to that point.` | N,V,O | Native |
| `$` | Move to the end of the line. | `$; d$ or D deletes through the line end.` | N,V,O | Native |
| `gg` | Move to the first line, or to the line given by a count. | `gg; 25gg goes to line 25; dgg deletes toward the first line.` | N,V,O | Native |
| `G` | Move to the last line, or to the line given by a count. | `G; 42G goes to line 42; ggVG selects the file.` | N,V,O | Native |
| `:{n}` | Jump to line number n. | `:120 goes to line 120.` | C | Native |
| `<C-d>` | Scroll down by half a screen. | `<C-d>` | N,V | Native |
| `<C-u>` | Scroll up by half a screen. | `<C-u>` | N,V | Native |
| `<C-f>` | Scroll down by one page. | `<C-f>` | N,V | Native |
| `<C-b>` | Scroll up by one page. | `<C-b>` | N,V | Native |

### Editing

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `x` | Delete the character under the cursor, or the Visual selection. | `x; 3x deletes three characters.` | N,V | Native |
| `X` | Delete the character before the cursor. | `X` | N | Native |
| `dd` | Delete (cut) the whole line. Paste it again with p. | `dd; 3dd deletes three lines.` | N | Native |
| `D` | Delete from the cursor through the end of the line. | `D is the same as d$.` | N | Native |
| `yy` | Yank (copy) the whole line. Interactive sessions use the system clipboard when available. | `yy then p; 5yy copies five lines.` | N | Native |
| `Y` | Yank from the cursor through the end of the line (Neovim default). | `Y is the same as y$.` | N | Native |
| `p` | Put text after the cursor, or below the line for linewise text. Visual Mode replaces the selection. | `p; 3p repeats the put; "0p uses the most recent yank.` | N,V | Native |
| `P` | Put text before the cursor, or above the line for linewise text. Visual Mode replaces the selection. | `P` | N,V | Native |
| `r` | Replace the character under the cursor with the next character you type. | `ra replaces it with a; 5r- replaces five characters with dashes.` | N,V | Native |
| `J` | Join the next line to this line, with space as needed. | `J; 3J joins three lines.` | N,V | Native |

### Undo

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `u` | Undo the most recent change. Persistent undo keeps history between sessions. | `u; 5u undoes five changes.` | N | Native |
| `<C-r>` | Redo a change that you undid. | `<C-r>` | N | Native |
| `.` | Repeat the most recent text change. | `ciwfoo<Esc>, move to another word, then press .` | N | Native |

### Search

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `/` | Search forward for a pattern. Press Enter to finish. | `/userId<CR>, then n or N; d/foo<CR> deletes up to foo.` | N,V,O | Native |
| `?` | Search backward for a pattern. | `?func<CR>` | N,V,O | Native |
| `n` | Find the next match in the direction of the last / or ? search. | `/foo<CR> n n n` | N,V,O | Native |
| `N` | Find a match in the opposite direction to the last search. | `N` | N,V,O | Native |
| `*` | Search forward for the whole word under the cursor. | `Press * on a variable name, then n for more matches.` | N,V,O | Native |
| `#` | Search backward for the whole word under the cursor. | `#` | N,V,O | Native |

### Learning

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `:Tutor` | Open the official interactive Vim lesson. Allow about 30 minutes. | `:Tutor or <leader>ht` | C | Native |
| `:help` | Open the official help. Follow a link with Ctrl-]; return with Ctrl-o. | `:help e; :help iw; :help CTRL-W` | C | Native |
| `<leader>hg` | Open the NEOVIM_GUIDES picker. Start with 00_INDEX.txt. | `<leader>hg, then type lsp and press Enter.` | N | Custom |

## Level 2 — Efficient editing

### Operator

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `d` | Delete (cut) text selected by a Motion or Text Object. | `dw dd d$ dG diw di( dap dt;` | N,V | Native |
| `c` | Delete text, then enter Insert Mode (change). | `ciw changes a word; ci" changes a string; cc changes a line.` | N,V | Native |
| `y` | Yank (copy) text selected by a Motion or Text Object. | `yiw yap y$ yi{` | N,V | Native |
| `dw` | Delete from the cursor toward the start of the next word, including space when present. | `dw on the u in user := repo deletes user and its space.` | N | Native |
| `diw` | Delete the word under the cursor without its surrounding space. | `diw works from the middle of repo.` | N | Native |
| `daw` | Delete the word and adjacent whitespace. | `daw removes a word and usually its following space.` | N | Native |
| `ciw` | Change the word under the cursor from any position within it. | `ciwnewName<Esc>, move to another word, then press .` | N | Native |
| `caw` | Change a word and its adjacent whitespace. | `caw enters Insert Mode; ciw usually suits code better.` | N | Native |
| `yiw` | Yank the word under the cursor. | `yiw, move, then p; "0p retrieves the last yank.` | N | Native |
| `dap` | Delete a paragraph and adjacent blank lines. | `dap; dip keeps surrounding blank lines.` | N | Native |
| `>` | Indent text to the right. Visual Mode ends after the shift. | `>> shifts one line; >ip shifts a paragraph; . repeats.` | N,V | Native |
| `<` | Indent text to the left. | `<< shifts one line; <i{ shifts a block body.` | N,V | Native |
| `=` | Reindent text using the active indentation rules. | `== for one line; =ap for a paragraph; gg=G for the file.` | N,V | Native |
| `gu` | Make text lowercase. | `guiw; guu changes the whole line.` | N,V | Native |
| `gU` | Make text uppercase. | `gUiw makes a constant name uppercase.` | N,V | Native |
| `gc` | Toggle comments using a Motion or a Visual selection (Neovim). | `gcc for one line; gcap for a paragraph; Visual Mode then gc.` | N,V,O | Native |
| `gw` | Wrap text to textwidth and keep the cursor position. | `gwip wraps a comment paragraph.` | N,V | Native |

### Visual

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `vip` | Select the paragraph: a block of lines between blank lines. | `vip, then d, y, >, or gc.` | N | Native |
| `V` | Start linewise Visual Mode. | `Vjjd deletes three lines; V} extends to a paragraph boundary.` | N | Native |
| `<C-v>` | Start blockwise Visual Mode to select columns. I or A can edit several lines. | `<C-v>3jI// <Esc> adds a comment prefix to four lines.` | N | Native |
| `gv` | Select the previous Visual selection again. | `gv` | N | Native |
| `o_visual` | In Visual Mode, move to the other end of the selection. | `v5jo moves to the other end so you can extend it.` | V | Native |

### Editing

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `cc` | Change the line, keeping indentation when autoindent is active. | `cc` | N | Native |
| `C` | Change from the cursor through the end of the line. | `C is the same as c$.` | N | Native |
| `s` | Delete a character and enter Insert Mode; change a selection in Visual Mode. | `s is like cl in Normal Mode.` | N,V | Native |
| `S` | Change the whole line, like cc. | `S` | N | Native |
| `R` | Enter Replace Mode to type over existing text. | `R, type, then press <Esc>.` | N | Native |
| `~` | Switch letter case under the cursor or in the Visual selection. | `~; g~iw switches case for a whole word.` | N,V | Native |
| `gcc` | Toggle the comment on this line. | `gcc; 3gcc toggles three lines.` | N | Native |
| `gco` | Add a comment line below (LazyVim). | `gco, then type a note.` | N | Plugin |
| `gcO` | Add a comment line above (LazyVim). | `gcO` | N | Plugin |

### Motion

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `W` | Move to the start of the next WORD: a sequence without whitespace. | `W; dW; user.getName() is one WORD.` | N,V,O | Native |
| `B` | Move back to the start of a WORD. | `B` | N,V,O | Native |
| `E` | Move to the end of a WORD. | `E; cE` | N,V,O | Native |
| `ge` | Move back to the end of the previous word. | `ge; dge` | N,V,O | Native |
| `gE` | Move back to the end of the previous WORD. | `gE` | N,V,O | Native |
| `f` | Find a character to the right on this line. | `f(; df, deletes through the comma; 2f" finds the second quote.` | N,V,O | Native |
| `F` | Find a character to the left on this line. | `F.` | N,V,O | Native |
| `t` | Move just before a character to the right (till). | `ct) changes text up to, but not including, ).` | N,V,O | Native |
| `T` | Move just after a character to the left. | `dT( deletes backward without deleting the opening parenthesis.` | N,V,O | Native |
| `;` | Repeat the last f, F, t, or T in the same direction. | `f, ; ; ;` | N,V,O | Native |
| `,` | Repeat the last f, F, t, or T in the opposite direction. | `f, ; ,` | N,V,O | Native |
| `%` | Jump between matching parentheses, brackets, or braces. | `Press % on {; d% deletes through its matching brace.` | N,V,O | Native |
| `{` | Move backward by a paragraph, usually to a blank line. | `{; d{` | N,V,O | Native |
| `}` | Move forward by a paragraph, usually to a blank line. | `}; y}` | N,V,O | Native |
| `H` | Move to the top visible text line (High). | `H; scrolloff can keep the cursor away from the edge.` | N,V,O | Native |
| `M` | Move to the middle visible text line. | `M` | N,V,O | Native |
| `L` | Move to the bottom visible text line (Low). | `L; scrolloff can keep the cursor away from the edge.` | N,V,O | Native |
| `gj` | Move down by a screen line when text wraps. | `gj; <leader>uw toggles wrapping.` | N,V,O | Native |
| `gk` | Move up by a screen line when text wraps. | `gk` | N,V,O | Native |

### Screen

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `zz` | Scroll to center the cursor line. | `zz` | N | Native |
| `zt` | Scroll to place the cursor line at the top. | `zt` | N | Native |
| `zb` | Scroll to place the cursor line at the bottom. | `zb` | N | Native |

### Text Object

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `iw` | Inner word: the word without surrounding whitespace. | `ciw, diw, yiw, viw` | V,O | Native |
| `aw` | A word: the word with adjacent whitespace. | `daw removes a word with space.` | V,O | Native |
| `iW` | Inner WORD: a sequence without whitespace. | `ciW changes user.getName() as one object.` | V,O | Native |
| `is` | Inner sentence. | `cis changes a sentence.` | V,O | Native |
| `ip` | Inner paragraph: consecutive non-blank lines. | `yip, >ip, =ip, gcip` | V,O | Native |
| `ap` | A paragraph with adjacent blank lines. | `dap` | V,O | Native |
| `i(` | Inside parentheses. Also written ib or i). | `ci( changes all function arguments.` | V,O | Native |
| `a(` | Parentheses and their contents. | `da(` | V,O | Native |
| `i{` | Inside braces. Also written iB. | `di{ deletes a function body; >i{ indents it.` | V,O | Native |
| `a{` | Braces and their contents. | `ya{` | V,O | Native |
| `i[` | Inside square brackets. | `ci[` | V,O | Native |
| `i<` | Inside angle brackets, such as Java type arguments. | `ci< changes String in List<String>.` | V,O | Native |
| `i"` | Inside double quotes. The next string on the line can also be selected. | `ci" changes string contents.` | V,O | Native |
| `a"` | Double quotes and their contents. | `da"` | V,O | Native |
| `i'` | Inside single quotes. | `ci'` | V,O | Native |
| `` i` `` | Inside backticks, such as a Go raw string or struct tag. | `` ci` changes a JSON tag. `` | V,O | Native |
| `it` | Inside an XML or HTML tag. | `cit inside <version>3.5.3</version>.` | V,O | Native |
| `at` | An XML or HTML tag and its contents. | `dat removes <dependency>...</dependency>.` | V,O | Native |
| `if` | Function body (Treesitter through mini.ai). | `vif selects the body; daf deletes a whole function.` | V,O | Plugin |
| `af` | Whole function, including its signature (Treesitter). | `yaf copies a method; ]f moves to the next function.` | V,O | Plugin |
| `ic` | Class body (Treesitter). | `vic selects a class body.` | V,O | Plugin |
| `ac` | Whole class (Treesitter). | `yac copies a class.` | V,O | Plugin |
| `ia` | One function argument. | `cia changes an argument; daa deletes it with a separator.` | V,O | Plugin |
| `aa` | An argument and its separating comma. | `daa` | V,O | Plugin |
| `io` | Inside a conditional, loop, or block (Treesitter). | `dio` | V,O | Plugin |
| `iq` | Inside the nearest pair of quotes: double, single, or backtick. | `ciq` | V,O | Plugin |
| `iu` | Inside a function call (Usage): its arguments. | `diu` | V,O | Plugin |
| `ie` | One part of a camelCase or snake_case name. | `cie on the User part of getUserName.` | V,O | Plugin |
| `ig` | The whole buffer (file). | `yig copies the file; =ig reindents it.` | V,O | Plugin |
| `ii` | Lines in the same indentation scope. | `dii; >ii` | V,O | Plugin |

### Count

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `{count}` | A count repeats a command or chooses its size. | `3dd; d3w equals 3dw; 5j; 2ci(` | N,V,O | Native |

### Buffer

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `:ls` | List open buffers. | `:ls, then :b 3 or :b user<Tab>.` | C | Native |
| `:b` | Switch to a buffer by number or part of its name. | `:b handler<Tab>` | C | Native |
| `[b` | Switch to the previous buffer. | `[b runs :bprevious.` | N | Plugin |
| `]b` | Switch to the next buffer. | `]b runs :bnext.` | N | Plugin |
| `<C-^>` | Switch between the current and alternate file. | `Service to Controller, then <C-^> returns to Service.` | N | Native |
| `<leader>,` | Pick an open buffer. | `<Space>, then type a file name.` | N | Plugin |
| `<leader>bd` | Close this buffer while keeping the window layout. | `<leader>bd` | N | Plugin |
| `<leader>bo` | Close all other buffers. | `<leader>bo` | N | Plugin |

### Window

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<C-w>s` | Split the window horizontally. | `<C-w>s or :sp file` | N | Native |
| `<C-w>v` | Split the window vertically. | `<C-w>v, then open a test beside the code.` | N | Native |
| `<C-w>h` | Move to the window on the left. | `<C-w>h; j, k, l move down, up, right.` | N | Native |
| `<C-w>j` | Move to the window below, such as the app terminal. | `<C-w>j` | N | Native |
| `<C-w>k` | Move to the window above. | `<C-w>k` | N | Native |
| `<C-w>l` | Move to the window on the right. | `<C-w>l` | N | Native |
| `<C-w>w` | Cycle through windows. | `<C-w>w` | N | Native |
| `<C-w>p` | Return to the previous window. | `<C-w>p` | N | Native |
| `<C-w>q` | Close this window. | `<C-w>q` | N | Native |
| `<C-w>o` | Keep only this window. | `<C-w>o closes the other windows.` | N | Native |
| `<C-w>=` | Make window sizes equal. | `<C-w>=` | N | Native |
| `<C-w>_` | Maximize this window's height. Use Ctrl-w \| for its width. | `<C-w>_; <C-w>\|` | N | Native |
| `<C-w>T` | Move this window to a new tab page. | `<C-w>T` | N | Native |
| `<C-w><Space>` | Enter which-key window mode to run several window commands. | `<C-w><Space>, then l l j; Esc exits.` | N | Plugin |

### Tab

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `gt` | Move to the next tab page, or tab number n with a count. | `gt; 2gt` | N | Native |
| `gT` | Move to the previous tab page. | `gT` | N | Native |
| `:tabnew` | Open a tab page: a window layout that can show several buffers. | `:tabnew; :tabclose closes it.` | C | Native |

### Jump

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<C-o>` | Go back in the jump list, including jumps between files. | `gd, read the definition, then <C-o> returns.` | N | Native |
| `<C-i>` | Go forward in the jump list. Some terminals send the same code for Tab. | `<C-i>` | N | Native |
| ``` `` ``` | Return to the exact position before the last jump. | ``` G, then `` to return; repeat to switch back. ``` | N | Native |
| `g;` | Go to an earlier change location in the change list. | `g; g;` | N | Native |
| `g,` | Go to a later change location. | `g,` | N | Native |
| `gi` | Enter Insert Mode where you last inserted text. | `gi` | N | Native |

### Insert

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `i_<C-w>` | In Insert Mode, delete the word before the cursor. | `After a mistyped word, press <C-w>.` | I | Native |
| `i_<C-u>` | In Insert Mode, delete text back toward the start of the line. | `<C-u>; deletion depends on where this Insert session started.` | I | Native |
| `i_<C-o>` | In Insert Mode, run one Normal Mode command, then return. | `<C-o>zz` | I | Native |
| `i_<C-r>` | In Insert Mode, insert text from a Register. | `<C-r>" uses the unnamed Register; <C-r>0 uses the last yank.` | I | Native |
| `i_<C-t>` | In Insert Mode, increase indentation. Ctrl-d decreases it. | `<C-t>` | I | Native |
| `i_<C-n>` | In the completion menu, select the next item; Ctrl-p selects the previous one. | `Type gre, then <C-n>, then <CR> to accept.` | I | Plugin |
| `i_<C-Space>` | In Insert Mode, open the completion menu manually. | `<C-Space>` | I | Plugin |
| `i_<C-e>` | In Insert Mode, cancel the completion menu and undo its preview. | `<C-e>` | I | Plugin |
| `i_<C-y>` | In Insert Mode, accept the selected completion. | `<C-y> or Enter when an item is selected.` | I | Plugin |
| `i_<Tab>` | In Insert Mode, move to the next snippet field; Shift-Tab moves back. | `Accept a snippet, then use Tab to move between its fields.` | I | Plugin |

### Replace

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `:s` | Replace text on this line or on the selected lines. | `:s/foo/bar/g; select lines, then :s/a/b/g.` | C | Native |
| `:%s` | Replace text in the whole file. The c flag asks about each match. | `:%s/userId/accountId/gc; preview appears while typing.` | C | Native |

### Fold

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `za` | Toggle the fold under the cursor. | `za on a long method.` | N | Native |
| `zc` | Close a fold. | `zc` | N | Native |
| `zo` | Open a closed fold. | `zo` | N | Native |
| `zR` | Open all folds. | `zR` | N | Native |
| `zM` | Close all folds to see the file structure. | `zM, then zo to open one part.` | N | Native |

## Level 3 — Development workflows

### Text Object

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `ih` | The current Git hunk: a group of changed lines. | `vih selects the hunk; dih deletes its current buffer text.` | V,O | Plugin |

### Mark

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `m` | Set a Mark: lowercase for this file, uppercase across files. | `ma then 'a; mS in Service and mC in Controller.` | N | Native |
| `'` | Jump to the line of a Mark. | `'a; d'a deletes through the marked line.` | N,V,O | Native |
| `` ` `` | Jump to a Mark's exact line and column. | `` `a; `. is the last change; `" is the position when the file closed. `` | N,V,O | Native |
| `:marks` | List Marks. | `:marks or <leader>sm for a picker.` | C | Native |
| `<leader>sm` | Find a Mark in a picker. | `<leader>sm` | N | Plugin |

### Register

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `"` | Choose a Register for the next command. | `"ayy yanks to a; "ap puts from a; "Ayy appends to a.` | N,V | Native |
| `"0` | Register 0 holds the most recent yank. Deletes do not replace it. | `yiw, then delete elsewhere; "0p still puts the yanked word.` | N,V | Native |
| `"_` | The black hole Register discards text without replacing other Registers. | `"_dd; Visual "_dP replaces a selection using the saved text.` | N,V | Native |
| `"+` | The system clipboard Register. Interactive y and p also use it when available. | `"+p; check :set clipboard? if clipboard sharing fails.` | N,V | Native |
| `:reg` | Show Register contents. | `:reg or <leader>s" for the picker.` | C | Native |
| `<leader>s"` | Choose a Register in a picker and put its text. | `<leader>s"` | N | Plugin |

### Macro

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `q` | Record a Macro: q plus a Register name; press q again to stop. | `qaA!<Esc>jq records an append and a move in Register a.` | N | Native |
| `@` | Run a Macro from a Register. | `@a; 10@a runs it ten times.` | N | Native |
| `@@` | Run the last executed Macro again. | `@@` | N | Native |
| `Q` | Run the last recorded Macro (Neovim default). | `Q` | N | Native |

### Quickfix

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `:copen` | Open the quickfix list of search results, references, or build errors. | `:copen; Enter jumps to an entry; <leader>xq toggles the window.` | C | Native |
| `]q` | Go to the next quickfix or Trouble entry. | `]q` | N | Native |
| `[q` | Go to the previous quickfix or Trouble entry. | `[q` | N | Native |
| `<leader>xq` | Toggle the quickfix window. | `<leader>xq` | N | Plugin |
| `<leader>xl` | Toggle the location list: a list for one window. | `<leader>xl` | N | Plugin |
| `:grep` | Search with ripgrep and put results in quickfix. | `:grep TODO . then :copen` | C | Native |
| `:cdo` | Run a command at each quickfix entry. | `:grep OldName . then :cdo s/OldName/NewName/g \| update` | C | Native |

### LSP

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `gd` | Go to the definition of a symbol. | `gd on h.svc.GetUser opens the service; <C-o> returns.` | N | Plugin |
| `gD` | Go to a symbol's declaration. | `gD` | N | Plugin |
| `gI` | Find implementations of an interface or method. | `gI on GreetingService.greet finds GreetingServiceImpl.` | N | Plugin |
| `gri` | Find implementations with Neovim's built-in LSP mapping. | `gri` | N | Native |
| `gy` | Go to a variable's type definition. | `gy on user opens struct User.` | N | Plugin |
| `grt` | Go to a type definition with Neovim's built-in LSP mapping. | `grt` | N | Native |
| `grr` | Find symbol references, usually in quickfix when there are several results. | `grr, then ]q or [q to browse.` | N | Native |
| `<leader>cu` | Find Usages: open references in a picker with previews. | `<leader>cu, similar to IntelliJ Alt+F7.` | N | Custom |
| `grn` | Rename a symbol through the Language Server. | `grn, type a new name, then Enter.` | N | Native |
| `<leader>cr` | Rename a symbol, like IntelliJ Shift+F6. | `<leader>cr` | N | Plugin |
| `gra` | Choose a code action or quick fix (Neovim). | `gra on a diagnostic, then choose a fix.` | N,V | Native |
| `<leader>ca` | Choose a code action: fixes, imports, or generated code. | `<leader>ca, similar to IntelliJ Alt+Enter.` | N,V | Plugin |
| `<leader>cA` | Choose a source action for the whole file. | `<leader>cA for organize imports or code generation.` | N | Plugin |
| `K` | Hover: show a symbol's documentation or type. Press K again to enter the popup. | `K on c.JSON` | N | Native |
| `gK` | Show a function signature and its parameters. | `gK` | N | Plugin |
| `i_<C-s>` | In Insert Mode, show signature help while entering arguments (Neovim). | `greet(<C-s>` | I | Native |
| `gO` | List symbols in this file with Neovim's built-in mapping. | `gO` | N | Native |
| `<leader>ss` | Find a symbol in this file, such as a method or field. | `<leader>ss, then type greet.` | N | Plugin |
| `<leader>sS` | Find a symbol in the workspace, such as a class or function. | `<leader>sS, then type UserHandler.` | N | Plugin |
| `<leader>cs` | Show a symbol outline in the side panel. | `<leader>cs, similar to the Structure tool window.` | N | Plugin |
| `<leader>ci` | Find incoming calls: functions that call this function. | `<leader>ci on a service method.` | N | Custom |
| `<leader>cI` | Find outgoing calls: functions called by this function. | `<leader>cI` | N | Custom |
| `<leader>cf` | Format the file or Visual selection. Go uses goimports; Java uses jdtls. | `<leader>cf; select text, then <leader>cf for a range.` | N,V | Plugin |
| `<leader>co` | Organize imports in Go or Java. | `<leader>co` | N | Plugin |
| `]]` | Go to the next highlighted reference in this file; [[ goes back. | `]] with a Language Server that supports document highlights.` | N | Plugin |
| `<leader>uh` | Toggle inlay hints: extra parameter names or inferred types in the code. | `<leader>uh; hints are off by default.` | N | Plugin |
| `<leader>cl` | Show LSP information for this buffer. | `<leader>cl or :checkhealth vim.lsp` | N | Plugin |

### Diagnostics

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>cd` | Show diagnostic details for the current line. | `<leader>cd` | N | Plugin |
| `]d` | Go to the next diagnostic (error or warning). | `]d, then <leader>ca for a fix; [d goes back.` | N | Plugin |
| `[d` | Go to the previous diagnostic. | `[d` | N | Plugin |
| `]e` | Go to the next error; [e goes to the previous error. | `]e` | N | Plugin |
| `]w` | Go to the next warning; [w goes to the previous warning. | `]w` | N | Plugin |
| `<leader>sd` | List workspace diagnostics in a picker. | `<leader>sd; <leader>sD shows this buffer only.` | N | Plugin |
| `<leader>xx` | Toggle the Trouble diagnostics panel. | `<leader>xx, similar to a Problems tool window.` | N | Plugin |

### Java

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>cxv` | Extract a Java expression into a variable. | `Select an expression, then <leader>cxv.` | N,V | Plugin |
| `<leader>cxc` | Extract a Java expression into a constant. | `<leader>cxc` | N,V | Plugin |
| `<leader>cxm` | Extract the selected Java code into a method. | `Select lines with V, then <leader>cxm.` | V | Plugin |
| `<leader>cgs` | Go to the superclass implementation of this Java method. | `<leader>cgs` | N | Plugin |
| `<leader>cgS` | Go to the subject class related to a Java test. | `<leader>cgS in a test class.` | N | Plugin |

### Search

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>ff` | Find a project file, like Space twice. | `<leader>ff` | N | Plugin |
| `<leader>fr` | Find a recently opened file. | `<leader>fr` | N | Plugin |
| `<leader>/` | Search project text with live grep. | `<leader>/, then type NotFound.` | N | Plugin |
| `<leader>sw` | Search the project for the word or Visual selection. | `<leader>sw` | N,V | Plugin |
| `<leader>sr` | Search and replace across files with grug-far. | `<leader>sr; review the results before applying changes.` | N,V | Plugin |
| `<leader>sb` | Find a line in this buffer. | `<leader>sb` | N | Plugin |
| `<leader>sR` | Resume the last picker. | `<leader>sR` | N | Plugin |
| `<leader>e` | Toggle the file explorer, which starts hidden. | `<leader>e; a creates, d deletes, r renames; ? in Normal Mode shows help.` | N | Plugin |

### Undo

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>su` | Browse the undo tree and restore an earlier file state. | `<leader>su` | N | Plugin |

### Surround

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `gsa` | Add surrounding characters using mini.surround. | `gsaiw" surrounds a word with quotes; Visual gsa) adds parentheses.` | N,V | Plugin |
| `gsd` | Delete surrounding characters. | `gsd" removes quotes; gsd) removes parentheses.` | N | Plugin |
| `gsr` | Replace surrounding characters. | `gsr"' changes double quotes to single quotes.` | N | Plugin |

### Git

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `]h` | Go to the next Git hunk (a group of changed lines); [h goes back. | `]h` | N | Plugin |
| `<leader>ghp` | Preview the current Git hunk. | `<leader>ghp` | N | Plugin |
| `<leader>ghs` | Stage a Git hunk, like git add for this part of the file. | `<leader>ghs` | N,V | Plugin |
| `<leader>ghr` | Reset a Git hunk, discarding its changes. Review it first. | `<leader>ghr` | N,V | Plugin |
| `<leader>ghb` | Show Git blame for this line: its author and commit. | `<leader>ghb` | N | Plugin |
| `<leader>ghd` | Diff this file against the index, or HEAD for a staged file. | `<leader>ghd; :help gitsigns.diffthis explains the base.` | N | Plugin |
| `<leader>gs` | Show Git status in a picker; Tab stages or unstages an entry. | `<leader>gs` | N | Plugin |
| `<leader>gd` | List changed Git hunks in the repository. | `<leader>gd` | N | Plugin |
| `<leader>gl` | Show the repository's commit history. | `<leader>gl` | N | Plugin |
| `<leader>gf` | Show commit history for this file. | `<leader>gf` | N | Plugin |

### Debug

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>db` | Set or remove a breakpoint. | `<leader>db on a line in a handler.` | N | Plugin |
| `<leader>dB` | Set a conditional breakpoint. | `<leader>dB, then id == 42.` | N | Plugin |
| `<leader>dc` | Start or continue debugging. Choose a Go or Java launch configuration. | `<leader>dc; Go: Debug app (module main package); Java: Launch ...` | N | Plugin |
| `<F9>` | Start or continue debugging, like IntelliJ F9. | `<F9>` | N | Custom |
| `<F8>` | Step over: run the current line without entering its functions. | `<F8>` | N | Custom |
| `<F7>` | Step into: enter a called function. | `<F7>` | N | Custom |
| `<S-F8>` | Step out: run until the current function returns. | `<S-F8>` | N | Custom |
| `<leader>dC` | Run to the cursor line. | `<leader>dC` | N | Plugin |
| `<leader>dt` | Terminate the debug session. | `<leader>dt` | N | Plugin |
| `<leader>du` | Toggle the debug panels for variables, call stack, and watches. | `<leader>du` | N | Plugin |
| `<leader>de` | Evaluate the expression under the cursor or in the selection. | `<leader>de during a paused debug session.` | N,V | Plugin |
| `<leader>dr` | Open the debug console (REPL) to evaluate expressions. | `<leader>dr, then name.toUpperCase() in Java.` | N | Plugin |

### Test

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>tt` | Run tests in this file (Go) or class (Java). | `<leader>tt in user_test.go or a Java test class.` | N | Plugin |
| `<leader>tr` | Run the test nearest the cursor. | `<leader>tr inside TestGetUser.` | N | Plugin |
| `<leader>tT` | Go: run all project tests. Java: choose a test to run. | `<leader>tT` | N | Plugin |
| `<leader>td` | Debug the nearest Go test through neotest. | `<leader>db, then <leader>td.` | N | Plugin |
| `<leader>to` | Show Go test output. Java test output uses the debug console. | `<leader>to for Go; <leader>dr for Java.` | N | Plugin |
| `<leader>ts` | Show the Go test results tree. | `<leader>ts` | N | Plugin |

### Run

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>rr` | Run the app using Go, Maven, or Gradle. | `<leader>rr, then call the app on its configured port.` | N | Custom |
| `<leader>rb` | Build the project using its build tool. | `<leader>rb: go build ./..., Maven package -DskipTests, or Gradle build -x test.` | N | Custom |
| `<leader>rt` | Run project tests using Go, Maven, or Gradle. | `<leader>rt: go test ./..., Maven test, or Gradle test.` | N | Custom |
| `<leader>rc` | Run a custom terminal command at the detected project root. | `<leader>rc, then docker compose up -d.` | N | Custom |
| `<leader>rl` | Run the last runner command again. | `<leader>rl` | N | Custom |

### Terminal

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<C-/>` | Toggle the floating terminal at the project root. | `<C-/>; some terminals send <C-_> instead.` | N,T | Plugin |
| `t_<C-\><C-n>` | In Terminal Mode, enter Normal Mode to scroll or copy output. | `<C-\><C-n>, then use /, ?, or y.` | T | Native |

### Session

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>qs` | Restore this directory's session: its files and window layout. | `Open Neovim in the project, then <leader>qs.` | N | Plugin |
| `<leader>qq` | Quit all windows. | `<leader>qq` | N | Plugin |
| `<leader>uv` | Toggle auto-save. | `<leader>uv` | N | Custom |

### Database

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>D` | Toggle the Database UI for SQL connections and queries. | `<leader>D; a adds a connection.` | N | Custom |

### Learning

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `<leader>hh` | Open the KeyHelp key and function picker. | `<leader>hh, then type delete or ciw.` | N | Custom |
| `<leader>hk` | Ask about a key sequence. | `<leader>hk, then e, ciw, or <C-w>v.` | N | Custom |
| `<leader>hm` | List all active keymaps, including plugin mappings. | `<leader>hm` | N | Custom |
| `<leader>hd` | Open README, KEYMAPS, or WORKFLOWS in a reading window. | `<leader>hd, then choose WORKFLOWS.` | N | Custom |
| `<leader>?` | Show buffer-local mappings with which-key. | `<leader>? in a Java file shows jdtls mappings.` | N | Plugin |

## Level 4 — Advanced Vim

### Advanced

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `cgn` | Change the current or next search match. Use dot to change another match. | `* then cgnnewName<Esc>; . repeats; n skips a match.` | N | Native |
| `gn` | Select the current or next search match. Operators can use it too. | `/foo<CR> then dgn or cgn.` | N,V,O | Native |
| `:g` | Run an Ex command on every line that matches a pattern. | `:g/TODO/d; :g/^func/normal A // review` | C | Native |
| `:v` | Run an Ex command on lines that do not match a pattern. | `:v/ERROR/d keeps only lines containing ERROR.` | C | Native |
| `:normal` | Run Normal Mode commands on a range of lines. | `:%normal A; or select lines, then :'<,'>normal @q.` | C | Native |
| `@:` | Repeat the last Ex command (a command entered after a colon). | `@:; then @@ repeats it again.` | N | Native |
| `&` | Repeat the last substitution on this line without its flags. | `&; g& repeats across the file using the previous flags.` | N | Native |
| `!` | Filter text through a shell command, replacing the text with its output. | `!ip sort; :%!jq . formats JSON if jq is installed.` | N,V | Native |
| `:read` | Read a file or command output into the buffer. | `:r !date; :r !go env GOPATH` | C | Native |
| `<C-a>` | Increase a number. In Visual Mode, g Ctrl-a creates an increasing sequence. | `5<C-a>; select lines of numbers, then g<C-a>.` | N,V | Native |
| `<C-x>` | Decrease a number. | `<C-x>` | N,V | Native |
| `:earlier` | Return to an earlier state in the undo history. | `:earlier 10m; :later 5m moves forward.` | C | Native |
| `gx` | Open the URL or path under the cursor with a system app. | `gx on a URL.` | N,V | Native |
| `gf` | Open the file whose name is under the cursor. | `gf on ./config/app.yml` | N | Native |
| `gJ` | Join lines without adding spaces. | `gJ` | N,V | Native |
| `ga` | Show the character's numeric code under the cursor. | `ga shows ASCII or Unicode values.` | N | Native |
| `:bufdo` | Run an Ex command in every listed buffer. | `:bufdo %s/foo/bar/ge \| update; review changes first.` | C | Native |
| `:sort` | Sort lines. The u flag removes duplicates; n sorts numbers. | `Select lines, then :sort u.` | C | Native |
| `:command` | Define a custom Ex command. | `:command! GoTidy !go mod tidy` | C | Native |

### Command-line

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `c_<C-r><C-w>` | In Command-line Mode, insert the word under the cursor. | `:%s/<C-r><C-w>/newName/g` | C | Native |
| `q:` | Open command history for editing with Vim keys; Enter runs a command. | `q: for commands; q/ for search history.` | N | Native |
| `<leader>:` | Open command history in a picker. | `<leader>:` | N | Plugin |
| `c_<C-f>` | While typing a command, open its command-line editing window. | `:%s/abc<C-f>` | C | Native |

### Macro

| Key | Action | Example | Mode | Source |
|---|---|---|---|---|
| `qA` | Append more recorded commands to Macro a. | `qA, record extra actions, then q to stop.` | N | Native |
| `:let @a` | Edit a Macro's Register as text. | `:let @a='0dw'; or put it with "ap, edit, and yank back with "ayy.` | C | Native |

