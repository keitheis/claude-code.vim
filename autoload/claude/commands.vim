scriptencoding utf-8

function! claude#commands#register() abort
  command! ClaudeCode call claude#toggle()
  command! ClaudeCodeStop call claude#terminal#stop()
  let l:variants = claude#config#get().command_variants
  for l:name in keys(l:variants)
    let l:cap = claude#core#ucfirst(l:name)
    execute 'command! ClaudeCode' . l:cap . ' call claude#toggle_with_variant("' . l:name . '")'
  endfor
  command! -range ClaudeCodeSelect call claude#select#send(<line1>, <line2>)
  command! ClaudeCodeToggleAll call claude#toggle_all_windows()
  command! ClaudeCodeResetSync call claude#reset_sync_mode()
  command! ClaudeCodeRefresh call claude#file_refresh#refresh()
endfunction
