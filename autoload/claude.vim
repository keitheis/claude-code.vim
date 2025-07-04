let s:version = '0.1.0'

function! claude#setup(...)
  if a:0
    call claude#config#merge(a:1)
  endif
  call claude#commands#register()
  call claude#keymaps#register_keymaps()
  call claude#file_refresh#setup()
  call claude#terminal#setup_sync_autocmds()
endfunction

function! claude#toggle()
  call claude#terminal#toggle()
endfunction

function! claude#toggle_with_variant(variant)
  call claude#terminal#toggle_with_variant(a:variant)
endfunction

function! claude#get_version()
  return s:version
endfunction

" Toggle Claude Code in all windows (synchronized mode)
function! claude#toggle_all_windows()
  call claude#terminal#toggle_all_windows()
endfunction

" Reset to normal mode (individual window control)
function! claude#reset_sync_mode()
  call claude#terminal#reset_sync_mode()
endfunction

" Get current sync mode (0=normal, 1=show_in_all, 2=hide_from_all)
function! claude#get_sync_mode()
  return claude#terminal#get_sync_mode()
endfunction

