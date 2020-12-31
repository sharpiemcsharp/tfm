-- Lol Maze
-- by Sharpiepoops
-- Makes use of Alexander Simakov's maze generation that I found years ago, but his site has since gone by the looks of it

MEEP   = true
COLS   = 13
ROWS   = 6
TILE   = 60
ADMINS = { "sharpiepoops#0020", "+sharpiepoops#0000", "sharpieboob#0000" }
BLOBS  = false

-----------------------------------------------------------------------------------------------------------------------


-- DESCRIPTION:  Maze generation program Lua <-> C:
--               Lua - maze generation
--               C   - maze visualization
--      AUTHOR:  Alexander Simakov, <xdr [dot] box [at] Gmail>
--               http://alexander-simakov.blogspot.com/
--     LICENSE:  Public domain
--  HOW-TO RUN:  gcc -o maze_generator -Wall `pkg-config lua5.1 --libs --cflags` maze_generator.c
--              ./maze_generator ./maze_dfs.lua 15 10

local Maze = {}

--
-- Public methods
--

-- Create new Maze instance
function Maze:new(width, height)
    local obj = {
        width       = width,
        height      = height,
        cells       = {},
        ascii_board = {},
    }

    setmetatable(obj, self)
    self.__index = self

    return obj
end

-- Generate maze
function Maze:generate()
    self:_init_cells()
    self:_init_ascii_board()

    self.cells[1][1].left_wall                     = false -- open entry point
    self.cells[self.height][self.width].right_wall = false -- open exit point

    self:_process_neighbor_cells(1, 1);
    local result = self:_render()

    return result
end

--
-- Private methods
--

-- Close all walls, mark all cells as not visited yet
function Maze:_init_cells()
    self.cells = {}
    for y = 1, self.height do
        self.cells[y] = {}
        for x = 1, self.width do
            self.cells[y][x] = {
                left_wall   = true,
                right_wall  = true,
                top_wall    = true,
                bottom_wall = true,
                is_visited  = false,
            }
        end
    end

    return
end

-- Draw +---+---+ ... +---+
function Maze:_draw_horizontal_bar()
    local line = ''

    for x = 1, self.width do
        line = line .. '+---'
    end
    line = line .. '+'

    return line
end

-- Draw |   |   | ... |   |
function Maze:_draw_vertical_bars()
    local line = ''

    for x = 1, self.width do
        line = line .. '|   '
    end
    line = line .. '|'

    return line
end

-- Draw ascii chess-like board with all walls closed
function Maze:_init_ascii_board()
    self.ascii_board = {}

    for y = 1, self.height do
        local horizontal_bar = self:_string_to_array(self:_draw_horizontal_bar());
        local vertical_bars  = self:_string_to_array(self:_draw_vertical_bars());

        table.insert( self.ascii_board, horizontal_bar )
        table.insert( self.ascii_board, vertical_bars )
    end

    local horizontal_bar = self:_string_to_array(self:_draw_horizontal_bar());
    table.insert( self.ascii_board, horizontal_bar )

    return
end

-- Get cells neighbor to the cell (x,y): left, right, top, bottom
function Maze:_get_neighbor_cells(x, y)
    local neighbor_cells = {}

    local shifts = {
        { x = -1, y =  0 },
        { x =  1, y =  0 },
        { x =  0, y =  1 },
        { x =  0, y = -1 },
    }

    for index, shift in ipairs(shifts) do
        new_x = x + shift.x
        new_y = y + shift.y

        if new_x >= 1 and new_x <= self.width  and
           new_y >= 1 and new_y <= self.height
        then
            table.insert( neighbor_cells, { x = new_x, y = new_y } )
        end
    end

    return neighbor_cells
end

-- Process the cell with all its neighbors in random order
function Maze:_process_neighbor_cells(x, y)
    self.cells[y][x].is_visited = true

    local neighbor_cells = self:_shuffle(self:_get_neighbor_cells(x, y))

    for index, neighbor_cell in ipairs(neighbor_cells) do
        if self.cells[neighbor_cell.y][neighbor_cell.x].is_visited == false then
            if neighbor_cell.x > x     then     -- open wall with right neighbor
                self.cells[y][x].right_wall                              = false
                self.cells[neighbor_cell.y][neighbor_cell.x].left_wall   = false
            elseif neighbor_cell.x < x then     -- open wall with left neighbor
                self.cells[y][x].left_wall                               = false
                self.cells[neighbor_cell.y][neighbor_cell.x].right_wall  = false
            elseif neighbor_cell.y > y then     -- open wall with bottom neighbor
                self.cells[y][x].bottom_wall                             = false
                self.cells[neighbor_cell.y][neighbor_cell.x].top_wall    = false
            elseif neighbor_cell.y < y then     -- open wall with top neighbor
                self.cells[y][x].top_wall                                = false
                self.cells[neighbor_cell.y][neighbor_cell.x].bottom_wall = false
            end

            -- recursively process this cell
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

--
-- Utils
--

-- Generate random number: use either external random
-- number generator or internal - math.random()
function Maze:_rand(max)
    if type(external_rand) ~= "nil" then
        return external_rand(max)
    else
        return math.random(max)
    end
end

-- Shuffle array (external_rand() is external C function)
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

-- Split string into array of chars
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


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WALL = 0
PATH = 1
X = {}
Y = {}

math.randomseed(os.time())


-- table contains value
table.contains = function(t,value)
	for _,v in pairs(t) do
		if v==value then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Input stuff

