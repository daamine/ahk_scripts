#IfWinActive ahk_class CabinetWClass ; for use in explorer.
#!l::
ClipSaved := ClipboardAll
Send !d
Sleep 10
Send ^c
ControlGetText, _Path, toolbarwindow322, ahk_class CabinetWClass
StringReplace, _Path, _Path,% "Address: ",% ""
Run "wt.exe" -d `"%clipboard%`"
Clipboard := ClipSaved
ClipSaved =
return
