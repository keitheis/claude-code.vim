" Test float window with background preservation
source plugin/claude-code.vim

" Configure for float window
let g:claude_code_config = {
  \ 'window': {
  \   'position': 'float',
  \   'enter_insert': 1,
  \   'float': {
  \     'width': '60%',
  \     'height': '40%',
  \     'row': 'center',
  \     'col': 'center'
  \   }
  \ }
\ }

call claude#setup(g:claude_code_config)

" Create a test file to show in the background
edit test_background.txt
call append(0, ["This is a test file", "It should remain visible in the background", "when the Claude Code float window is open"])
normal! gg

echo "Float window test ready!"
echo "Open file test_background.txt in background"
echo "Use :ClaudeCode to test the float window"
echo "The original file should stay visible in the background"