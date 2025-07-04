let s:terminal_bufnr = -1
let s:terminal_job = -1
let s:sync_mode = 0  " 0=normal, 1=show_in_all, 2=hide_from_all
let s:float_winid = -1

" Enter terminal-job mode if the user focuses the terminal again
function! s:auto_insert() abort
  if &buftype ==# 'terminal' && mode() !=# 't'
    " The Vim terminal sometimes ignores startinsert; feed "i<BS>" instead
    call feedkeys("i", 'n')
  endif
endfunction

" Setup autocommands to keep the terminal in insert mode
function! s:setup_auto_insert() abort
  augroup ClaudeCodeTerminalInsert
    autocmd! * <buffer>
    autocmd BufEnter <buffer> call <SID>auto_insert()
  augroup END
endfunction

" Setup auto-insert for popup windows
function! s:setup_popup_auto_insert(bufnr) abort
  augroup ClaudeCodeTerminalInsert
    execute 'autocmd! * <buffer=' . a:bufnr . '>'
    execute 'autocmd BufEnter <buffer=' . a:bufnr . '> call <SID>auto_insert()'
  augroup END
endfunction

function! s:open_terminal(cmd)
  if has('nvim')
    " This plugin targets Vim, but just in case
    return termopen(a:cmd)
  endif
  if exists('*term_start')
    let l:buf = term_start(a:cmd, {'term_name': 'claude-code', 'curwin': 1})
    let s:terminal_bufnr = l:buf
    " Set up autocmd to restore GUI columns when terminal buffer is deleted
    call s:setup_terminal_cleanup()
    return l:buf
  else
    return -1
  endif
endfunction

" Setup cleanup for when terminal is closed or deleted
function! s:setup_terminal_cleanup()
  augroup ClaudeCodeTerminalCleanup
    autocmd! * <buffer>
    autocmd BufUnload <buffer> call claude#terminal#cleanup_gui_columns()
  augroup END
endfunction

function! s:open_terminal_hidden(cmd)
  if has('nvim')
    " This plugin targets Vim, but just in case
    return termopen(a:cmd)
  endif
  if exists('*term_start')
    let l:buf = term_start(a:cmd, {'term_name': 'claude-code', 'hidden': 1})
    let s:terminal_bufnr = l:buf
    return l:buf
  else
    return -1
  endif
endfunction

" Cleanup function to restore GUI columns when terminal is closed
function! claude#terminal#cleanup_gui_columns()
  if claude#window#is_gui_columns_extended()
    call claude#window#restore_gui_columns()
  endif
endfunction

function! claude#terminal#toggle()
  return claude#terminal#toggle_with_variant('')
endfunction

function! claude#terminal#toggle_with_variant(variant_name)
  let l:config = claude#config#get()

  " Determine command for new terminal when needed
  let l:cmd = l:config.command
  if a:variant_name != '' && has_key(l:config.command_variants, a:variant_name)
    let l:cmd .= ' ' . l:config.command_variants[a:variant_name]
  endif

  " Check if we're in sync mode and handle accordingly
  if s:sync_mode == 1
    " show_in_all mode - toggle all windows
    call claude#terminal#toggle_all_windows()
    return
  elseif s:sync_mode == 2
    " hide_from_all mode - toggle all windows  
    call claude#terminal#toggle_all_windows()
    return
  endif

  " Check if we should use float window
  if l:config.window.position ==# 'float' && has('popupwin')
    call claude#terminal#toggle_float(l:cmd)
    return
  endif

  " Normal mode - single window toggle
  " If the terminal window is visible, just close that window
  if claude#terminal#is_visible()
    let l:claude_winnr = bufwinnr(s:terminal_bufnr)
    " Only close if it's not the last window
    if winnr('$') > 1
      execute l:claude_winnr . 'wincmd c'
      " Restore GUI columns if no Claude Code windows remain and GUI was extended
      if !claude#terminal#has_any_visible_windows() && claude#window#is_gui_columns_extended()
        call claude#window#restore_gui_columns()
      endif
    endif
    return
  endif

  " If the terminal job already exists, reopen the buffer
  if claude#terminal#is_active()
    call claude#window#create_split()
    execute 'buffer' s:terminal_bufnr
  else
    call claude#window#create_split()
    let s:terminal_bufnr = s:open_terminal(l:cmd)
  endif

  " Disable AutoComplPop mappings in this buffer if present
  call claude#acp#maybe_disable()
  if l:config.window.enter_insert
    call s:setup_auto_insert()
    startinsert
  endif
endfunction

