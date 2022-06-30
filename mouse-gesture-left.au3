#AutoIt3Wrapper_Icon="mouse-gesture-left.ico"

#include <Misc.au3>

If _IsPressed(11) Then ; 11 is CTRL
	Send("#^{LEFT}") ; WIN+CRTL+LEFT is left virtual desktop
Else
	Send("#^`") ; WIN+CTRL+` for PowerToys Run
EndIf
