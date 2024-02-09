#NoEnv
SetBatchLines, -1

DefaultCommandsFile := A_ScriptDir . "\Commands.txt"

; Commands file for MobaXterm
MobaXtermCommandsFile := A_ScriptDir . "\OtherCommands.txt"
LinuxCommandsFile := A_ScriptDir . "\LinuxCommands.txt"

CurrentCommand := ""
OffsetX := 0 ;offset in caret position in X axis
OffsetY := 20 ;offset from caret position in Y axis
BoxHeight := 165 ;height of the suggestions box in pixels
ShowLength := 4 ;minimum length of word before showing suggestions
MaxResults := 20 ;maximum number of results to display

NormalKeyList := "a`nb`nc`nd`ne`nf`ng`nh`ni`nj`nk`nl`nm`nn`no`np`nq`nr`ns`nt`nu`nv`nw`nx`ny`nz" ;list of key names separated by `n that make up words in upper and lower case variants
NumberKeyList := "1`n2`n3`n4`n5`n6`n7`n8`n9`n0" ;list of key names separated by `n that make up words as well as their numpad equivalents
OtherKeyList := "'`n-`nSpace" ;list of key names separated by `n that make up words
ResetKeyList := "Esc`nHome`nEnter`nPGUP`nPGDN`nEnd`nLeft`nRight`nRButton`nMButton`n,`n.`n/`n[`n]`n;`n\`n=`n```n"""  ;list of key names separated by `n that cause suggestions to reset
TriggerKeyList := "Tab`nEnter" ;list of key names separated by `n that trigger completion

Gui, CommandAutocomplete:Default
Gui, Font, s10, Courier New
Gui, +Delimiter`n
Gui, Add, ListBox, x0 y0 h%BoxHeight%  0x100 vMatched gCompleteCommand AltSubmit
Gui, -Caption +ToolWindow +AlwaysOnTop +LastFound
;Gui, Show, h100 Hide, AutoComplete

CoordMode, Caret
SetKeyDelay, 0
SendMode, Input

;obtain desktop size across all monitors
SysGet, ScreenWidth, 78
SysGet, ScreenHeight, 79


hWindow := WinExist()
Gui, Show, h%BoxHeight% Hide, AutoComplete

Gosub, ResetCommand

SetHotkeys(NormalKeyList,NumberKeyList,OtherKeyList,ResetKeyList,TriggerKeyList)

#IfWinExist AutoComplete ahk_class AutoHotkeyGUI

~LButton::
MouseGetPos,,, Temp1
If (Temp1 != hWindow)
    Gosub, ResetCommand
Return

Up::
Gui, CommandAutocomplete:Default
GuiControlGet, Temp1,, Matched
If Temp1 > 1 ;ensure value is in range
    GuiControl, Choose, Matched, % Temp1 - 1
Return

Down::
Gui, CommandAutocomplete:Default
GuiControlGet, Temp1,, Matched
GuiControl, Choose, Matched, % Temp1 + 1
Return

!1::
!2::
!3::
!4::
!5::
!6::
!7::
!8::
!9::
!0::
Gui, CommandAutocomplete:Default
KeyWait, Alt
Key := SubStr(A_ThisHotkey, 2, 1)
GuiControl, Choose, Matched, % Key = 0 ? 10 : Key
Gosub, CompleteCommand
Return


#IfWinExist

~BackSpace::
CurrentCommand := SubStr(CurrentCommand,1,-1)
Gosub, SuggestCommand
Return

Key:
CurrentChar := SubStr(A_ThisHotkey, 2)
CurrentCommand .= (CurrentChar = "Space") ? " " : CurrentChar
;MsgBox CurrentCommand , %CurrentCommand%
Gosub, SuggestCommand
Return

ShiftedKey:
Char := SubStr(A_ThisHotkey,3)
StringUpper, Char, Char
CurrentCommand .= Char
Gosub, SuggestCommand
Return

NumpadKey:
CurrentCommand .= SubStr(A_ThisHotkey,8)
Gosub, SuggestCommand
Return

;$Tab::
;    Sleep, 100 ; Give it some time to activate/focus
;    If (SubStr(clipboard, 0) = " ") ; check if space at the end of clipboard, if so remove it
;        StringTrimRight, clipboard, clipboard, 1
;    CurrentCommand = %clipboard%
;    Gosub, SuggestCommand 
;    Return


ResetCommand:
CurrentCommand := ""
Gui, CommandAutocomplete:Hide
Return

SuggestCommand:

    if !WinActive("ahk_exe MobaXterm.exe") and !WinActive("ahk_class Notepad++") and !WinActive("ahk_exe chrome.exe") and !WinActive("ahk_exe msedge.exe") and !WinActive("ahk_exe brave.exe")  and !WinActive("ahk_exe WindowsTerminal.exe") and !WinActive("ahk_exe acwebhelper.exe") and !WinActive("ahk_exe zoom.exe"){
	   Return
	}
	Commands := ""
	CommandsFile := DefaultCommandsFile
    FileRead, Commands, %CommandsFile%
	
	If WinActive("ahk_exe MobaXterm.exe") or WinActive("ahk_exe WindowsTerminal.exe") {
		CommandsFile := LinuxCommandsFile
		; Read commands from the appropriate file
		FileRead, Commands2, %CommandsFile%
		Commands .= "`n" . Commands2
    }
	If WinActive("ahk_exe MobaXterm.exe") {
        CommandsFile := MobaXtermCommandsFile
        ; Read commands from the appropriate file
		FileRead, Commands3, %CommandsFile%
		Commands .= "`n" . Commands3
	}

    PrepareCommandList(Commands)

    ;Gui, CommandAutocomplete:Hide
    Gui,  CommandAutocomplete:Default
    ;GuiControl, Choose, Matched, 0 
    If StrLen(CurrentCommand) < 3
    {
        Return
    }

    ; Clear the ListBox content
	;Gui, Submit, NoHide
	GuiControl, , Matched,`n

    ;GuiControl, -Redraw, Matched
	;GuiControl,, Matched, % b list := Trim(StrReplace(b list b, b remove b, b), b)
    ;LV_Delete()
	;Control, Delete, 1, CommandAutocomplete, Select System

    ;ColCount := LV_GetCount("Column")
    ;Loop, %ColCount%
    ;    LV_DeleteCol(1)

    ;GoSub DebugPrintListBox
    MatchList := Suggest(CurrentCommand, Commands)

	;check for a lack of matches
	If (MatchList = "")
	{
		Gui, Hide
		Return
	}

	;limit the number of results
    Position := InStr(MatchList,"`n",True,1,MaxResults)
    If Position
        MatchList := SubStr(MatchList,1,Position - 1)

    MaxWidth := 0
    DisplayList := ""
    Loop, Parse, MatchList, `n
    {
        Entry := (A_Index < MaxResults ? A_Index . ". " : "   ") . A_LoopField
		Width := TextWidth(Entry)
		Entry := Trim(Entry," `t`r`n")
        If (Width > MaxWidth)
            MaxWidth := Width
        DisplayList .= Entry . "`n"
    }
    MaxWidth += 30 ;add room for the scrollbar

    DisplayList := SubStr(DisplayList, 1, -1)
	;GuiControl, +Redraw, Matched

    GuiControl,, Matched, % DisplayList ; Update the ListBox with new suggestions
    GuiControl, Choose, Matched, 1
    GuiControl, Move, Matched, w%MaxWidth%
    ;PosX := A_CaretX + OffsetX
	;PosY := A_CaretY + OffsetY
	hwnd := GetCaret(PosX, PosY, w, h)

    If PosX + MaxWidth > ScreenWidth ;past right side of the screen
        PosX := ScreenWidth - MaxWidth
    ;Sleep, 100 ;
    If PosY + BoxHeight > ScreenHeight ;past bottom of the screen
       PosY := ScreenHeight - BoxHeight
    
	;MsgBox A_CaretX, %A_CaretX%, A_CaretY, %A_CaretY%, MaxWidth , %MaxWidth%

	if (!PosX) {
		; Set a default value if A_CaretX is not defined
		PosX := 700
		PosY := 800
	}


	Gui, Show, x%PosX% y%PosY% w%MaxWidth% NoActivate ;show window
	;Sleep, 100 ;
	;MsgBox DisplayList , %DisplayList%
	;GoSub DebugPrintListBox
    Return

