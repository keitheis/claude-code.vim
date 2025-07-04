function! Test_ClaudeSetup()
  call assert_true(exists('*claude#setup'))
endfunction

function! Test_ConfigMerge()
  let l:orig = claude#config#get()
  call claude#config#merge({'shell': {'separator': '&&'}})
  call assert_true(claude#config#get().shell.separator ==# '&&')
endfunction

function! Test_TerminalToggle()
  call claude#toggle()
  call assert_true(claude#terminal#is_active())
  call assert_true(claude#terminal#is_visible())
  call assert_equal(2, winnr('$'))
  let l:auto = execute('au ClaudeCodeTerminalInsert')
  call assert_true(l:auto =~# 'auto_insert')
  call claude#toggle()
  call assert_true(claude#terminal#is_active())
  call assert_false(claude#terminal#is_visible())
  call assert_equal(1, winnr('$'))
endfunction

function! Test_WindowManagement()
  call assert_true(exists('*claude#window#create_split'))
endfunction

function! Test_FileRefresh()
  call assert_true(exists('*claude#file_refresh#setup'))
endfunction

function! Test_GitIntegration()
  call assert_true(exists('*claude#git#find_root'))
endfunction

function! Test_VersionCompatibility()
  call assert_true(v:version >= 800)
endfunction

function! Test_SelectCommand()
  call assert_true(exists(':ClaudeCodeSelect'))
  call assert_true(exists('*claude#select#send'))
endfunction

