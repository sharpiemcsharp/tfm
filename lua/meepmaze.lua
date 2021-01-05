#!/usr/bin/env lua
------------------------------------------
-- GENERATED FILE, DO NOT EDIT DIRECTLY --
------------------------------------------
ADMINS = { "Sharpiepoops#0020" }
MEEP = true
COLS = 13
ROWS = 6
TILE = 60
BLOBS = false
COLOR = "324650"
SIZE = 0.7
TIME = 60
SOUL = 0
function DEBUG(fmt, ...)
print("DEBUG: " .. string.format(fmt, ...))
end
Input = {}
Input.SPACE = 32
Input.LEFT = 37
Input.RIGHT = 39
Input.UP = 38
Input.DOWN = 40
for ii = 65,65+25,1 do
Input[string.char(ii)] = ii
end
Input._bind = function(p,k,d,y)
if type(k)=="table" then
for _,kk in pairs(k) do
tfm.exec.bindKeyboard(p,kk,d,y)
end
else
tfm.exec.bindKeyboard(p,k,d,y)
print("Input" .. p .. " k:" .. k)
end
end
Input._bind_unbind_common = function(p,k,d,y)
if p and #p>2 then
Input._bind(p,k,d,y)
else
local o = p
for p,pi in pairs(tfm.get.room.playerList) do
local bind = true
if p then
if o == "S" and pi.isShaman==false then
bind = false
elseif o == "M" and pi.isShaman==true then
bind = false
end
end
if bind then
Input._bind(p,k,d,y)
end
end
end
end
Input.bind = function(p,k,u)
local d = (u==nil)
print("bind: d:"..tostring(d))
Input._bind_unbind_common(p,k,d,true)
end
Input.unbind = function(p,k,u)
local d = (u==nil)
Input._bind_unbind_common(p,k,d,false)
end
Input.bind_movement = function(p,u)
local k = {Input.LEFT, Input.RIGHT, Input.UP, Input.DOWN, Input.A, Input.D, Input.W, Input.S, Input.Q, Input.Z }
Input.bind(p,k,u)
end
Input.left = function(k)
return (k and (k==Input.LEFT or k==Input.A or k==Input.Q))
end
Input.right = function(k)
return (k and (k==Input.RIGHT or k==Input.D))
end
Input.up = function(k)
return (k and (k==Input.UP or k==Input.W or k==Input.Z))
end
Input.down = function(k)
return (k and (k==Input.DOWN or k==Input.S))
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
local Maze = {}
function Maze:new(width, height)
local obj = {
width = width,
height = height,
cells = {},
ascii_board = {},
}
setmetatable(obj, self)
self.__index = self
return obj
end
function Maze:generate()
self:_init_cells()
self:_init_ascii_board()
self.cells[1][1].left_wall = false -- open entry point
self.cells[self.height][self.width].right_wall = false -- open exit point
self:_process_neighbor_cells(1, 1);
local result = self:_render()
return result
end
function Maze:_init_cells()
self.cells = {}
for y = 1, self.height do
self.cells[y] = {}
for x = 1, self.width do
self.cells[y][x] = {
left_wall = true,
right_wall = true,
top_wall = true,
bottom_wall = true,
is_visited = false,
}
end
end
return
end
function Maze:_draw_horizontal_bar()
local line = ''
for x = 1, self.width do
line = line .. '+---'
end
line = line .. '+'
return line
end
function Maze:_draw_vertical_bars()
local line = ''
for x = 1, self.width do
line = line .. '|   '
end
line = line .. '|'
return line
end
function Maze:_init_ascii_board()
self.ascii_board = {}
for y = 1, self.height do
local horizontal_bar = self:_string_to_array(self:_draw_horizontal_bar());
local vertical_bars = self:_string_to_array(self:_draw_vertical_bars());
table.insert( self.ascii_board, horizontal_bar )
table.insert( self.ascii_board, vertical_bars )
end
local horizontal_bar = self:_string_to_array(self:_draw_horizontal_bar());
table.insert( self.ascii_board, horizontal_bar )
return
end
function Maze:_get_neighbor_cells(x, y)
local neighbor_cells = {}
local shifts = {
{ x = -1, y = 0 },
{ x = 1, y = 0 },
{ x = 0, y = 1 },
{ x = 0, y = -1 },
}
for index, shift in ipairs(shifts) do
new_x = x + shift.x
new_y = y + shift.y
if new_x >= 1 and new_x <= self.width and
new_y >= 1 and new_y <= self.height
then
table.insert( neighbor_cells, { x = new_x, y = new_y } )
end
end
return neighbor_cells
end
function Maze:_process_neighbor_cells(x, y)
self.cells[y][x].is_visited = true
local neighbor_cells = self:_shuffle(self:_get_neighbor_cells(x, y))
for index, neighbor_cell in ipairs(neighbor_cells) do
if self.cells[neighbor_cell.y][neighbor_cell.x].is_visited == false then
if neighbor_cell.x > x then -- open wall with right neighbor
self.cells[y][x].right_wall = false
self.cells[neighbor_cell.y][neighbor_cell.x].left_wall = false
elseif neighbor_cell.x < x then -- open wall with left neighbor
self.cells[y][x].left_wall = false
self.cells[neighbor_cell.y][neighbor_cell.x].right_wall = false
elseif neighbor_cell.y > y then -- open wall with bottom neighbor
self.cells[y][x].bottom_wall = false
self.cells[neighbor_cell.y][neighbor_cell.x].top_wall = false
elseif neighbor_cell.y < y then -- open wall with top neighbor
self.cells[y][x].top_wall = false
self.cells[neighbor_cell.y][neighbor_cell.x].bottom_wall = false
end
self:_process_neighbor_cells(neighbor_cell.x, neighbor_cell.y)
end
end
return
end
function Maze:_wipe_left_wall(x, y)
self.ascii_board[y * 2][(x - 1) * 4 + 1] = ' '
return
end
function Maze:_wipe_right_wall(x, y)
self.ascii_board[y * 2][x * 4 + 1] = ' '
return
end
function Maze:_wipe_top_wall(x, y)
for i = 0, 2 do
self.ascii_board[(y - 1) * 2 + 1][ (x - 1) * 4 + 2 + i] = ' '
end
return
end
function Maze:_wipe_bottom_wall(x, y)
for i = 0, 2 do
self.ascii_board[y * 2 + 1][(x - 1) * 4 + 2 + i] = ' '
end
return
end
function Maze:_render()
for y = 1, self.height do
for x = 1, self.width do
if self.cells[y][x].left_wall == false then
self:_wipe_left_wall(x, y)
end
if self.cells[y][x].right_wall == false then
self:_wipe_right_wall(x, y)
end
if self.cells[y][x].top_wall == false then
self:_wipe_top_wall(x, y)
end
if self.cells[y][x].bottom_wall == false then
self:_wipe_bottom_wall(x, y)
end
end
end
local result = ''
for index, chars in ipairs(self.ascii_board) do
result = result .. self:_array_to_string(chars)
end
return result
end
function Maze:_rand(max)
if type(external_rand) ~= "nil" then
return external_rand(max)
else
return math.random(max)
end
end
function Maze:_shuffle(array)
for i = 1, #array do
index1 = self:_rand(#array)
index2 = self:_rand(#array)
if index1 ~= index2 then
array[index1], array[index2] = array[index2], array[index1]
end
end
return array
end
function Maze:_string_to_array(str)
local array = {}
for char in string.gmatch(str, '.') do
table.insert(array, char)
end
return array
end
function Maze:_array_to_string(array)
return table.concat(array, '') .. "\n"
end
WALL = 0
PATH = 1
X = {}
Y = {}
math.randomseed(os.time())
Admin.add(ADMINS)
Commands.add(Admin.Commands)
adminCommands = {}
adminCommands._auth = Admin.isAdmin
adminCommands.cols = Commands.property(_G, "COLS" , tonumber)
adminCommands.rows = Commands.property(_G, "ROWS" , tonumber)
adminCommands.tile = Commands.property(_G, "TILE" , tonumber)
adminCommands.color = Commands.property(_G, "COLOR")
adminCommands.size = Commands.property(_G, "SIZE" , tonumber)
Commands.add(adminCommands)
function GenerateGround(T, X, Y, L, H, P, o)
return string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" P="%s" o="%s"/>', T, X, Y, L, H, P, o)
end
function GenerateXML(cols, rows)
local cols = cols or COLS
local rows = rows or ROWS
maze = Maze:new(cols, rows)
local ascii = maze:generate()
local map_width = TILE * (cols + 1)
local map_height = TILE * (rows + 1)
print(string.format("[%04d,%04d]", map_width, map_height))
local xml = string.format('<C><P L="%d" H="%d" G="%d,%d" ', map_width, map_height, 0, 0)
if SOUL == 1 then
xml = xml .. 'A="" '
end
xml = xml .. '/><Z><S>'
local y = 28
local ascii_cols = cols * 4 + 1
local ascii_rows = rows * 2 + 1
for ascii_y = 1, ascii_rows, 1 do
local x = 10
for ascii_x = 1, ascii_cols, 2 do
if (ascii_y % 2) == 1 then
if BLOBS and (ascii_x % 4) == 1 then
xml = xml .. GenerateGround(12, x, y, 10, 10, "0,0,0,0.2,0,0,0,0", COLOR)
end
local c = string.byte(maze.ascii_board[ascii_y][ascii_x])
if c == 45 then
xml = xml .. GenerateGround(12, x, y, TILE - 10, 10, "0,0,0,0.2,0,0,0,0", COLOR)
end
else
local c = string.byte(maze.ascii_board[ascii_y][ascii_x])
if c == 124 then
xml = xml .. GenerateGround(12, x, y, 10, TILE - 10, "0,0,0,0.2,0,0,0,0", COLOR)
end
end
x = x + TILE / 2
end
y = y + TILE / 2
end
xml = xml .. '</S><D>'
xml = xml .. string.format('<DS X="%d" Y="%d" />', TILE * 0.5, TILE * 0.75)
xml = xml .. string.format('<T X="%d" Y="%d" />', TILE * cols - TILE / 4, TILE * rows + TILE / 4)
xml = xml .. string.format('<F X="%d" Y="%d" />', TILE * cols - TILE / 4, TILE * rows + TILE / 4)
xml = xml .. '</D><O></O></Z></C>'
return xml
end
function eventNewGame()
if tfm.get.room.currentMap ~= '@0' then
xml = GenerateXML()
tfm.exec.newGame(xml)
end
if MEEP then
tfm.exec.setUIMapName("Meep!")
else
tfm.exec.setUIMapName("Maze!")
end
for p,_ in pairs(tfm.get.room.playerList) do
Input.bind_movement(p)
X[p] = 2
Y[p] = 10
tfm.exec.movePlayer(p, 0, 0, false, 0, 0, true)
tfm.exec.changePlayerSize(p, SIZE)
if MEEP then
tfm.exec.giveMeep(p)
end
end
tfm.exec.setGameTime(TIME)
end
function eventLoop(t,r)
end
eventChatCommand = Commands.eventChatCommand
if tfm then
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoScore(false)
tfm.exec.disableMortCommand(false)
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.newGame()
else
local cols = tonumber(arg[1])
local rows = tonumber(arg[2])
xml = GenerateXML(cols, rows)
end
