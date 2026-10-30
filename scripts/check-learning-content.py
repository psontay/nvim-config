#!/usr/bin/env python3
"""Check the English learning scope without loading or changing plugins."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
GUIDES = ROOT / 'NEOVIM_GUIDES'
EXPECTED = ['00_INDEX', '01_SURVIVAL', '02_MOVEMENT', '03_EDITING',
            '04_SEARCH_REPLACE', '05_BUFFERS_WINDOWS', '06_FILE_NAVIGATION',
            '07_LSP_COMPLETION', '08_GO_GIN', '09_JAVA_SPRING', '10_TEST_DEBUG',
            '11_GIT', '12_TERMINAL_CLIPBOARD', '13_ADVANCED_VIM',
            '14_TROUBLESHOOTING', '15_KEYMAPS']
# Vietnamese letters, not general Unicode punctuation or a digraph example.
VIETNAMESE = re.compile('[ĂăÂâĐđÊêÔôƠơƯư\u1ea0-\u1ef9]')
errors = []

def check(condition, message):
    if not condition:
        errors.append(message)

paths = [ROOT / 'README.md', ROOT / 'docs/KEYMAPS.md', ROOT / 'docs/WORKFLOWS.md']
paths += [GUIDES / (name + '.txt') for name in EXPECTED]
paths += [GUIDES / 'MANIFEST.txt', GUIDES / 'VERIFICATION.txt']
for path in paths:
    try:
        text = path.read_bytes().decode('utf-8', errors='strict')
    except (OSError, UnicodeError) as error:
        errors.append(f'{path.relative_to(ROOT)}: {error}')
        continue
    check(bool(text.strip()), f'Empty file: {path.name}')
    check('\x00' not in text, f'NUL byte: {path.name}')
    check(not VIETNAMESE.search(text), f'Vietnamese content: {path.name}')
    if path.stem in EXPECTED:
        check(len(text.strip()) >= 500, f'Too short: {path.name}')
        for number in range(1, 12):
            check(re.search(rf'(?m)^{number}\. ', text), f'Missing section {number}: {path.name}')
    for ref in re.findall(r'\b\d\d_[A-Z_]+\.txt\b|\b(?:MANIFEST|VERIFICATION)\.txt\b', text):
        check((GUIDES / ref).is_file(), f'Broken guide reference in {path.name}: {ref}')
    if path.suffix == '.md':
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in target and not target.startswith('#'):
                check((path.parent / target.split('#')[0]).exists(), f'Broken Markdown link: {target}')

# Comments/identifiers are outside translation scope. The accent-fold table is
# invisible compatibility data and is intentionally preserved.
source_paths = [ROOT / 'lua/custom/keyhelp/data.lua', ROOT / 'lua/custom/keyhelp/init.lua',
                ROOT / 'lua/config/keymaps.lua', ROOT / 'lua/custom/runner.lua',
                ROOT / 'lua/plugins/lsp.lua', ROOT / 'lua/plugins/debug.lua', ROOT / 'lua/plugins/ui.lua']
source_paths += list((ROOT / 'scripts').glob('*.lua'))
for path in source_paths:
    text = path.read_text()
    text = re.sub(r'local FOLD = \{.*?\n\}', '', text, flags=re.S)
    for number, line in enumerate(text.splitlines(), 1):
        # No translated source string has a Lua comment marker inside it.
        visible = line.split('--', 1)[0]
        check(not VIETNAMESE.search(visible), f'Vietnamese UI string: {path.name}:{number}')

# Compile every config/script file. Lua files are loaded only as syntax here.
syntax = r'''
for _, dir in ipairs({'lua', 'scripts'}) do
  for _, path in ipairs(vim.fn.glob(dir .. '/**/*.lua', false, true)) do
    assert(loadfile(path))
  end
end
assert(loadfile('init.lua'))
local data=dofile('lua/custom/keyhelp/data.lua')
assert(#data==333, 'KeyHelp count changed')
local doc=table.concat(vim.fn.readfile('docs/KEYMAPS.md'), '\n')
local txt=table.concat(vim.fn.readfile('NEOVIM_GUIDES/15_KEYMAPS.txt'), '\n')
for _, e in ipairs(data) do
  local description=e[5]:gsub('|', '\\|')
  assert(doc:find(description,1,true), 'Markdown missing: '..e[1])
  assert(txt:find(e[5],1,true), 'Text table missing: '..e[1])
end
'''
result = subprocess.run(['nvim', '--headless', '-u', 'NONE', '-i', 'NONE', '-l', '/dev/stdin'],
                        input=syntax, text=True, capture_output=True, cwd=ROOT)
check(result.returncode == 0, 'Lua syntax/generated-content check: ' + result.stderr.strip())
for error in errors:
    print('FAIL:', error)
print(f'English content: {len(EXPECTED)} guides, 3 Markdown documents, UI/generator scope; {len(errors)} errors')
sys.exit(bool(errors))
