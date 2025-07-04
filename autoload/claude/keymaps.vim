function! claude#keymaps#register_keymaps()
  let l:maps = claude#config#get().keymaps
  if has_key(l:maps, 'toggle')
    execute 'nnoremap <silent> ' . l:maps.toggle.normal . ' :ClaudeCode<CR>'
    execute 'tnoremap <silent> ' . l:maps.toggle.terminal . ' <C-\\><C-n>:ClaudeCode<CR>'
    let l:vars = l:maps.toggle.variants
    for l:name in keys(l:vars)
      let l:cap = claude#core#ucfirst(l:name)
      execute 'nnoremap <silent> ' . l:vars[l:name] . ' :ClaudeCode' . l:cap . '<CR>'
    endfor
  endif
  if l:maps.window_navigation
    tnoremap <silent> <C-h> <C-\><C-n><C-w>h
    tnoremap <silent> <C-j> <C-\><C-n><C-w>j
    tnoremap <silent> <C-k> <C-\><C-n><C-w>k
    tnoremap <silent> <C-l> <C-\><C-n><C-w>l
  endif
  if l:maps.scrolling
    tnoremap <silent> <C-f> <C-\><C-n><C-f>i
    tnoremap <silent> <C-b> <C-\><C-n><C-b>i
  endif
endfunction

function! claude#keymaps#setup_terminal_navigation()
endfunction

