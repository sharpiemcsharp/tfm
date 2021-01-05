#!/usr/bin/env lua
------------------------------------------
-- GENERATED FILE, DO NOT EDIT DIRECTLY --
------------------------------------------
function DEBUG(fmt, ...)
print("DEBUG: " .. string.format(fmt, ...))
end
function string:split(sep)
local r = {}
for p in string.gmatch(self, "[^" .. sep .. "]+") do
table.insert(r, p)
end
return r
end
function string:startswith(prefix)
return string.sub(self, 1, string.len(prefix)) == prefix
end
function string.equal(s1, s2, case_insensitive)
if case_insensitive then
return s1:lower() == s2:lower()
else
return s1 == s2
end
end
table.contains = function(t, value, case_insensitive)
for _, v in pairs(t) do
if string.equal(v, value, case_insensitive) then
return true
end
end
return false
end
table.combine = function(...)
local r = {}
for _, a in pairs(arg) do
if a and type(a)=='table' then
for _,e in pairs(a) do
table.insert(r,e)
end
end
end
return r
end
table.keys = function(t, sort)
r = {}
for k, _ in pairs(t) do
table.insert(r, k)
end
if sort then
table.sort(r)
end
return r
end
table.values = function(t, sort)
r = {}
for _, v in pairs(t) do
table.insert(r, v)
end
if sort then
table.sort(r)
end
return r
end
Commands = {}
Commands._bags = {}
Commands.add = function(bag)
table.insert(Commands._bags, bag)
for key, _ in pairs(bag) do
if not string.startswith(key, '_') then
system.disableChatCommandDisplay(key)
end
end
end
Commands.property = function(object, key, type_conversion_func, readonly)
local function f(p, a)
if object and object[key] then
if #a >= 2 then
if readonly then
else
if type_conversion_func then
object[key] = type_conversion_func(a[2])
else
object[key] = a[2]
end
end
end
tfm.exec.chatMessage(string.format("%s: %s", key, tostring(object[key])), p)
end
end
return f
end
Commands.eventChatCommand = function(playerName, message)
playerName = playerName:lower()
if string.startswith(message, '_') then
return false
end
local args = string.split(message, ' ')
local key = args[1]:lower()
if #Commands._bags == 0 then
return false
end
for i, bag in ipairs(Commands._bags) do
if bag[key] then
local auth_result = false
if not bag['_auth'] then
auth_result = true
elseif bag._auth(playerName) then
auth_result = true
end
if auth_result then
bag[key](playerName, args)
return true
end
else
end
end
return false
end
Admin = {}
Admin.List = {}
Admin._add = function(p, level)
p = p:lower()
Admin.List[p] = level
end
Admin.add = function(obj, level)
if level == nil then
level = 0
end
if type(obj) == "string" then
Admin._add(obj, level)
else
for _, p in ipairs(obj) do
Admin._add(p, level)
end
end
end
Admin.isAdmin = function(p)
if Admin.List[p] then
return true
else
return false
end
end
Admin.getLevel = function(p)
return Admin.List[p]
end
Admin.Commands = {}
Admin.Commands._auth = Admin.isAdmin
Admin.Commands.admins = function(p, a)
tfm.exec.chatMessage("<font color='#AAAAAA'>admins: " .. table.concat(table.keys(Admin.List, true), ", "), p)
end
Admin.Commands.admin = function(p, a)
if #a >= 2 then
if Admin.isAdmin(a[2]) then
tfm.exec.chatMessage(string.format("<R>admin: %s is already an admin", a[2]), p)
else
Admin.add(a[2])
tfm.exec.chatMessage(string.format("<VP>admin: %s is now an admin", a[2]), p)
end
end
end
ADMINS = "Sharpiepoops#0020"
Ticks = 15
Radius = 10
Tick = 0
TickDelta = 0
DegreesPerTick = 360 / Ticks
AdminCommands = {}
AdminCommands._auth = Admin.isAdmin
AdminCommands.TICKS = nil
function eventLoop(t,r)
local ad = Tick * DegreesPerTick
local ar = math.rad(ad)
local x = Radius * math.sin(ar)
local y = Radius * math.cos(ar)
tfm.exec.setWorldGravity(x, y)
tfm.exec.addShamanObject(0, 400 + x * 10, 220 + y * 10, (180 - ad) - 180, 0, 0, false)
Tick = Tick + TickDelta
end
function eventNewGame()
roof = {}
roof.type = 10
roof.width = 1600
roof.height = 20
roof.foreground = false
roof.friction = 0
roof.restitution = 0
roof.angle = 0
roof.color = 0
roof.miceCollison = true
roof.groundCollision = false
roof.dynamic = false
roof.mass = 0
roof.linearDamping = 0
tfm.exec.addPhysicObject(0, 400, -10, roof)
Tick = 0
if tfm.get.room.mirroredMap then
TickDelta = -1
else
TickDelta = 1
end
end
