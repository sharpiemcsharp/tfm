-- GOOD MAPS

-- #45732
-- #73686
-- #82767
-- #37517
-- #92978
-- #67264
-- #18358
-- #48141
-- #88658
-- #30375
-- #1948
-- #39730
-- #63367
-- #76795
-- #30632 (EDIZ 10)
-- #33281 (EDIZ 10)

-- HMM MAPS
-- #43425

-- SMALLER GROUNDS: (TEST BIG?)
-- #46494 (10+ me + mak)
-- #78962 (10+ me + mak)
-- #74219 (10+ me + mak)
-- #63839
-- #21317
-- #888
-- #48740
-- #69716 (10)
-- #17908 (10+)


function split(s,t) local r={}; for p in string.gmatch(s,"[^"..t.."]+") do table.insert(r,p); end;return r;end


GROUNDS = 20

function GenerateXML()
	local n = GROUNDS
	local r = 0
	local L = 40;
	local X, Y, Y1, Y2, H1, H2;
	local s
	local TT = { 0, 1, 2, 3, 4, 5, 6, 7, 10, 11, 16, 17 }
	local T  = TT[math.random(#TT)]
	local R = {}
	local a
	local rst = 9999
	local fr = 0
	local maplength = n * 200 + 400

	tfm.exec.chatMessage("<R>#" .. tostring(SEED) .. " ground:" .. tostring(T),"sharpiepoops")

	-- start xml, random bg
	local xml = string.format('<C><P Ca="" L="%d" F="%d" defilante="0,0,0,1" aie="" /><Z><S>', maplength, math.random(9))

	-- spawn ground
	xml = xml .. string.format('<S X="50" Y="350" L="100" H="100" T="%d" P="0,0,0,0,0,0,0,0" />', T)

	-- roof
	xml = xml .. string.format('<S X="%d" Y="10" L="%d" H="40" T="%d" P="0,0,0,%d,0,0,0,0" />', maplength/2-300, maplength, T, rst)
	

	for i = 0,n-1,1 do
		-- Pick a random number
		r  = math.random(200)

		-- X value of this ground
		X  = 300 + (i * 200)

		-- Upper ground:
		-- Height
		H1 = 100 + r
		Y1 = H1 / 2 
		
		-- Lower ground:
		H2 = 400 - (H1+100)
		Y2 = H1 + 130 + H2/2

		-- hmm, nudge up
		Y1 = Y1 - 20
		Y2 = Y2 - 20
		
		-- nudge height to make it easier towards the start
		H1 = H1 - (n-i)
		H2 = H2 - (n-i)

		-- Generate angle, and add upper ground
		a = 181 + (i%3)
		s = string.format('<S T="%d" P="0,0,%d,%d,%d,0,0,0" X="%d" Y="%d" L="%d" H="%d" />',T,fr,rst,a,X,Y1,L,H1)
		xml = xml .. s

		-- Generate angle, and add lower ground
		a = (0-1) - (i%3)

		-- Last ground, rest and angle 0
		--if i==n-1 then
		--	rst = 0
	--		a = 0
	--		T = 6
	--		fr = 0.3
	--	end

		if H2 > 20 then
			s = string.format('<S T="%d" P="0,0,%d,%d,%d,0,0,0" X="%d" Y="%d" L="%d" H="%d" />',T,fr,rst,a,X,Y2,L,H2)
			xml = xml .. s
		end

		L = L + 2

		-- textarea width
		local taw = 12;
		if i+1>=10 then
			taw = 20
		end
		ui.addTextArea(100+i, tostring(i+1), nil, X-taw/2, 26, taw, 16, 0x010101, 0xffffff, 0.5, false)
		
--		table.insert(R,r)
	end

	xml = xml .. '</S><D>'

	-- mouse spawn
	xml = xml .. '<DS X="50" Y="300" />'

	-- holes and cheeses
	for i = 0,19,1 do
		xml = xml .. string.format('<T X="%d" Y="%d" />', maplength-100, 30 + i*20)
	end
	for i = 0,18,1 do
		xml = xml .. string.format('<F X="%d" Y="%d" />', maplength-100, 20 + i*21)
	end

	xml = xml .. '</D><O>'

--	for i = 0,n,1 do
		--X = (i+1) * 200
		--Y = R[i+1] + 150
--		s = string.format('<O C="6" X="%d" Y="%d" P="0" />',X,Y)
--		xml = xml .. s
--	end

	xml = xml .. '</O></Z></C>'

	return xml
end




SEED = math.random(100000)
math.randomseed(SEED)

SPAWN = {}
SPEED = {}


function Bind(p)
	tfm.exec.bindKeyboard(p,32, true,true)
	tfm.exec.bindKeyboard(p,37, true,true)
	tfm.exec.bindKeyboard(p,38, true,true)
	tfm.exec.bindKeyboard(p,39, true,true)
	tfm.exec.bindKeyboard(p,40, true,true)
	tfm.exec.bindKeyboard(p,string.byte('W',1),true,true)
	tfm.exec.bindKeyboard(p,string.byte('A',1),true,true)
	tfm.exec.bindKeyboard(p,string.byte('S',1),true,true)
	tfm.exec.bindKeyboard(p,string.byte('D',1),true,true)
	tfm.exec.bindKeyboard(p,string.byte('Q',1),true,true)
	tfm.exec.bindKeyboard(p,string.byte('Z',1),true,true)
	system.bindMouse(p,true)
end

function Kill(p)
	tfm.exec.killPlayer(p)
	SPAWN[p] = 1
end

function Fly(p,x,y)
	if SPEED[p] then
		SPEED[p] = nil
		tfm.exec.movePlayer(p,0,0,true,45,0,true)
	end
	tfm.exec.movePlayer(p,0,0,true,0,-50,true)
end

function eventNewGame()
	SPAWN = {}
	for p,_ in pairs(tfm.get.room.playerList) do
		Kill(p)
	end
	tfm.exec.setGameTime(6*60,true)
	tfm.exec.setUIMapName('<R>Flappymouse: #' .. tostring(SEED))
--	tfm.exec.setUIShamanName('Flappymouse')
end

function eventMouse(p,x,y)
	Fly(p,x,y)
end

function eventKeyboard(p,k,d,x,y)
	if not tfm.get.room.playerList[p].isDead then
		if k==32 then
			if y < 0 then
				Kill(p)
			else
				Fly(p,x,y)
			end
		else
			if x < 4700 then
				tfm.exec.chatMessage("<R>Don't move!<J>You can only press <VP>SPACE<J>! <J>Só aperte <VP>ESPAÇO!<J>!",p)
				Kill(p)
			end
		end
	end
end


local ticktock = true
function eventLoop(t,r)
	ticktock = not ticktock
	if ticktock then
		return
	end
	--print(t)
	if r < 3 then
		SEED = math.random(100000)
		tfm.exec.newGame(GenerateXML())
	end

	-- Respawn
	for p,_ in pairs(SPAWN) do
		tfm.exec.respawnPlayer(p)
		SPEED[p] = 1
	end
	SPAWN = {}
	
	-- 
	--for p,P in pairs(tfm.get.room.playerList) do
	--	if P.isDead==false then
	--		if P.y<0 then
	--			tfm.exec.killPlayer(p)
	--		end
	--		SetPlayerSpeedX(p)
	--	end
	--end
end

function eventPlayerDied(p)
	SPAWN[p] = 1
end

function eventPlayerWon(p)
	tfm.exec.chatMessage('<J>' .. p .. '<VP> finished the map!')
	SPAWN[p] = 1
end


function eventNewPlayer(p)
	print("new player: " .. p)
	tfm.exec.setUIMapName('<R>Flappymouse: #' .. tostring(SEED))
	tfm.exec.chatMessage('<J>Welcome to <VP>Flappymouse<J>! Type !help for help', p)
	Bind(p)
	Kill(p)
end

function eventChatCommand(p,s)
	-- print('player:' .. p .. ': ' .. s)
	local a = split(s,' ')
	local cmd = 'command_' .. string.lower(a[1])
	if _G[cmd] then
		_G[cmd](p,a)
	end
end

function command_help(p,a)
	tfm.exec.chatMessage("<J>Fly using space or mouse button. Don't press any other keys!", p)
	--tfm.exec.chatMessage('<VP>You can change the speed with command:<J>!level NUMBER    <VP>- NUMBER between 0 and 10', p)
	tfm.exec.chatMessage("<J>Type <VP>/watch YOURNAME<J> if it's hard to see your mouse!", p)
end

--[[
function command_level(p,a)
	local f = FINISHED[p] or 0
	if a[2] then
		if MOVED[p] then
			tfm.exec.killPlayer(p)
		end
		LEVEL[p] = tonumber(a[2]) or 0
		if LEVEL[p] < f then
			LEVEL[p] = f
		elseif LEVEL[p] > 10 then
			-- check player has completed at 10
			if f>=10 then
				if LEVEL[p] > 20 then
					LEVEL[p] = 20
				end
			else
				tfm.exec.chatMessage('<R>Complete at level <J>10<R> to unlock higher levels!', p)
				LEVEL[p] = 10
			end
		else

		end
		LEVEL[p] = math.floor(LEVEL[p])
		tfm.exec.chatMessage('<J>Level set to: ' .. tostring(LEVEL[p]), p)
	else
		tfm.exec.chatMessage('<R>Usage: !level NUMBER',p)
	end
end
--]]

function command_admin(p,a)
	if p:lower() == "sharpiepoops#0020" then
		cmd = a[2]:lower()
		if cmd == 'seed' then
			SEED = tonumber(a[3]) or 0
			math.randomseed(SEED)
			tfm.exec.newGame(GenerateXML())
		elseif cmd == 'grounds' then
			GROUNDS = tonumber(a[3]) or 1
			tfm.exec.newGame(GenerateXML())
		end
	end
end

tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoScore(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.setRoomMaxPlayers(30)
tfm.exec.newGame(GenerateXML())

for p,P in pairs(tfm.get.room.playerList) do
	eventNewPlayer(p)
end


