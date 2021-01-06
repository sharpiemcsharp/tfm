#include "lib/stdio.lua"
#include "lib/Events.lua"


FirstHandler = {}

FirstHandler.eventNewGame = function()
	print("FirstHandler.eventNewGame")
end

FirstHandler.eventSummoningStart = function(playerName, objectType, xPosition, yPosition, angle)
	printf("FirstHandler.summoningStart %s", playerName)
	return Events.STOP
end

SecondHandler = {}

SecondHandler.eventNewGame = function()
	print("SecondHandler.eventNewGame")
end


Events.addHandler(FirstHandler)
Events.addHandler(SecondHandler)

Events.init()
