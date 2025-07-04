" Claude Code Vim plugin entry

if exists('g:loaded_claude_code')
  finish
endif
let g:loaded_claude_code = 1

" Compatibility checks
if v:version < 800
  echohl ErrorMsg
  echom 'Claude Code plugin requires Vim 8.0 or later'
  echohl None
  finish
endif

if !has('terminal')
  echohl WarningMsg
  echom 'Claude Code plugin: terminal feature not available, some functions may not work'
  echohl None
endif

" Setup
if exists('g:claude_code_config')
  call claude#setup(g:claude_code_config)
else
  call claude#setup({})
endif

