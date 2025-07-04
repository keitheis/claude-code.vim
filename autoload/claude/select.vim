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
  if l:root != '' && l:path =~ '^' . escape(l:root, '\\')
    let l:path = substitute(l:path, '^' . escape(l:root, '\\') . '/\?', '', '')
  else
    let l:path = expand('%:.')
  endif

  let l:msg = '@' . l:path . '#' . a:start_lnum . '-' . a:end_lnum . "\n"
  call claude#terminal#send(l:msg)
endfunction