CompleteCommand:
    Gui, CommandAutocomplete:Default
    Gui, Hide

    GuiControlGet, Index,, Matched
    If Index
    {
        TempList := "`n" . MatchList . "`n"
        Position := InStr(TempList,"`n",0,1,Index) + 1
        SelectedCommand := SubStr(TempList, Position, InStr(TempList, "`n", 0, Position) - Position)
		StringReplace,SelectedCommand,SelectedCommand,`n,,All
        StringReplace,SelectedCommand,SelectedCommand,`r,,All
	    ;MsgBox CompleteCommand , %SelectedCommand%
        SendWord(CurrentCommand,SelectedCommand,CorrectCase)
    }
	Gosub, ResetCommand
    Return

PrepareCommandList(ByRef Commands)
{
    Sort, Commands
    Loop, Parse, Commands, `n
        LV_Add("", A_LoopField)
}

GuiEscape:
GuiClose:
    Gui, CommandAutocomplete:Default
    Gui, Submit
    Gui, Destroy
    Return

Suggest(CurrentCommand, ByRef Commands)
{
    Local Pattern, Command
    Pattern := "^" . CurrentCommand . ".*"
    Local MatchList := ""
    Loop, Parse, Commands, `n
    {
        Command := A_LoopField
		Command := Trim(Command," `t`r`n")
        If RegExMatch(Command, Pattern)
        {
            MatchList .= Command . "`n"
        }
    }

    MatchList := SubStr(MatchList, 1, -1)

    Return, MatchList
}

