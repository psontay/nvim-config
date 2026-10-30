# WORKFLOWS — Daily Go/Gin and Java/Spring Boot work

Open this document with `<leader>hd`. `<leader>` means **Space**. Use `<leader>hh` to search by function or `:KeyHelp ciw` to explain a key. The [guides](../NEOVIM_GUIDES/00_INDEX.txt) provide exercises and deeper explanations.

## 1. Open a project

```bash
cd ~/Workspace/Vim/go-gin-demo && nvim
cd ~/Workspace/Vim/spring-demo && nvim
```

Open at the project root for predictable search and terminal scope. `<leader>qs` restores this directory's session. Open a Go or Java source file to start its Language Server. gopls normally attaches quickly; jdtls may need time to import Maven/Gradle dependencies. Watch the statusline and inspect `<leader>cl`. No fixed startup time is guaranteed.

## 2. Find files

| Task | Key or command |
|---|---|
| Find a project file | Space twice, type part of a name, Enter |
| Recent files | `<leader>fr` |
| Open buffers | `<leader>,` or `:ls`, then `:b name` |
| Alternate file | Ctrl-^ |
| Explorer | `<leader>e`; `a` creates, `r` renames, `d` deletes |
| Open a path | `:e internal/handler/user.go`; Tab completes |

In a picker, Ctrl-j/Ctrl-k selects a result. Ctrl-v opens a vertical split; Ctrl-s opens a horizontal split. These keys have picker-specific meanings. Press Esc to leave input or close. Press `?` in picker Normal Mode for help.

## 3. Find symbols or text

| Task | Key |
|---|---|
| Workspace symbols | `<leader>sS` |
| File symbols | `<leader>ss` or `gO` |
| Symbol outline | `<leader>cs` |
| Project text search | `<leader>/` |
| Search the cursor word or Visual selection across files | `<leader>sw` |
| Search this file | `/pattern`, then `n` / `N`; `*` searches a whole word |

A symbol is a named item such as a class or method. Symbol search needs LSP. `n` follows the direction of the last `/` or `?` search.

## 4. Read code

| Task | Key | Example |
|---|---|---|
| Definition | `gd` | handler call to service method |
| Implementation | `gI` | Java interface to implementation |
| References | `<leader>cu` or `grr` | callers and other uses |
| Type definition | `gy` | variable to its struct/class |
| Documentation | `K` | library API help |
| Incoming / outgoing calls | `<leader>ci` / `<leader>cI` | callers / called functions |
| Return / move forward after a jump | Ctrl-o / Ctrl-i | return from a definition |
| Next / previous diagnostic | `]d` / `[d` | `<leader>cd` opens details |

`]f` and `[f` move between functions when the Treesitter parser supports them. `%` matches brackets. `zz` centers the line. `zM` closes folds; `zo` opens one. Use `gd` on `gin.Default` or `SpringApplication.run` to read library source or Java decompiled text. Avoid editing dependency caches.

## 5. Refactor and format

| Task | Key or command |
|---|---|
| Rename a symbol | `<leader>cr` or `grn`, new name, Enter |
| Code action / quick fix | `<leader>ca` or `gra` |
| Organize imports | `<leader>co` |
| Format file or supported range | `<leader>cf`; use Visual Mode for a range |
| Java extract variable / constant | `<leader>cxv` / `<leader>cxc` |
| Java extract method | Visual selection, then `<leader>cxm` |
| Java generate members | `<leader>ca`, then an available Generate action |
| Project text replacement | `<leader>sr`; review before applying |
| File text replacement | `:%s/old/new/gc` |

Go manual save (`:w` or Normal/Visual Ctrl-s) runs goimports when enabled. Auto-save writes without formatting. Java does not format on save; manual formatting uses Eclipse and may differ from IntelliJ. Not every formatter supports a selection range. Review the resulting diff.

## 6. Test

| Task | Go | Java |
|---|---|---|
| File / class | `<leader>tt` through neotest | `<leader>tt` through jdtls |
| Nearest test | `<leader>tr` | `<leader>tr` |
| Output | `<leader>to`, summary `<leader>ts` | debug console `<leader>dr` |
| All / pick | `<leader>tT` runs all test files | `<leader>tT` picks a test |
| Build-tool tests | `<leader>rt`: `go test ./...` | `<leader>rt`: Maven/Gradle test |
| Debug a test | breakpoint, then `<leader>td` | breakpoint, then jdtls test mapping |

