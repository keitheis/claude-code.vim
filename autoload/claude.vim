scriptencoding utf-8

let s:version = '0.2.0'

function! claude#setup(...) abort
  if a:0
    call claude#config#merge(a:1)
  endif
  call claude#commands#register()
  call claude#keymaps#register_keymaps()
  call claude#file_refresh#setup()
  call claude#terminal#setup_sync_autocmds()
endfunction

function! claude#toggle() abort
  call claude#terminal#toggle()
endfunction

function! claude#toggle_with_variant(variant) abort
  call claude#terminal#toggle_with_variant(a:variant)
endfunction

function! claude#get_version() abort
  return s:version
endfunction

" Toggle Claude Code in all windows (synchronized mode)
function! claude#toggle_all_windows() abort
  call claude#terminal#toggle_all_windows()
endfunction

" Reset to normal mode (individual window control)
function! claude#reset_sync_mode() abort
  call claude#terminal#reset_sync_mode()
endfunction

" Get current sync mode (0=normal, 1=show_in_all, 2=hide_from_all)
function! claude#get_sync_mode() abort
  return claude#terminal#get_sync_mode()
endfunction
