source plugin/claude-code.vim
source test/test_claude.vim
call Test_ClaudeSetup()
call Test_ConfigMerge()
call Test_TerminalToggle()
call Test_WindowManagement()
call Test_FileRefresh()
call Test_GitIntegration()
call Test_VersionCompatibility()
call Test_SelectCommand()
qall