function! claude#terminal#toggle_float(cmd)
  let l:config = claude#config#get()
  
  " If float window is visible, close it
  if claude#terminal#is_float_visible()
    call popup_close(s:float_winid)
    let s:float_winid = -1
    return
  endif

  " If terminal buffer exists, reuse it in float window
  if claude#terminal#is_active()
    let s:float_winid = claude#terminal#create_float_with_buffer(s:terminal_bufnr)
  else
    " Create new terminal in float window
    let s:float_winid = claude#terminal#create_float_with_command(a:cmd)
  endif

  " Setup auto-insert if configured
  if l:config.window.enter_insert
    call s:setup_auto_insert()
    " Focus the popup window and enter insert mode
    call win_gotoid(s:float_winid)
    startinsert
  endif
endfunction

function! claude#terminal#create_float_with_buffer(bufnr)
  let l:cfg = claude#config#get().window.float
  let l:width = claude#window#calculate_size(l:cfg.width, &columns)
  let l:height = claude#window#calculate_size(l:cfg.height, &lines)
  
  " Calculate position
  let l:row = claude#window#calculate_position(l:cfg.row, &lines, l:height)
  let l:col = claude#window#calculate_position(l:cfg.col, &columns, l:width)
  
  " Create popup window with existing terminal buffer
  let l:winid = popup_create(a:bufnr, {
        \ 'minwidth': l:width,
        \ 'minheight': l:height,
        \ 'maxwidth': l:width,
        \ 'maxheight': l:height,
        \ 'border': [],
        \ 'borderchars': l:cfg.border_chars,
        \ 'line': l:row,
        \ 'col': l:col,
        \ 'pos': 'topleft',
        \ 'wrap': 0,
        \ 'scrollbar': 0,
        \ 'title': l:cfg.title,
        \ 'close': 'button',
        \ 'callback': 'claude#terminal#float_closed'
        \ })
  
  call s:setup_popup_auto_insert(a:bufnr)
  return l:winid
endfunction

function! claude#terminal#create_float_with_command(cmd)
  let l:cfg = claude#config#get().window.float
  let l:width = claude#window#calculate_size(l:cfg.width, &columns)
  let l:height = claude#window#calculate_size(l:cfg.height, &lines)
  
  " Calculate position
  let l:row = claude#window#calculate_position(l:cfg.row, &lines, l:height)
  let l:col = claude#window#calculate_position(l:cfg.col, &columns, l:width)
  
  " Create the terminal hidden first (so it doesn't disturb current window)
  let s:terminal_bufnr = s:open_terminal_hidden(a:cmd)
  
  " Create popup window with the terminal buffer
  let l:winid = popup_create(s:terminal_bufnr, {
        \ 'minwidth': l:width,
        \ 'minheight': l:height,
        \ 'maxwidth': l:width,
        \ 'maxheight': l:height,
        \ 'border': [],
        \ 'borderchars': l:cfg.border_chars,
        \ 'line': l:row,
        \ 'col': l:col,
        \ 'pos': 'topleft',
        \ 'wrap': 0,
        \ 'scrollbar': 0,
        \ 'title': l:cfg.title,
        \ 'close': 'button',
        \ 'callback': 'claude#terminal#float_closed'
        \ })
  
  call claude#window#setup_buffer_options(s:terminal_bufnr)
  call claude#acp#maybe_disable()
  call s:setup_popup_auto_insert(s:terminal_bufnr)
  
  return l:winid
endfunction

function! claude#terminal#float_closed(winid, result)
  " Handle float window closure
  let s:float_winid = -1
  call claude#terminal#cleanup_gui_columns()
endfunction

function! claude#terminal#is_float_visible()
  return s:float_winid != -1 && popup_getoptions(s:float_winid) != {}
endfunction

function! claude#terminal#is_visible()
  return claude#terminal#is_active() && (bufwinnr(s:terminal_bufnr) != -1 || claude#terminal#is_float_visible())
endfunction

function! claude#terminal#is_active()
  return bufexists(s:terminal_bufnr)
endfunction

function! claude#terminal#get_bufnr()
  return s:terminal_bufnr
endfunction


function! claude#terminal#send(text) abort
  if !claude#terminal#is_active()
    return
  endif
  if exists('*term_sendkeys')
    " Vim has a helper to send text directly to the terminal buffer
    call term_sendkeys(s:terminal_bufnr, a:text)
    return
  endif

  " Fallback: get the terminal job and use chansend()
  let l:job = term_getjob(s:terminal_bufnr)
  if type(l:job) == type(0) && l:job == 0
    return
  endif
  call chansend(l:job, a:text)
endfunction

