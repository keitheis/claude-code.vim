" Test float window functionality
let g:claude_code_debug = 1

" Source the plugin
source plugin/claude-code.vim

" Test basic float window configuration
function! TestFloatConfig()
  let config = {
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
  
  call claude#setup(config)
  let merged = claude#config#get()
  
  echo "Float config test:"
  echo "Position: " . merged.window.position
  echo "Float width: " . merged.window.float.width
  echo "Float height: " . merged.window.float.height
  echo "Border chars: " . string(merged.window.float.border_chars)
  echo "Title: " . merged.window.float.title
  echo ""
endfunction

" Test float window functions
function! TestFloatFunctions()
  echo "Testing float window functions:"
  
  " Test size calculation
  let width = claude#window#calculate_size('80%', 100)
  echo "Width calculation (80% of 100): " . width
  
  let height = claude#window#calculate_size(50, 100)
  echo "Height calculation (50 absolute): " . height
  
  " Test position calculation
  let row = claude#window#calculate_position('center', 100, 20)
  echo "Row calculation (center of 100, size 20): " . row
  
  let col = claude#window#calculate_position(10, 100, 20)
  echo "Col calculation (10 absolute): " . col
  
  echo ""
endfunction

" Test popup window availability
function! TestPopupAvailability()
  echo "Testing popup window availability:"
  echo "has('popupwin'): " . has('popupwin')
  echo "has('popup'): " . has('popup')
  echo "Vim version: " . v:version
  echo ""
endfunction

" Run all tests
call TestFloatConfig()
call TestFloatFunctions()
call TestPopupAvailability()

echo "Float window tests completed!"