Java uses buffer-local test mappings after jdtls attaches. The Go neotest summary and debug-test mapping are not Java test integrations. See [test and debug details](../NEOVIM_GUIDES/10_TEST_DEBUG.txt) for current test limits.

## 7. Debug an HTTP request

For Go/Gin:

1. Open `internal/handler/user.go` and set `<leader>db` on an executable line in `GetUser`.
2. Start `<leader>dc` or F9 and choose **Debug app (module main package)**.
3. In another terminal, call `curl http://localhost:8088/users/1` for the demo.
4. Inspect variables. F8 steps over, F7 steps into, Shift-F8 steps out, and F9 continues.
5. Use `<leader>de` to evaluate, `<leader>dr` for the console, and `<leader>dt` to terminate.

For Java/Spring Boot, set a breakpoint in a controller and choose a **Launch ... DemoApplication** entry. The demo request is `curl 'http://localhost:8089/greeting?name=Neovim'`. Main classes are discovered when debugging starts. If discovery times out, wait for import and retry, or run `:JdtUpdateDebugConfig`.

A remote Java attach choice is configured for `127.0.0.1:5005`. Start the app with the appropriate JDWP option before attaching. Remote attach was not exercised in this migration. F-key delivery in Konsole is also untested; leader equivalents are listed in the debug guide.

## 8. Run and build

| Task | Key | Go | Maven | Gradle |
|---|---|---|---|---|
| Run | `<leader>rr` | `go run .` or first `cmd/*` main package | `spring-boot:run` | `bootRun` |
| Build | `<leader>rb` | `go build ./...` | `package -DskipTests` | `build -x test` |
| Test | `<leader>rt` | `go test ./...` | `test` | `test` |
| Custom command | `<leader>rc` | enter a command at the detected root | same | same |
| Repeat runner command | `<leader>rl` | repeats command and cwd | same | same |

The runner prefers `./mvnw` or `./gradlew` when present. Maven submodule build/test adds `-pl <module> -am`; run uses `-pl <module>` without `-am`. Gradle adds a subproject task prefix. A sibling Maven dependency may need a prior project install. Check the command before running it in a multi-module workspace.

The runner opens a bottom terminal and leaves focus in code. Move with Ctrl-w j, press `i` for terminal input, and use Ctrl-c to stop the program. Ctrl-\ then Ctrl-n returns to Normal Mode; `q` hides a Snacks terminal. A hidden program can still be running. Ctrl-/ toggles the floating terminal.

## 9. Git

| Task | Key or command |
|---|---|
| Next / previous hunk | `]h` / `[h` |
| Preview / stage / reset a hunk | `<leader>ghp` / `<leader>ghs` / `<leader>ghr` |
| Blame this line | `<leader>ghb` |
| Diff against the gitsigns base (normally index) | `<leader>ghd` |
| Git status picker | `<leader>gs`; Tab stages/unstages |
| Repository / file history | `<leader>gl` / `<leader>gf` |
| Commit through terminal | `<leader>rc`, then `git commit -m "feat: ..."` |

A hunk is a group of changed lines. Preview before resetting; reset discards its changes. Git mappings from gitsigns appear in tracked files after it attaches. `dih` deletes selected buffer text; it does not reset the hunk to Git's version.

## 10. Recover and troubleshoot

| Problem | Recovery |
|---|---|
| Wrong edit | `u`; Ctrl-r redoes it |
| Need an older state | `<leader>su` or `:earlier 10m` |
| Auto-save wrote a mistake | undo still works; inspect Git diff |
| Last copied text replaced by a delete | `"0p`; use `"_d` for future deletes |
| Wrong mode | Esc; in Terminal Mode use Ctrl-\ Ctrl-n |
| Unexpected layout | Ctrl-w = balances; Ctrl-w o keeps one window |
| Java dependencies stale | `:JdtUpdateConfig`, then inspect `:JdtShowLogs` |
| Stuck LSP | `:checkhealth vim.lsp`, then `:lsp restart` |
| Help or guide issue | `:messages`; open the index directly with `:e` |

`:q!` and `:e!` discard only unsaved changes. They cannot undo an earlier auto-save. Review each affected file before a Git restore. `:JdtWipeDataAndRestart` clears the current project's jdtls cache and forces reimport; use it after simpler checks. Full backup and rollback notes are in [README](../README.md).
