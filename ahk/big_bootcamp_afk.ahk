#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


WinActivate Transformice

TfmSendCommand(cmd)
{
	Send {ENTER}
	SendRaw /
	SendRaw %cmd%
	Send {ENTER}
}

TfmJump()
{
	SendRaw w
}

While True
{
	TfmSendCommand("changesize * 2")
	Sleep 1000
	TfmJump()
	Sleep 9000
}

