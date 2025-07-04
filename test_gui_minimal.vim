" Minimal GUI test for Claude Code vim plugin
runtime! autoload/claude/*.vim

echo "Testing GUI column extension functionality..."

" Test function existence
if !exists('*claude#window#extend_gui_columns')
  echo "ERROR: claude#window#extend_gui_columns missing"
  qall!
endif

if !exists('*claude#window#restore_gui_columns')
  echo "ERROR: claude#window#restore_gui_columns missing"
  qall!
endif

if !exists('*claude#window#is_gui_columns_extended')
  echo "ERROR: claude#window#is_gui_columns_extended missing"
  qall!
endif

if !exists('*claude#window#should_extend_gui_columns')
  echo "ERROR: claude#window#should_extend_gui_columns missing"
  qall!
endif

if !exists('*claude#terminal#cleanup_gui_columns')
  echo "ERROR: claude#terminal#cleanup_gui_columns missing"
  qall!
endif

if !exists('*claude#terminal#has_any_visible_windows')
  echo "ERROR: claude#terminal#has_any_visible_windows missing"
  qall!
endif

" Test single window scenario
while winnr('$') > 1
  wincmd c
endwhile

let result = claude#window#should_extend_gui_columns()
if result != 0
  echo "ERROR: should_extend_gui_columns should return 0 for single window, got " . result
  qall!
endif

" Test multiple window scenario
split
let result = claude#window#should_extend_gui_columns()
if result != 1
  echo "ERROR: should_extend_gui_columns should return 1 for multiple windows, got " . result
  qall!
endif

" Test GUI column extension state
let result = claude#window#is_gui_columns_extended()
if result != 0
  echo "ERROR: is_gui_columns_extended should return 0 initially, got " . result
  qall!
endif

" Test extension/restoration behavior
let original_columns = &columns
call claude#window#extend_gui_columns()
if claude#window#is_gui_columns_extended() && &columns <= original_columns
  echo "ERROR: GUI columns should be extended"
  qall!
endif

call claude#window#restore_gui_columns()
if claude#window#is_gui_columns_extended() || &columns != original_columns
  echo "ERROR: GUI columns should be restored"
  qall!
endif

" Test cleanup
call claude#terminal#cleanup_gui_columns()

" Clean up
while winnr('$') > 1
  wincmd c
endwhile

echo "All tests passed!"
qall