DebugPrintListBox:
    GuiControlGet, Temp1,, Matched

    Count := LV_GetCount()
	;MsgBox , % "ListBox size:`n" Temp1
	ListBoxContent := ""
    Loop, %Count%
    {
        ListBoxContent .= "Entry " A_Index ": " LV_GetText(A_Index, 1) "`n"
    }
    ;MsgBox, % "ListBox Contents:`n" ListBoxContent
    Return

SendWord(CurrentWord,NewWord,CorrectCase = False)
{
    If CorrectCase
    {
        Position := 1
        CaseSense := A_StringCaseSense
        StringCaseSense, Locale
        Loop, Parse, CurrentWord
        {
            Position := InStr(NewWord,A_LoopField,False,Position) ;find next character in the current word if only subsequence matched
            If A_LoopField Is Upper
            {
                Char := SubStr(NewWord,Position,1)
                StringUpper, Char, Char
                NewWord := SubStr(NewWord,1,Position - 1) . Char . SubStr(NewWord,Position + 1)
            }
        }
        StringCaseSense, %CaseSense%
    }

    ;send the word
    Send, % "{BS " . StrLen(CurrentWord) . "}" ;clear the typed word
    SendRaw, %NewWord%
}

TextWidth(String)
{
    static Typeface := "Courier New"
    static Size := 10
    static hDC, hFont := 0, Extent
    If !hFont
    {
        hDC := DllCall("GetDC","UPtr",0,"UPtr")
        Height := -DllCall("MulDiv","Int",Size,"Int",DllCall("GetDeviceCaps","UPtr",hDC,"Int",90),"Int",72)
        hFont := DllCall("CreateFont","Int",Height,"Int",0,"Int",0,"Int",0,"Int",400,"UInt",False,"UInt",False,"UInt",False,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"Str",Typeface)
        hOriginalFont := DllCall("SelectObject","UPtr",hDC,"UPtr",hFont,"UPtr")
        VarSetCapacity(Extent,8)
    }
    DllCall("GetTextExtentPoint32","UPtr",hDC,"Str",String,"Int",StrLen(String),"UPtr",&Extent)
    Return, NumGet(Extent,0,"UInt")
}


