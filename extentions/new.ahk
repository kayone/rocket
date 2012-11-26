paramCount  = %0%
userInput   = %1%
pName       = %2%
winId       = %3%

extentionPath:= "extentions\%userInput%.ahk"

IfNotExist extentionPath
{
    msgbox %temp%
	FileCopy, extentions\_template.ahk, extentionPath
}

run , C:\Dropbox\Tools\AutoHotkey\SciTE\SciTE.exe extentions\%userInput%.ahk