Input = {}
Input.SPACE = 32
Input.LEFT = 37
Input.RIGHT = 39
Input.UP = 38
Input.DOWN = 40
for ii = 65,65+25,1 do
--	print("input: key:"..ii.." "..string.char(ii))
	Input[string.char(ii)] = ii
end

Input._bind = function(p,k,d,y)
	if type(k)=="table" then
		for _,kk in pairs(k) do
			tfm.exec.bindKeyboard(p,kk,d,y)
			--print("BIND:"..p.." k:"..kk)
		end
	else
		tfm.exec.bindKeyboard(p,k,d,y)
		--print("BIND:"..p.." k:"..k)
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
					-- Sham only requested
					bind = false
				elseif o == "M" and pi.isShaman==true then
					-- Mice only requested
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
	-- left
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


---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Commands

Commands = {}

-- string split
Commands._split = function(s,t)
	local r = {}
	for p in string.gmatch(s,"[^"..t.."]+") do
		table.insert(r,p)
	end
	return r
end

Commands._property = function(player, object, key, command_args, type_conversion_func)
	if object and object[key] then
		if #command_args == 2 then
			-- set
			if type_conversion_func then
				object[key] = type_conversion_func(command_args[2])
			else
				object[key] = command_args[2]
			end
		end
		-- get
		tfm.exec.chatMessage(string.format("%s: %s", key, tostring(object[key])))
	end
end

Commands.init = function()
	--disableChatCommandDisplay
end

Commands.command_cols = function(player, command_args)
	Commands._property(player, _G, "COLS", command_args, tonumber)
end

Commands.command_rows = function(player, command_args)
	Commands._property(player, _G, "ROWS", command_args, tonumber)
end

Commands.command_tile = function(player, command_args)
	Commands._property(player, _G, "TILE", command_args, tonumber)
end


function eventChatCommand(player, str)
	player = player:lower()
	if table.contains(ADMINS, player) then
		local command_args = Commands._split(str,' ')
		local command_func = 'command_' .. string.lower(command_args[1])
		if Commands[command_func] then
			Commands[command_func](player, command_args)
		else
			tfm.exec.chatMessage("Unknown command", player)
		end
	end
end



---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- checks if a position isn't out of bounds of the maze.
function inbounds(x,y)
	if x > COLS or x < 2 then
		return false
	end
	if y > ROWS or y < 2 then
		return false
	end
	return true
end

function GenerateXML(cols, rows)
	local cols = cols or COLS
	local rows = rows or ROWS
	maze = Maze:new(cols, rows)
	local ascii = maze:generate()
	--print(ascii)
	
	local map_width  = TILE * (cols + 1)
	local map_height = TILE * (rows + 1)
	
	print(string.format("[%04d,%04d]", map_width, map_height))
	
	local xml = string.format('<C><P L="%d" H="%d" G="%d,%d" /><Z><S>', map_width, map_height, 0, 0)
	
	local y = 28
	local ascii_cols = cols * 4 + 1
	local ascii_rows = rows * 2 + 1

	for ascii_y = 1, ascii_rows, 1 do
		local x = 10
		for ascii_x = 1, ascii_cols, 2 do
			--print(string.format("[%03d,%03d] [%02d,%02d]", x, y, ascii_x, ascii_y))
			if (ascii_y % 2) == 1 then
				if BLOBS and (ascii_x % 4) == 1 then
					xml = xml .. string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" o="606060" P="%s" />', 12, x, y, 10, 10, "0,0,0,0.2,0,0,0,0")
				end
				local c = string.byte(maze.ascii_board[ascii_y][ascii_x])
				--print(c)
				if c == 45 then
					xml = xml .. string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" o="404040" P="%s" />', 12, x, y, 50, 10, "0,0,0,0.2,0,0,0,0")
				end
			else
				local c = string.byte(maze.ascii_board[ascii_y][ascii_x])
				--print(c)
				if c == 124 then
					xml = xml .. string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" o="404040" P="%s" />', 12, x, y, 10, 50, "0,0,0,0.2,0,0,0,0")
				end
			end
			x = x + TILE / 2
		end
		y = y + TILE / 2
	end
	
	xml = xml .. '</S><D>'
	xml = xml .. string.format('<DS X="%d" Y="%d" />', TILE * 0.5, TILE * 0.75)
	xml = xml .. string.format('<T X="%d" Y="%d" />',  TILE * cols - TILE / 4, TILE * rows + TILE / 4)
	xml = xml .. string.format('<F X="%d" Y="%d" />',  TILE * cols - TILE / 4, TILE * rows + TILE / 4)
	xml = xml .. '</D><O></O></Z></C>'
	--print(xml:gsub("<", "["):gsub(">", "]"))
	return xml
end

function eventNewGame()

	if tfm.get.room.currentMap ~= '@0' then
		print("blah")
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
		tfm.exec.changePlayerSize(p, 0.7)
		if MEEP then
			tfm.exec.giveMeep(p)
		end
	end
end

function eventLoop(t,r)
	--if r < 3 then
	---	xml = GenerateXML()
	--	tfm.exec.newGame(xml)
	--end
end

if tfm then
	tfm.exec.disableAutoShaman(true)
	tfm.exec.disableAutoScore(false)
	tfm.exec.disableMortCommand(false)
	tfm.exec.disableWatchCommand(false)
	tfm.exec.newGame()
else
	local cols = tonumber(arg[1])
	local rows = tonumber(arg[2])
	xml = GenerateXML(cols, rows)
end
