scriptencoding utf-8

function! claude#window#create_split() abort
  let l:config = claude#config#get().window
  let l:pos = l:config.position

  " Extend GUI columns if this is a vertical split in GUI
  if has('gui_running') && l:pos =~# '\<vertical\>'
    call claude#window#extend_gui_columns()
  endif

  " Calculate split size based on split_ratio
  let l:is_vertical = l:pos =~# '\<vertical\>'
  if l:is_vertical
    let l:size = float2nr(&columns * l:config.split_ratio)
  else
    let l:size = float2nr(&lines * l:config.split_ratio)
  endif

  if l:pos ==# 'vertical'
    execute 'vertical ' . l:size . 'new'
  elseif l:is_vertical
    execute l:pos . ' ' . l:size . 'new'
  else
    execute l:size . l:pos . ' new'
  endif
  call claude#window#setup_buffer_options(bufnr('%'))
endfunction

function! claude#window#calculate_size(val, total) abort
  if type(a:val) == type('') && a:val =~ '%$'
    return float2nr(str2float(a:val[:-2]) / 100.0 * a:total)
  endif
  return a:val
endfunction

function! claude#window#calculate_position(pos, total, size) abort
  if type(a:pos) == type('') && a:pos ==# 'center'
    return float2nr((a:total - a:size) / 2)
  endif
  return a:pos
endfunction

function! claude#window#setup_buffer_options(bufnr) abort
  let l:config = claude#config#get().window
  setlocal nobuflisted noswapfile
  if l:config.hide_numbers
    setlocal nonumber norelativenumber
  endif
  if l:config.hide_signcolumn
    setlocal signcolumn=no
  endif
endfunction

" GUI column management
let s:gui_columns_extended = 0
let s:original_columns = 0

function! claude#window#extend_gui_columns() abort
  if !has('gui_running') || s:gui_columns_extended
    return
  endif

  " Don't extend if current buffer is non-file
  if empty(expand('%')) || &buftype != ''
    return
  endif

  let l:config = claude#config#get().window
  let l:extend_amount = get(l:config, 'gui_columns_extend', 36)

  let s:original_columns = &columns
  let &columns = &columns + l:extend_amount
  let s:gui_columns_extended = 1
endfunction

function! claude#window#restore_gui_columns() abort
  if !has('gui_running') || !s:gui_columns_extended
    return
  endif

  let &columns = s:original_columns
  let s:gui_columns_extended = 0
endfunction

function! claude#window#is_gui_columns_extended() abort
  return s:gui_columns_extended
endfunction
