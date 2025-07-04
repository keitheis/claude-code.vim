" Configuration management for Claude Code plugin

let s:default_config = {
  \ 'window': {
  \   'split_ratio': 0.3,
  \   'position': 'rightbelow vertical',
  \   'enter_insert': 1,
  \   'hide_numbers': 1,
  \   'hide_signcolumn': 1,
  \   'float': {
  \     'width': '80%',
  \     'height': '80%',
  \     'row': 'center',
  \     'col': 'center',
  \     'border_chars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
  \     'title': ' Claude Code '
  \   }
  \ },
  \ 'git': {
  \   'use_git_root': 1
  \ },
  \ 'shell': {
  \   'separator': '&&',
  \   'pushd_cmd': 'pushd',
  \   'popd_cmd': 'popd'
  \ },
  \ 'command': 'claude',
  \ 'command_variants': {
  \   'continue': '--continue',
  \   'resume': '--resume',
  \   'verbose': '--verbose'
  \ },
  \ 'keymaps': {
  \   'toggle': {
  \     'normal': '<C-,>',
  \     'terminal': '<C-,>',
  \     'variants': {
  \       'continue': '<leader>cC',
  \       'verbose': '<leader>cV'
  \     }
  \   },
  \   'window_navigation': 1,
  \   'scrolling': 1
  \ }
\ }

let s:config = deepcopy(s:default_config)

function! claude#config#get()
  return s:config
endfunction

function! s:deep_merge(dict, user)
  let l:result = deepcopy(a:dict)
  for [l:key, l:val] in items(a:user)
    if type(l:val) == type({}) && has_key(l:result, l:key)
      let l:result[l:key] = s:deep_merge(l:result[l:key], l:val)
    else
      let l:result[l:key] = l:val
    endif
  endfor
  return l:result
endfunction

function! claude#config#merge(user_config)
  let s:config = s:deep_merge(s:default_config, a:user_config)
  return s:config
endfunction

function! claude#config#validate(config)
  if type(a:config) != type({})
    return 0
  endif
  return 1
endfunction

