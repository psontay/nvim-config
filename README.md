# Neovim — A minimal Go/Gin and Java/Spring Boot IDE

This is the existing **Neovim 0.12 + LazyVim** configuration. It provides development tools while keeping a small interface and native Vim habits. The custom learning materials are in English.

In Neovim, `<leader>` means **Space**. Use `<leader>hh` to search KeyHelp, `:KeyHelp e` to explain a key, and `<leader>h1` through `<leader>h4` for learning levels.

- [KEYMAPS](docs/KEYMAPS.md): generated key reference from the same data as KeyHelp.
- [WORKFLOWS](docs/WORKFLOWS.md): daily Go and Java tasks.
- [Learning guides](NEOVIM_GUIDES/00_INDEX.txt): 16 plain-text guides; open with `<leader>hg` or `:KeyHelp guides`.
- [Verification](NEOVIM_GUIDES/VERIFICATION.txt): current checks and their limits.

Use `<leader>hd` or `:KeyHelp docs` to read the three Markdown documents inside Neovim.

## Structure

```text
init.lua                 Nerd Font flag and lazy.nvim entry point
lazyvim.json             enabled LazyVim extras
lazy-lock.json           pinned plugin commits
lua/config/
  lazy.lua               LazyVim setup, plain icons, Tutor enabled
  options.lua            autowrite, static UI, debugger environment
  keymaps.lua            restored native keys, help and runner mappings
  autocmds.lua           indentation, auto-save format guard, Java save policy
lua/plugins/
  ui.lua                 small UI, statusline, plain icons, help group labels
  editor.lua             Flash disabled to keep s/S/f/t behavior
  lsp.lua                LSP mappings, completion, digraph preservation
  go.lua                 gopls, goimports, conditional golangci-lint
  java.lua               jdtls launcher/runtime setup, Lombok, debug/test bundles
  debug.lua              function keys and Go app debug configuration
  autosave.lua           auto-save events and eligible buffers
  database.lua           Dadbod UI and SQL completion
  colorscheme.lua        built-in habamax colorscheme
lua/custom/
  keyhelp/data.lua        333 entries: keys, modes, descriptions, examples, relations
  keyhelp/init.lua        picker, details, four learning levels, docs and guide access
  runner.lua             project detection and terminal run/build/test commands
  java.lua               JDK discovery, project root, unique workspace name
  icons.lua              symbols that do not require a Nerd Font
scripts/
  check-keyhelp.lua       mapping and native help-tag checks
  check-english-help.lua  actual help windows, English search, levels, navigation
  check-native-keys.lua   real native editing, digraph, Macro, and split behavior
  check-guides.lua        guide files, references, version stamps, leader mappings
  check-learning-content.py  UTF-8, English scope, structure, generated-file checks
  gen-keymaps-doc.lua     generate docs/KEYMAPS.md
  gen-keymaps-txt.lua     generate NEOVIM_GUIDES/15_KEYMAPS.txt
```

## Tools and interface

| Feature | Configured tool | Main access |
|---|---|---|
| Plugins | lazy.nvim and LazyVim | `:Lazy`; versions in the lockfile |
| Language Servers | Neovim LSP, nvim-lspconfig, Mason; nvim-jdtls for Java | `<leader>cl` |
| Completion | blink.cmp | automatic menu; Ctrl-n/Ctrl-p; Enter accepts |
| Formatting | conform.nvim and LSP fallback | `<leader>cf` |
| Lint | gopls; nvim-lint for configured project linters | `]d`, `<leader>cd` |
| Syntax and code structure | Treesitter and textobjects | `]f`, `if`, `af` |
| Text Objects | mini.ai | `ciw`, `cia`, `vif` |
| Surround | mini.surround extra | `gsa`, `gsd`, `gsr` |
| Files, text, symbols | Snacks picker | Space twice, `<leader>/`, `<leader>sS` |
| Explorer | Snacks explorer | `<leader>e` |
| Project replacement | grug-far | `<leader>sr` |
| Diagnostics and outline | Trouble, native quickfix | `<leader>xx`, `<leader>cs`, `:copen` |
| Git | gitsigns and Snacks pickers | `]h`, `<leader>ghp`, `<leader>gs` |
| Debugging | nvim-dap, dap-ui, dap-go, java-debug | `<leader>dc`, F9/F8/F7/Shift-F8 |
| Go tests | neotest and neotest-golang | `<leader>tt`, `<leader>tr` |
| Java tests | nvim-jdtls and java-test | Java-local `<leader>tt`, `<leader>tr` |
| Terminal and runner | Snacks terminal and custom runner | Ctrl-/, `<leader>rr` |
| Help | which-key, KeyHelp, Tutor | `<leader>hh`, `<leader>ht` |
| Sessions | persistence.nvim | `<leader>qs` |
| Auto-save | auto-save.nvim | `<leader>uv` |
| SQL | Dadbod UI and completion | `<leader>D` |

Bufferline, Noice, Flash, the dashboard, smooth scrolling, and extra themes are disabled. The theme is habamax. The statusline uses simple symbols; `vim.g.nerd_font = false` is set in `init.lua`.

The configuration restores native `H`, `L`, `j`, `k`, `n`, `N`, `s`, `S`, `f`, `t`, Visual `<`/`>`, `ga`, and the `grr`/`grn`/`gra`/`gri`/`grt` family. Insert Ctrl-k enters a digraph. Insert Ctrl-s shows signature help. Normal/Visual Ctrl-s saves. Use Ctrl-w h/j/k/l to move between windows. See KEYMAPS for details.

## Go

