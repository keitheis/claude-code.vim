scriptencoding utf-8

function! claude#git#find_root() abort
  let l:root = system('git rev-parse --show-toplevel 2>/dev/null')
  if v:shell_error
    return ''
  endif
  return substitute(l:root, '\n\+$', '', '')
endfunction

function! claude#git#set_workdir() abort
  let l:root = claude#git#find_root()
  if l:root !=# ''
    execute 'lcd' fnameescape(l:root)
  endif
endfunction

function! claude#git#is_git_repo() abort
  return claude#git#find_root() !=# ''
endfunction
