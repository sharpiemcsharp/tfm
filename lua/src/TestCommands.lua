#include "lib/StringExtensions.lua"
#include "lib/Commands.lua"

STR = "Hello"

playerCommands = {}

playerCommands._write = function(message)
end

playerCommands.foo = function(p,a)
	print("foo!")
end

playerCommands.bar = function(p,a)
	print("bar!")
end

playerCommands.str = Commands.property(_G, "STR")

Commands.add(playerCommands)

function eventChatCommand(playerName, message)
	print(string.format("eventChatCommand: received %s %s", playerName, message))
	Commands.eventChatCommand(playerName, message)
end