GetCaret(ByRef X:="", ByRef Y:="", ByRef W:="", ByRef H:="") {

    ; UIA caret
    static IUIA := ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
    ; GetFocusedElement
    DllCall(NumGet(NumGet(IUIA+0)+8*A_PtrSize), "ptr", IUIA, "ptr*", FocusedEl:=0)
    ; GetCurrentPattern. TextPatternElement2 = 10024
    DllCall(NumGet(NumGet(FocusedEl+0)+16*A_PtrSize), "ptr", FocusedEl, "int", 10024, "ptr*", patternObject:=0), ObjRelease(FocusedEl)
    if patternObject {
        ; GetCaretRange
        DllCall(NumGet(NumGet(patternObject+0)+10*A_PtrSize), "ptr", patternObject, "int*", IsActive:=1, "ptr*", caretRange:=0), ObjRelease(patternObject)
        ; GetBoundingRectangles
        DllCall(NumGet(NumGet(caretRange+0)+10*A_PtrSize), "ptr", caretRange, "ptr*", boundingRects:=0), ObjRelease(caretRange)
        ; VT_ARRAY = 0x20000 | VT_R8 = 5 (64-bit floating-point number)
        Rect := ComObject(0x2005, boundingRects)
		;If Rect.haskey(0) {
        ;    X:=Round(Rect[0]), Y:=Round(Rect[1]), W:=Round(Rect[2]), H:=Round(Rect[3])
        ;    return
        ;}
    }

    ; Acc caret
    static _ := DllCall("LoadLibrary", "Str","oleacc", "Ptr")
    idObject := 0xFFFFFFF8 ; OBJID_CARET
    if DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", WinExist("A"), "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc:=0)=0 {
        oAcc := ComObjEnwrap(9,pacc,1)
        oAcc.accLocation(ComObj(0x4003,&_x:=0), ComObj(0x4003,&_y:=0), ComObj(0x4003,&_w:=0), ComObj(0x4003,&_h:=0), 0)
        X:=NumGet(_x,0,"int"), Y:=NumGet(_y,0,"int"), W:=NumGet(_w,0,"int"), H:=NumGet(_h,0,"int")
        if (X | Y) != 0
            return
    }

    ; default caret
    CoordMode Caret, Screen
    X := A_CaretX
    Y := A_CaretY
    W := 4
    H := 20
}

SetHotkeys(NormalKeyList,NumberKeyList,OtherKeyList,ResetKeyList,TriggerKeyList)
{
    Loop, Parse, NormalKeyList, `n
    {
        Hotkey, ~%A_LoopField%, Key, UseErrorLevel
        Hotkey, ~+%A_LoopField%, ShiftedKey, UseErrorLevel
    }

    Loop, Parse, NumberKeyList, `n
    {
        Hotkey, ~%A_LoopField%, Key, UseErrorLevel
        Hotkey, ~Numpad%A_LoopField%, NumpadKey, UseErrorLevel
    }

    Loop, Parse, OtherKeyList, `n
        Hotkey, ~%A_LoopField%, Key, UseErrorLevel

    Loop, Parse, ResetKeyList, `n
        Hotkey, ~*%A_LoopField%, ResetCommand, UseErrorLevel

    Hotkey, IfWinExist, AutoComplete ahk_class AutoHotkeyGUI
    Loop, Parse, TriggerKeyList, `n
        Hotkey, %A_LoopField%, CompleteCommand, UseErrorLevel
}
