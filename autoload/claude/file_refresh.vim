" File refresh functionality for Claude Code plugin

" Setup file refresh monitoring
function! claude#file_refresh#setup()
  augroup ClaudeFileRefresh
    autocmd!
    " Monitor when terminal window is closed
    autocmd BufWinLeave * if &buftype == 'terminal' | call s:refresh_all_files() | endif
    " Monitor when entering a window (user switches away from terminal)
    autocmd WinEnter * call s:check_and_refresh()
    " Monitor when focusing on vim
    autocmd FocusGained * call s:refresh_all_files()
  augroup END
endfunction

" Refresh all open files
function! s:refresh_all_files()
  " Get current window and buffer
  let l:current_win = winnr()
  let l:current_buf = bufnr('%')
  
  " Check all buffers for changes
  for l:buf in range(1, bufnr('$'))
    if buflisted(l:buf) && bufname(l:buf) != ''
      " Find a window that can switch buffers (not winfixbuf)
      let l:target_win = -1
      let l:target_win_buf = -1
      for l:win in range(1, winnr('$'))
        if !getwinvar(l:win, '&winfixbuf')
          let l:target_win = l:win
          let l:target_win_buf = winbufnr(l:win)
          break
        endif
      endfor
      
      if l:target_win != -1
        " Switch to target window and buffer temporarily
        execute l:target_win . 'wincmd w'
        execute 'buffer' l:buf
        checktime
        " Restore the original buffer in the target window
        execute 'buffer' l:target_win_buf
      endif
    endif
  endfor
  
  " Return to original window
  execute l:current_win . 'wincmd w'
endfunction

" Check if we're coming from a terminal and refresh if needed
function! s:check_and_refresh()
  " Only refresh if we're not in a terminal window
  if &buftype != 'terminal'
    call s:refresh_all_files()
  endif
endfunction

" Manual refresh function that can be called externally
function! claude#file_refresh#refresh()
  call s:refresh_all_files()
endfunction