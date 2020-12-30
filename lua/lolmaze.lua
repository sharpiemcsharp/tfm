-- Lol Maze
-- by Sharpiepoops
-- Makes use of Alexander Simakov's maze generation that I found years ago, but his site has since gone by the looks of it


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

COLS = 5
ROWS = 3
WALL = 0
PATH = 1
X = {}
Y = {}

math.randomseed(os.time())

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

-- get x/y position of a tile
TILE = 30
function getx(x)
	local u = TILE
	return x*u - (u/2)
end
function gety(y)
	local u = TILE
	return y*u - (u/2)
end

function GenerateXML()
	maze = Maze:new(COLS, ROWS)
	local ascii = maze:generate()
	print(ascii)
	
	local xml = string.format('<C><P L="%d" H="%d" G="%d,%d" /><Z><S>', 800, 400, 0, 0)
	
	for y = 1, ROWS * 2 + 1, 1 do
		for x = 1, COLS * + 1, 1 do
			print(string.format("%02d,%02d",x,y))
			--print(maze.ascii_board[y][x*2]) -- .. " " .. string.byte(maze.ascii_board[y][x*2]))
			local bx = x * 2
			local by = y
			local c = string.byte(maze.ascii_board[by][bx])
			print(c)
			if (y % 2) == 1 then
				if c ~= 32 then
					xml = xml .. string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" P="%s" />', 1, getx(x), gety(y), 20, 10, "0,0,0,0.2,0,0,0,0")
				end
			else
				if c == 124 then
					xml = xml .. string.format('<S T="%d" X="%d" Y="%d" L="%d" H="%d" P="%s" />', 1, getx(x), gety(y), 10, 20, "0,0,0,0.2,0,0,0,0")
				end
			end
		end
	end
	
	xml = xml .. '</S><D>'

	xml = xml .. string.format('<T X="%d" Y="%d" />', 50, 50)
	xml = xml .. string.format('<F X="%d" Y="%d" />', 750, 350)
	
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

	tfm.exec.setUIMapName("hello")

	for p,_ in pairs(tfm.get.room.playerList) do
		Input.bind_movement(p)
		X[p] = 2
		Y[p] = 10
		tfm.exec.movePlayer(p, getx(2), gety(10), false, 0, 0, true)
	end
end

function eventLoop(t,r)
	--if r < 3 then
	---	xml = GenerateXML()
	--	tfm.exec.newGame(xml)
	--end
end


tfm.exec.newGame()
