; Create a window with a default solid color background and display the message
WinGetPos,,,,TrayHeight,ahk_class Shell_TrayWnd,,,

height := A_ScreenHeight-485-TrayHeight
; Function to read and format the file
ReadAndFormatFile(filePath) {
  ; Read the file
  FileRead, contents, %filePath%

  ; Replace line breaks with `n
  contents := StrReplace(contents, "`r`n", "`n")

  ; Combine all lines into one string
  return contents
}

GetLineCount(filePath) {
    FileRead, contents, %filePath%
    lineCount := 0
    loop, parse, contents, `n
    {
        lineCount++
    }
    return lineCount
}


excelShortcuts := ReadAndFormatFile("excelShortcuts.txt")
windowsShortcuts := ReadAndFormatFile("windowsShortcuts.txt")
notepadShortcuts := ReadAndFormatFile("notepadShortcuts.txt")

intellijShortcuts := ReadAndFormatFile("intellijShortcuts.txt")
vscodeShortcuts := ReadAndFormatFile("vscodeShortcuts.txt")

excelShortcutsCount := GetLineCount("excelShortcuts.txt")
windowsShortcutsCount := GetLineCount("windowsShortcuts.txt")
notepadShortcutsCount := GetLineCount("notepadShortcuts.txt")
intellijShortcutsCount := GetLineCount("intellijShortcuts.txt")
vscodeShortcutsCount := GetLineCount("vscodeShortcuts.txt")

; MsgBox %windowsShortcutsCount%

Gui, -Caption +AlwaysOnTop +ToolWindow 
Gui, Margin, 0, 0


Gui, Add, Text, w200 h150 vInfoTxt, %windowsShortcuts%
Gui, Show, w200 h130 x2100 y800 
WinGet, winid ,, A ; <-- need to identify window A = active
; MsgBox, winid=%winid% 
WinGetTitle, Title, A
; MsgBox, The active window is "%Title%".
WinGet, active_process_name, ProcessName, ahk_id %winid%
; MsgBox, The active program is: %active_process_name%
WinSet, ExStyle, +0x20, A ; 0x20 = WS_EX_CLICKTHROUGH
prev_active_window_id := winid
WinSet, Transparent, 150, A
SetTimer, CheckActiveWindow, 2000

GuiControlGet, hwnd, Hwnd, InfoTxt
CoordMode, Mouse, Screen
MouseGetPos, x, y

options := ""
OnMessage(0x201, "WM_LBUTTONDOWN")
return

WM_LBUTTONDOWN()
{
	PostMessage, 0xA1, 2,,, A
}
return

CheckActiveWindow:
WinGet, active_window_id ,, A ; <-- need to identify window A = active
if (active_window_id != prev_active_window_id) {
    WinGet, active_process_name, ProcessName, ahk_id %active_window_id%
    prev_active_window_id := active_window_id
	WinGetTitle, active_window_title, A
    ; MsgBox, The active window has changed to: %active_window_title%
	; GuiControl,, Text, New text to be displayed
    ; GuiControl Hide, InfoTxt
	WinGet, active_process_name, ProcessName, ahk_id %active_window_id%
    
    If InStr(active_process_name, "notepad", false) {
	   GuiControl, , InfoTxt, %notepadShortcuts%
	   height := notepadShortcutsCount * (130+5) / 11
	   GuiControl, Move, InfoTxt, w266 h%height%	   
       ; Gui, Show, w266 h%height% x2000 y750 NoActivate
	   options := "w266 h" . height . " x2000 y750"
	   ; Gui, Hide
       ; GuiControl Move, InfoTxt, x300 w266
	 } else if InStr(active_process_name, "autohot", false) {
       	return
    } else if InStr(active_process_name, "excel", false) {
		GuiControl, , InfoTxt, %excelShortcuts%
		height := excelShortcutsCount * (130+5) / 11  
        ; Gui, Show, w200 h%height% x2100 y800 NoActivate
	    options := "w200 h" . height . " x2100 y800"
		; Gui, Hide
	} else if InStr(active_process_name, "idea", false) {
		GuiControl, , InfoTxt, %intellijShortcuts%
		height := intellijShortcutsCount * (130+5) / 11  
        ; Gui, Show, w200 h%height% x2100 y800 NoActivate
	    options := "w200 h" . height . " x2100 y800"
		; Gui, Hide
	} else if InStr(active_process_name, "code", false) {
		GuiControl, , InfoTxt, %vscodeShortcuts%
		height := vscodeShortcutsCount * (130+5) / 11  
        ; Gui, Show, w200 h%height% x2100 y800 NoActivate
	    options := "w200 h" . height . " x2100 y800"
		; Gui, Hide
	} else {
		GuiControl, , InfoTxt, %windowsShortcuts%
        ; Gui, Show, w200 h130 x2100 y800 NoActivate
		height := windowsShortcutsCount * (130+15) / 11  
		options := "w200 h" . height . " x2100 y800"
		; Gui, Hide
	}
}
MouseGetPos, x, y
WinGetPos, winX, winY, winW, winH, ahk_id %hwnd%
if (x >= 2450 and y >= 1350) {
    Gui, Show, %options% NoActivate
	Sleep, 5000
} else {
    Gui, Hide
}
return
