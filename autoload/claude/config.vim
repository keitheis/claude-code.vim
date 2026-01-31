scriptencoding utf-8

" Configuration management for Claude Code plugin

let s:default_config = {
  \ 'window': {
  \   'split_ratio': 0.3,
  \   'position': 'rightbelow vertical',
  \   'enter_insert': 1,
  \   'hide_numbers': 1,
  \   'hide_signcolumn': 1,
  \   'gui_columns_extend': 36,
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
  \   'enabled': 1,
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

function! claude#config#get() abort
  return s:config
endfunction

function! s:deep_merge(dict, user) abort
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

function! claude#config#merge(user_config) abort
  if !claude#config#validate(a:user_config)
    call claude#core#handle_warning('invalid config format, using defaults')
    return s:config
  endif
  let s:config = s:deep_merge(s:default_config, a:user_config)
  return s:config
endfunction

function! claude#config#validate(config) abort
  if type(a:config) != type({})
    return 0
  endif
  " Validate window config if present
  if has_key(a:config, 'window')
    if type(a:config.window) != type({})
      return 0
    endif
    if has_key(a:config.window, 'split_ratio')
      let l:ratio = a:config.window.split_ratio
      if type(l:ratio) != type(0.0) && type(l:ratio) != type(0)
        return 0
      endif
      if l:ratio <= 0 || l:ratio >= 1
        return 0
      endif
    endif
  endif
  return 1
endfunction

function! claude#config#get_default() abort
  return deepcopy(s:default_config)
endfunction
