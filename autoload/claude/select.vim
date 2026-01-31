scriptencoding utf-8

function! claude#select#send(start_lnum, end_lnum) abort
  " Ensure terminal is open
  if !claude#terminal#is_active()
    call claude#terminal#toggle()
  endif

  " Determine file path relative to git root if available
  let l:path = expand('%:p')
  let l:root = ''
  if claude#config#get().git.use_git_root
    let l:root = claude#git#find_root()
  endif
  " Use stridx for safe string matching (no regex injection)
  if l:root != '' && stridx(l:path, l:root) == 0
    " Remove git root prefix from path
    let l:path = strpart(l:path, len(l:root))
    " Remove leading slash if present
    if l:path[0] ==# '/'
      let l:path = strpart(l:path, 1)
    endif
  else
    let l:path = expand('%:.')
  endif

  let l:msg = '@' . l:path . '#' . a:start_lnum . '-' . a:end_lnum . "\n"
  call claude#terminal#send(l:msg)
endfunction
