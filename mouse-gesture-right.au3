#AutoIt3Wrapper_Icon="mouse-gesture-right.ico"

#include <Misc.au3>

If _IsPressed(11) Then ; 11 is CTRL
	Send("#^{RIGHT}")
Else
	Send("!{TAB}")
EndIf
