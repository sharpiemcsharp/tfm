-- Meep Maze
-- by Sharpiepoops
-- Makes use of Alexander Simakovs maze generation that I found years ago, but his site has since gone by the looks of it

ADMINS = { "Sharpiepoops#0020" }
MEEP   = true
COLS   = 13
ROWS   = 6
TILE   = 60
BLOBS  = false
COLOR  = "324650"
SIZE   = 0.7
TIME   = 60
SOUL   = 0


#include "lib/Input.lua"
#include "lib/Admin.lua"
#include "lib/Commands.lua"

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

-- Admins
Admin.add(ADMINS)

-- Add default admin command set
Commands.add(Admin.Commands)

-- Meep maze admin commands
adminCommands = {}
adminCommands._auth = Admin.isAdmin
adminCommands.cols  = Commands.property(_G, "COLS" , tonumber)
adminCommands.rows  = Commands.property(_G, "ROWS" , tonumber)
adminCommands.tile  = Commands.property(_G, "TILE" , tonumber)
adminCommands.color = Commands.property(_G, "COLOR")
adminCommands.size  = Commands.property(_G, "SIZE" , tonumber)
Commands.add(adminCommands)


function GenerateGround(T, X, Y, L, H, P, o)
	return string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" P="%s" o="%s"/>', T, X, Y, L, H, P, o)
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
			--print(string.format("[%03d,%03d] [%02d,%02d]", x, y, ascii_x, ascii_y))
			if (ascii_y % 2) == 1 then
				if BLOBS and (ascii_x % 4) == 1 then
					xml = xml .. GenerateGround(12, x, y, 10, 10, "0,0,0,0.2,0,0,0,0", COLOR)
				end
				local c = string.byte(maze.ascii_board[ascii_y][ascii_x])
				--print(c)
				if c == 45 then
					xml = xml .. GenerateGround(12, x, y, TILE - 10, 10, "0,0,0,0.2,0,0,0,0", COLOR)
				end
			else
				local c = string.byte(maze.ascii_board[ascii_y][ascii_x])
				--print(c)
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
	xml = xml .. string.format('<T X="%d" Y="%d" />',  TILE * cols - TILE / 4, TILE * rows + TILE / 4)
	xml = xml .. string.format('<F X="%d" Y="%d" />',  TILE * cols - TILE / 4, TILE * rows + TILE / 4)
	xml = xml .. '</D><O></O></Z></C>'
	--print(xml:gsub("<", "["):gsub(">", "]"))
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
	--if r < 3 then
	---	xml = GenerateXML()
	--	tfm.exec.newGame(xml)
	--end
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