- gopls provides completion, navigation, rename, diagnostics, and code actions. gofumpt is disabled.
- Manual `:w` or Normal/Visual Ctrl-s runs goimports when autoformat is enabled. Auto-save writes without formatting.
- golangci-lint runs only when an ancestor directory contains `.golangci.{yml,yaml,toml,json}` and the executable is available.
- The custom debug choice **Debug app (module main package)** finds `main.go` at the root or the first `cmd/*/main.go`.
- neotest handles Go file and nearest-test runs. `<leader>rt` uses `go test ./...` in a terminal.
- For a workspace or an unusual main-package layout, use `<leader>rc` with an explicit command.

## Java and Spring Boot

- jdtls runs with a discovered JDK of version 21 or later. A suitable `JAVA_HOME` is preferred; otherwise the newest suitable discovered JDK is selected. This does not change the system JDK.
- The helper discovers JDKs in `JAVA_HOME`, SDKMAN, `/usr/lib/jvm`, and `~/.jdks`. Project analysis uses the runtimes available to jdtls and the build settings. A required JDK must actually be installed.
- A multi-module root normally shares one jdtls instance. Each project path gets a unique cache workspace under `~/.cache/nvim/jdtls/<name>-<hash>/`.
- Lombok is enabled when its Mason jar exists. Source download, decompilation, Maven/Gradle import, and automatic build-configuration updates are configured.
- nvim-jdtls discovers main classes when debugging starts. Java test mappings use java-test through the debugger, separately from Go's neotest adapter.
- Java does not format on save. Use `<leader>cf` deliberately; Eclipse and IntelliJ can format differently.
- Spring bean/endpoint tool windows and large IDE refactors are not configured. Gradle execution is configured but was not exercised in this migration.

## Environment and clipboard

The checked configuration uses Neovim 0.12.5 and LazyVim 16.0.1. The user's desktop is Fedora 44, KDE Plasma, Wayland, and Konsole. Installed plugin sources and `lazy-lock.json` are the authority for mappings; verification results are recorded separately from historical reports.

Development tools include Go, an appropriate JDK, Maven or a project wrapper, Git, ripgrep, fd, a compiler, tree-sitter CLI, and the Mason-managed language/debug/format tools. Check `:Mason` for installed tools. A Gradle wrapper avoids requiring a system Gradle installation.

Interactive local sessions use `clipboard=unnamedplus` unless `SSH_CONNECTION` is set. On Wayland, clipboard sharing needs a working provider such as `wl-copy`/`wl-paste`. `"+y` and `"+p` access the system clipboard explicitly. `"0p` retrieves the last yank; `"_d` deletes without replacing saved Register contents. Headless tests do not prove desktop clipboard behavior.

Lazygit is optional and was unavailable in the checkpoint. `<leader>gg` may therefore be absent; Git pickers and the CLI still work. Nerd Font icons can be enabled after choosing a matching Konsole font by changing the existing flag in `init.lua`.

## Check and maintain the documentation

From `~/.config/nvim`:

```bash
nvim --headless -c 'luafile scripts/check-english-help.lua'
nvim --headless -c 'luafile scripts/check-native-keys.lua'
KEYHELP_FILES="/absolute/demo/main.go /absolute/demo/App.java" \
  nvim --headless -c 'luafile scripts/check-keyhelp.lua'
KEYHELP_FILES="/absolute/demo/main.go /absolute/demo/App.java" \
  nvim --headless -c 'luafile scripts/check-guides.lua'
python3 scripts/check-learning-content.py
nvim --headless -l scripts/gen-keymaps-doc.lua
```

Go/Java fixtures must be real build projects. Include a tracked Git file when checking gitsigns mappings. `KEYHELP_FILES` uses whitespace-separated paths, so use fixture paths without spaces. Without attached LSP buffers, checks can report LSP mappings as missing. See [troubleshooting](NEOVIM_GUIDES/14_TROUBLESHOOTING.txt) before treating that as a regression.

To regenerate the full text reference, use the same Go/Java files with `scripts/gen-keymaps-txt.lua`. This reads current mappings, including buffer-local ones. Keep the generator and KeyHelp data in English. Update MANIFEST and verification results only after checking the affected guides.

## Updates and rollback

Back up the configuration and `lazy-lock.json` before updating. `:Lazy sync` can update plugins; `:MasonUpdate` updates the tool registry, not every installed tool. Review Mason's UI before updating tools. After an intentional update, open Go and Java files and check LSP, completion, tests, and debugging. `:Lazy restore` restores plugin commits from the current lockfile; restore an older lockfile first if that is the intended version.

The original full backup remains at `~/nvim-backups/20261022-211315/`. Its `RESTORE.sh` checks checksums, moves current directories aside, and extracts the old archives. Review the script before running it. That backup predates the guides. The pre-English documentation/configuration archive is under `.documentation-backups/20261029-191815/`, with a checksum and selective restore notes.

## Troubleshooting

| Problem | First check |
|---|---|
| No completion or definition | `<leader>cl`, `:checkhealth vim.lsp`, `:Mason` |
| Stuck Language Server | `:messages`, then `:lsp restart` |
| Java misses changed dependencies | `:JdtUpdateConfig`; inspect `:JdtShowLogs` |
| Java launch choice missing | wait for import, retry `<leader>dc`, or `:JdtUpdateDebugConfig` |
| Format differs from the team style | `:ConformInfo`; Java manual format uses Eclipse |
| Wrong or missing key | `:KeyHelp e`, `<leader>hm`, `:verbose nmap <key>` |
| Guide picker does not open | `:messages`; `:e ~/.config/nvim/NEOVIM_GUIDES/00_INDEX.txt` |
| Startup error | `nvim --clean`, `:Lazy`, `:messages` |

Use `:JdtWipeDataAndRestart` only after simpler Java checks. It clears that project's jdtls workspace cache and requires a fresh import. Do not remove the full plugin, Mason, or cache directories as a routine fix.
