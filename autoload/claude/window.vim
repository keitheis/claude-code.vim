function! claude#window#create_split()
  let l:config = claude#config#get().window
  let l:pos = l:config.position
  
  " Extend GUI columns if this is a vertical split in GUI
  if has('gui_running') && l:pos =~# '\<vertical\>'
    call claude#window#extend_gui_columns()
  endif
  
  if l:pos ==# 'vertical'
    vertical new
  elseif l:pos =~# '\<vertical\>'
    execute l:pos . ' new'
  else
    execute l:pos . ' new'
  endif
  call claude#window#setup_buffer_options(bufnr('%'))
endfunction

function! claude#window#calculate_size(val, total)
  if type(a:val) == type('') && a:val =~ '%$'
    return float2nr(str2float(a:val[:-2]) / 100.0 * a:total)
  endif
  return a:val
endfunction

function! claude#window#calculate_position(pos, total, size)
  if type(a:pos) == type('') && a:pos ==# 'center'
    return float2nr((a:total - a:size) / 2)
  endif
  return a:pos
endfunction

function! claude#window#setup_buffer_options(bufnr)
  setlocal nobuflisted noswapfile
  setlocal nonumber norelativenumber
  setlocal signcolumn=no
endfunction

" GUI column management
let s:gui_columns_extended = 0
let s:original_columns = 0

function! claude#window#extend_gui_columns()
  if !has('gui_running') || s:gui_columns_extended
    return
  endif
  
  " Don't extend if current buffer is non-file
  if empty(expand('%')) || &buftype != ''
    return
  endif
  
  let s:original_columns = &columns
  let &columns = &columns + 36
  let s:gui_columns_extended = 1
endfunction

function! claude#window#restore_gui_columns()
  if !has('gui_running') || !s:gui_columns_extended
    return
  endif
  
  let &columns = s:original_columns
  let s:gui_columns_extended = 0
endfunction

function! claude#window#is_gui_columns_extended()
  return s:gui_columns_extended
endfunction

