#NoEnv
#SingleInstance force

SetCapsLockState, Off
SetControlDelay, 0
Setworkingdir %A_ScriptDir%

WinGet, winId, ID, A
WinGetTitle, title, A
WinGet, pname , ProcessName, %title%

StringLower, pname , pname

OutputDebug, Starting

str =: pName
command= ERROR

badInputMessage := "$&*&%$#T&^$#@$#%????"

IniRead, browserPath, settings.ini, settings , browser
	
if(browserPath = ERROR)
{
	MsgBox "Browser has not been configured"
	exit()
}


showUi:
{
	iniWidth := 500					;initial width of gui
	guiWidth := iniWidth + 13*2		; 13 is the unreduceable left-margin spacing between gui and text

	Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, Color, 00A9DA	
	Gui, Font, s11, Consolas ;Set a large font size (32-point).
	Gui, Add, Text, vMyText cBlack w%iniWidth% left, ;can put LEFT, CENTER, or RIGHT for text alignment

	Winset, Transparent, 243	
	
	Gui, Show, y-50 			;show window off-screenl
	WinGetPos,,,,height, A	 	;store GUI height (last parameter is the gui's title)
	Y := -height
	
	Gui, Show, xCenter y%Y% w%guiWidth%, %A_ScriptFullPath%	;position GUI just above top border
	
	increment := 5
	while Y < -increment		;increment gui into position
	{
		Y := Y + increment
		Gui, Show, y%Y%
		sleep 5
	}
	Gui, Show, y0 NoActivate

	setText(pName)
}

readChar()		;input a character and show it on the GUI

setText(text)
{
	global
	str:= text
	GuiControl,, MyText, %text%
	return
}

getCommand()
{
	global
	
	OutputDebug, Parsing Command
	
	if (command = ERROR || InStr(str ,">") = 0)
	{
		IniRead, command, settings.ini, commands, %str%
		
		if(InStr(str ,"ERROR") = 0)
		{
			IfExist, extentions\%str%.ahk
				command:=str
		}
	}

	OutputDebug, Command -> %command%
	
	return command
}

getInput(input)
{
	global
	
	OutputDebug, parsing input
	
	currentCommand := GetCommand()
	

	
	if currentCommand = ERROR
	{
		return %str%
	}

	seperator := InStr(str ,">")
	
	;check if the user has provided any args or just the command
	if(seperator = 0)
	{
		return ""
	}
	
	
	userInput := Trim(SubStr(str, seperator + 1), A_Space)
	OutputDebug, Input -> %userInput%
	return userInput
}

format()
{
	global
		
	OutputDebug, re-formating
		
	command := GetCommand()
		
	if command = ERROR ; if still error
	{
		badInput()
		
	}
	else
	{
		str := command . "> "
		setText(str)
	}
}

evaluate()
{		
	OutputDebug, evaluating input -> %str%
		
	attemptCommand()
	attemptShortCut()
	attemptExtention()
		
	badInput()
}


attemptCommand()
{
	global
	command := GetCommand()		
	if command != ERROR
	{		
		OutputDebug, command %command% detected
		
		IniRead, template, settings.ini, templates, %command%
		
		OutputDebug, command teamplate %template%
		
		if template != ERROR
		{
			userInput := getInput(str)
			placeHolder := "[lookup]"
		
			StringReplace, formattedCommand, template, %placeHolder% , %userInput%
						
			launch(formattedCommand)	;quotes are used incase the input has spaces, so it is not treated as more than one parameter
		}
	}
}

attemptShortcut()
{
	global 
	OutputDebug, hotkey detected
			
	IniRead, hkey, settings.ini, hkey_%pname%, %str%
	
	if hkey = ERROR
	{
		IniRead, hkey, settings.ini, hkey_global, %str%
	}

	if hkey != ERROR
	{		
		WinActivate, ahk_id %winId%
		SendInput %hkey%
	
		GetKeyState, shiftState, Shift
		GetKeyState, ctrlState, Ctrl
		GetKeyState, altState, Alt
	
		if shiftState = D
		{
			SendInput {shift up}
		}
	
		if ctrlState = D
		{
			SendInput {ctrl up}
		}
	
		if altState = D
		{
			SendInput {alt up}
		}
	
		exit()
	}
}

attemptExtention()
{
	global
	
	extention := getCommand()
	userInput := getInput(str)

	IfExist, extentions\%extention%.ahk
	{
		run, extentions\%extention%.ahk "%userInput%" "%pname%" "%winId%" "%browserPath%"
		exit()
	}
}

backspace()
{
	global
	
	StringTrimRight, str, str, 1	;remove a character from the right side of %str%
	setText(str)
}



exit()
{
	global
	SetCapsLockState, Off
	
	Y := 0
	while Y > (0-height)
	{
		Y := Y - 3
		Gui, Show, y%Y% NoActivate
		sleep 10
	}
		
	exitApp
}	
	
badInput()
{
	global
	
	OutputDebug, Bad Input
	setText(badInputMessage)
	
	sleep 1000

	readChar()
}

readChar()
{
	global
	setText(pName)
	command := Error
		
	Loop	
	{
		Input, char, L1 M, {enter}{backspace} ;input a single character in %char%
		processKeyPress(char)
	}
}


processKeyPress(char)
{
	global
	
	asciiCode := Asc(char)
				
	;MsgBox  %char% : %asciiCode% : %ErrorLevel%
	
	if asciiCode = 0  ;check if user has pressed a terminating key
	{
		if InStr(ErrorLevel, "Backspace")
		{
			backspace()
			return
		}
			
		evaluate()
		return		
	}	
	
	;ctrl+v;
	if(asciiCode == 22)
	{
		appendText(clipboard)
		return
	}

	;ctrl+c
	if(asciiCode == 3)
	{
		clipboard:= str
		return
	}
	
	;ctrl+x
	if(asciiCode == 24)
	{
		clipboard:= str
		setText("")
		return
	}

	if(!InStr(str ,">") && (asciiCode == 9 ||  char == A_Space))
	{
		format()
	}
	else if(asciiCode > 31) ;don't print none-readable charecter.
	{	
		appendText(char)
	}
}

appendText(char)
{
	global
	
	if(str == pName)
	{
		setText("")
	}
	
	str := str . char
	setText(str)
}


launch(path)
{
	OutputDebug, Launching %path%

	if(InStr(path, "http://", false, 1) || InStr(path, "https://", false, 1))
	{
		launchUrl(path)
	}
	else
	{
		run, %path%
	}
	
	exit()
}

launchUrl(url)
{
	global
	
	encodedUrl := EncodeURL(url)
	
	
}




EncodeURL(p_data)
{
	old_FormatInteger := A_FormatInteger
	SetFormat, Integer, hex

	unsafe = 
	( Join LTrim
		25000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
		22233C3E5B5C5D5E607B7C7D7F808182838485868788898A8B8C8D8E8F9091929394
		95969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6
		B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8
		D9DADBDCDDDEDF7EE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9
		FAFBFCFDFEFF
	)
		
	loop, % StrLen( unsafe )//2
	{
		StringMid, token, unsafe, A_Index*2-1, 2
		StringReplace, p_data, p_data, % Chr( "0x" token ), `%%token%, all 
	}
		
	SetFormat, Integer, %old_FormatInteger%

	return, p_data
}	



;~LButton:: 
;~RButton:: 
~Home:: 
~End:: 
~PgUp:: 
~PgDn:: 
~Alt:: 
~LWin:: 
~RWin::
~Esc::
CapsLock::
{	
	exit()
}
