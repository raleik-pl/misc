#AutoIt3Wrapper_Icon="mouse-gesture-left.ico"

#include <Misc.au3>

If _IsPressed(11) Then ; 11 is CTRL
	Send("#^{LEFT}")
Else
	Send("#^`")
EndIf
