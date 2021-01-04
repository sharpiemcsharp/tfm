#!/usr/bin/env lua
------------------------------------------
-- GENERATED FILE, DO NOT EDIT DIRECTLY --
------------------------------------------
       

-- string split
string.split = function(s,t)
 local r = {}
 for p in string.gmatch(s,"[^"..t.."]+") do
  table.insert(r,p)
 end
 return r
end

-- string s starts with prefix p ?
string.startswith = function(s,p)
 return string.sub(s,1,string.len(p))==p
end
       

       

function DEBUG(msg)
 print('DEBUG:' .. msg)
end

       

-- table contains value
table.contains = function(t, value)
 for _,v in pairs(t) do
  if v==value then
   return true
  end
 end
 return false
end

-- combine some arrays (not tables!)
table.combine = function(...)
 local r = {}
 for _,a in pairs(arg) do
  if a and type(a)=='table' then
   for _,e in pairs(a) do
    table.insert(r,e)
   end
  end
 end
 return r
end



-- Create global
Commands = {}

-- Create our collection of command bags
-- A command bag is a table<string, function>
Commands._bags = {}


Commands.add = function(bag)
 DEBUG("Commands.add: begin")

 DEBUG("Commands.add: #bags before:" .. #Commands._bags)

 table.insert(Commands._bags, bag)

 DEBUG("Commands.add: #bags after: " .. #Commands._bags)

 -- hide
 for key, _ in pairs(bag) do
  if not string.startswith(key, '_') then
   system.disableChatCommandDisplay(key)
  end
 end

 DEBUG("Commands.add: end")
end


Commands.property = function(object, key, type_conversion_func)
 local function f(p, a)
  DEBUG(string.format("Commands.property.inner: obj %s key %s", tostring(object), key))
  if object and object[key] then
   DEBUG("Commands.property.inner: #args:" .. #a)
   if #a >= 2 then
    -- set
    if type_conversion_func then
     object[key] = type_conversion_func(a[2])
    else
     object[key] = a[2]
    end
   end
   -- get
   tfm.exec.chatMessage(string.format("%s: %s", key, tostring(object[key])), p)
  end
 end
 return f
end



-- Command handler
-- Call this from the global eventChatCommands
-- Returns true for success, false otherwise (command not found / unauthorized)
Commands.eventChatCommand = function(playerName, message)

 DEBUG("Commands.eventChatCommand: begin")

 playerName = playerName:lower()

 if string.startswith(message, '_') then
  DEBUG("Commands.eventChatCommand: end, error: starts with _")
  return false
 end

 local args = string.split(message, ' ')
 local key = args[1]:lower()

 DEBUG("Commands.eventChatCommand: split:" .. table.concat(args, ", "))

 DEBUG("Commands.eventChatCommand: bags: " .. #Commands._bags)

 if #Commands._bags == 0 then
  DEBUG("Commands.eventChatCommand: end, error: no bags")
  return false
 end

 for i, bag in ipairs(Commands._bags) do

  DEBUG("Commands.eventChatCommand: bag " .. i)

  if bag[key] then
   DEBUG("Commands.eventChatCommand:   " .. key .. " command found")

   local auth_result = false

   if not bag['_auth'] then
    DEBUG("Commands.eventChatCommand:   " .. key .. " authorization not required")
    auth_result = true
   elseif bag._auth(playerName) then
    DEBUG("Commands.eventChatCommand:   " .. key .. " authorization success")
    auth_result = true
   end

   if auth_result then
    DEBUG("Commands.eventChatCommand:   calling command func ...")
    bag[key](playerName, args)
    DEBUG("Commands.eventChatCommand:   end (ok)")
    return true
   end

   DEBUG("Commands.eventChatCommand:   " .. key .. " authorization failed")

  else
   DEBUG("Commands.eventChatCommand:   " .. key .. " command not found")
  end
 end

 DEBUG("Commands.eventChatCommand: end, error command not found or unauthorized")
 return false
end

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
