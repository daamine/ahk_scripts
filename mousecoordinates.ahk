Hotkey #!m, getMousePos
 
getMousePos() {
	MouseGetPos, xpos, ypos
	xy := "x" xpos " y" ypos
	ToolTip %xy%
	Clipboard := xy
	SetTimer toolTipClear, -1000
}
 
tooltipClear() {
	ToolTip
}