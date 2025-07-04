function! claude#acp#maybe_disable() abort
  let l:map = maparg('i', 'n')
  if l:map =~ 'feedPopup'
    try
      nnoremap <buffer> i i
      let b:acp_disabled = 1
    catch
    endtry
  endif
endfunction

