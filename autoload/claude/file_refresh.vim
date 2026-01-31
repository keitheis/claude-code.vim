scriptencoding utf-8

" File refresh functionality for Claude Code plugin

" Setup file refresh monitoring
function! claude#file_refresh#setup() abort
  augroup ClaudeFileRefresh
    autocmd!
    " Monitor when Claude terminal window is closed
    autocmd BufWinLeave * call s:on_buf_win_leave()
    " Monitor when entering a window (user switches away from terminal)
    autocmd WinEnter * call s:check_and_refresh()
    " Monitor when focusing on vim
    autocmd FocusGained * call s:refresh_all_files()
  augroup END
endfunction

" Only refresh if leaving the Claude terminal buffer
function! s:on_buf_win_leave() abort
  if &buftype ==# 'terminal' && bufnr('%') == claude#terminal#get_bufnr()
    call s:refresh_all_files()
  endif
endfunction

" Refresh all open files without switching windows
function! s:refresh_all_files() abort
  " Use checktime to check all buffers at once (Vim 8.0+)
  " This is more efficient and doesn't cause visual flicker
  if exists(':checktime')
    silent! checktime
  endif
endfunction

" Check if we're coming from a terminal and refresh if needed
function! s:check_and_refresh() abort
  " Only refresh if we're not in a terminal window
  if &buftype !=# 'terminal'
    call s:refresh_all_files()
  endif
endfunction

" Manual refresh function that can be called externally
function! claude#file_refresh#refresh() abort
  call s:refresh_all_files()
endfunction
