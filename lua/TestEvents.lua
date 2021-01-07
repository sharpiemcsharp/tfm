#!/usr/bin/env lua
------------------------------------------
-- GENERATED FILE, DO NOT EDIT DIRECTLY --
------------------------------------------
function printf(fmt, ...)
 print(string.format(fmt, ...))
end
       


function DEBUG(fmt, ...)
 print("DEBUG: " .. string.format(fmt, ...))
end

Events = {}

Events.Names = {
 "ChatCommand",
 "EmotePlayed",
 "FileLoaded",
 "FileSaved",
 "Keyboard",
 "Loop",
 "Mouse",
 "NewGame",
 "NewPlayer",
 "PlayerDataLoaded",
 "PlayerDied",
 "PlayerGetCheese",
 "PlayerLeft",
 "playerMeep",
 "PlayerRespawn",
 "PlayerVampire",
 "PlayerWon",
 "PopupAnswer",
 "SummoningCancel",
 "SummoningEnd",
 "SummoningStart",
 "TextAreaCallback"
}


Events.CONTINUE = 0
Events.STOP = 1


Events.Handlers = {}

Events.addHandler = function(handler)
 table.insert(Events.Handlers, handler)
end


Events.pipeline = function(event)
 local function f(...)
  for _, handler in ipairs(Events.Handlers) do
   if handler[event] then
    local r = handler[event](...)
    if not r then
     r = 0
    end
    DEBUG("Events.pipeline[%s]: Handler returned: %d", event, r)
    if r == Events.STOP then
     return
    end
   end
  end
 end
 return f
end

Events.init = function()
 for i, _ in ipairs(Events.Names) do
  Events.Names[i] = "event" .. Events.Names[i]
 end
 for _, event in ipairs(Events.Names) do
  if not _G[event] then
   for _, handler in ipairs(Events.Handlers) do
    if handler[event] then
     DEBUG("Events. creating %s pipeline ...", event)
     _G[event] = Events.pipeline(event)
     break
    end
   end
  end
 end
end


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
