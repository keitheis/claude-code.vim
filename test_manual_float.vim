" Manual test for float window
source plugin/claude-code.vim

" Configure for float window
let g:claude_code_config = {
  \ 'window': {
  \   'position': 'float',
  \   'float': {
  \     'width': '60%',
  \     'height': '40%',
  \     'row': 'center',
  \     'col': 'center'
  \   }
  \ }
\ }

call claude#setup(g:claude_code_config)

echo "Float window configuration applied!"
echo "Use :ClaudeCode to test the float window"
echo "Configuration:"
echo "- Position: float"
echo "- Size: 60% x 40%"
echo "- Position: center"
echo "- Popup support: " . has('popupwin')