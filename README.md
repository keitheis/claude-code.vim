# Claude Code Vim Plugin

This plugin integrates the [Claude Code](https://claude.com/product/claude-code) CLI with Vim and MacVim.

## Features
- Run Claude Code inside a Vim terminal window
- Auto reload files changed by Claude
- Git project detection
- Configurable key mappings and commands

## Installation

### vim-plug
```vim
Plug 'keitheis/claude-code.vim'
```

### Vundle
```vim
Plugin 'keitheis/claude-code.vim'
```

### Manual
Clone the repository into your `~/.vim` or `~/.vim/pack` directory.

## Configuration Example
```vim
let g:claude_code_config = {
  \ 'window': {'position': 'botright'},
  \ }
```
`enter_insert` under the `window` section controls whether the terminal
automatically enters insert mode whenever you switch to it. It defaults
to `1`. When enabled, the plugin feeds an `i<BS>` sequence on focus so
the terminal always re-enters job mode.

## Usage
- `:ClaudeCode` toggle the terminal
- `:'<,'>ClaudeCodeSelect` send selected lines to Claude
- `<C-,>` default mapping

## Troubleshooting
Ensure Vim 8.0+ with `+terminal` feature is available.
If you use the AutoComplPop plugin and see text like `=feedPopup()`
inserted when switching back to the Claude terminal, this plugin now
disables that mapping for the terminal buffer automatically.

## Compatibility
Vim 8.0 or newer is required. Floating windows need Vim 8.2+