" Toggle Claude Code buffer in all windows
function! claude#terminal#toggle_all_windows()
  let l:config = claude#config#get()
  let l:current_win = winnr()
  let l:is_any_visible = 0
  
  " Check if Claude Code is visible in any window
  for l:win in range(1, winnr('$'))
    if winbufnr(l:win) == s:terminal_bufnr
      let l:is_any_visible = 1
      break
    endif
  endfor
  
  if l:is_any_visible
    " Hide from all windows
    call claude#terminal#hide_from_all_windows()
    let s:sync_mode = 2
  else
    " Show in all windows (or create if doesn't exist)
    call claude#terminal#show_in_all_windows()
    let s:sync_mode = 1
  endif
  
  " Return to original window
  execute l:current_win . 'wincmd w'
endfunction

" Show Claude Code buffer in all windows
function! claude#terminal#show_in_all_windows()
  let l:config = claude#config#get()
  let l:current_win = winnr()
  
  " Create terminal if it doesn't exist
  if !claude#terminal#is_active()
    let l:cmd = l:config.command
    let l:original_win = winnr()
    
    " For float windows, create terminal hidden; for split windows, create normally
    if l:config.window.position ==# 'float' && has('popupwin')
      let s:terminal_bufnr = s:open_terminal_hidden(l:cmd)
    else
      call claude#window#create_split()
      let s:terminal_bufnr = s:open_terminal(l:cmd)
    endif
    
    call claude#acp#maybe_disable()
    if l:config.window.enter_insert
      call s:setup_auto_insert()
    endif
    execute l:original_win . 'wincmd w'
  endif
  
  " Add Claude Code to all windows that don't have it
  for l:win in range(1, winnr('$'))
    if winbufnr(l:win) != s:terminal_bufnr
      execute l:win . 'wincmd w'
      call claude#window#create_split()
      execute 'buffer' s:terminal_bufnr
      call claude#acp#maybe_disable()
    endif
  endfor
  
  execute l:current_win . 'wincmd w'
endfunction

" Hide Claude Code buffer from all windows
function! claude#terminal#hide_from_all_windows()
  let l:current_win = winnr()
  let l:windows_to_close = []
  
  " Collect all windows showing Claude Code buffer
  for l:win in range(1, winnr('$'))
    if winbufnr(l:win) == s:terminal_bufnr
      call add(l:windows_to_close, l:win)
    endif
  endfor
  
  " Close windows in reverse order to maintain window numbers
  " Only close if there are other windows available
  if winnr('$') > len(l:windows_to_close)
    for l:win in reverse(l:windows_to_close)
      execute l:win . 'wincmd c'
    endfor
  endif
  
  " Restore GUI columns if no Claude Code windows remain and GUI was extended
  if !claude#terminal#has_any_visible_windows() && claude#window#is_gui_columns_extended()
    call claude#window#restore_gui_columns()
  endif
endfunction

" Setup autocmds for window synchronization
function! claude#terminal#setup_sync_autocmds()
  augroup ClaudeCodeWindowSync
    autocmd!
    autocmd WinEnter * call claude#terminal#maintain_sync()
    autocmd TabEnter * call claude#terminal#maintain_sync()
  augroup END
endfunction

" Maintain synchronization when switching windows/tabs
function! claude#terminal#maintain_sync()
  if s:sync_mode == 0
    return
  endif
  
  let l:has_claude_in_current_tab = 0
  for l:win in range(1, winnr('$'))
    if winbufnr(l:win) == s:terminal_bufnr
      let l:has_claude_in_current_tab = 1
      break
    endif
  endfor
  
  if s:sync_mode == 1 && !l:has_claude_in_current_tab
    " Should show in all windows but missing in current tab
    call claude#terminal#show_in_all_windows()
  elseif s:sync_mode == 2 && l:has_claude_in_current_tab
    " Should hide from all windows but present in current tab
    call claude#terminal#hide_from_all_windows()
  endif
endfunction

" Reset sync mode to normal
function! claude#terminal#reset_sync_mode()
  let s:sync_mode = 0
endfunction

" Get current sync mode
function! claude#terminal#get_sync_mode()
  return s:sync_mode
endfunction

" Check if any Claude Code windows are visible across all tabs
function! claude#terminal#has_any_visible_windows()
  if !claude#terminal#is_active()
    return 0
  endif
  
  let l:current_tab = tabpagenr()
  for l:tab in range(1, tabpagenr('$'))
    execute 'tabnext' l:tab
    for l:win in range(1, winnr('$'))
      if winbufnr(l:win) == s:terminal_bufnr
        execute 'tabnext' l:current_tab
        return 1
      endif
    endfor
  endfor
  execute 'tabnext' l:current_tab
  return 0
endfunction

