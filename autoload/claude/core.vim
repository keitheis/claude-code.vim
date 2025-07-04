function! claude#core#handle_error(msg)
  echohl ErrorMsg
  echom 'Claude Code: ' . a:msg
  echohl None
endfunction

function! claude#core#handle_warning(msg)
  echohl WarningMsg
  echom 'Claude Code: ' . a:msg
  echohl None
endfunction

let g:claude_code_debug = get(g:, 'claude_code_debug', 0)

function! claude#core#debug_log(msg)
  if g:claude_code_debug
    echom 'Claude Code Debug: ' . a:msg
  endif
endfunction

" Utility: uppercase first character of a string
function! claude#core#ucfirst(str)
  if a:str == ''
    return ''
  endif
  return toupper(a:str[0]) . a:str[1:]
endfunction

