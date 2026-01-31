scriptencoding utf-8

function! claude#keymaps#register_keymaps() abort
  let l:maps = claude#config#get().keymaps

  " Check if keymaps are globally disabled
  if !get(l:maps, 'enabled', 1)
    return
  endif

  if has_key(l:maps, 'toggle')
    execute 'nnoremap <silent> ' . l:maps.toggle.normal . ' :ClaudeCode<CR>'
    execute 'tnoremap <silent> ' . l:maps.toggle.terminal . ' <C-\><C-n>:ClaudeCode<CR>'
    let l:vars = l:maps.toggle.variants
    for l:name in keys(l:vars)
      let l:cap = claude#core#ucfirst(l:name)
      execute 'nnoremap <silent> ' . l:vars[l:name] . ' :ClaudeCode' . l:cap . '<CR>'
    endfor
  endif
endfunction

" Setup buffer-local terminal navigation keymaps
" Called when entering the Claude terminal buffer
function! claude#keymaps#setup_terminal_buffer() abort
  let l:maps = claude#config#get().keymaps

  if !get(l:maps, 'enabled', 1)
    return
  endif

  if l:maps.window_navigation
    tnoremap <buffer> <silent> <C-h> <C-\><C-n><C-w>h
    tnoremap <buffer> <silent> <C-j> <C-\><C-n><C-w>j
    tnoremap <buffer> <silent> <C-k> <C-\><C-n><C-w>k
    tnoremap <buffer> <silent> <C-l> <C-\><C-n><C-w>l
  endif

  if l:maps.scrolling
    tnoremap <buffer> <silent> <C-f> <C-\><C-n><C-f>i
    tnoremap <buffer> <silent> <C-b> <C-\><C-n><C-b>i
  endif
endfunction
