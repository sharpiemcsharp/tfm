
function split(s,t) local r={}; for p in string.gmatch(s,"[^"..t.."]+") do table.insert(r,p); end;return r;end

function Map1(cheese)
	local TT = { 0, 1, 2, 3, 4, 5, 6, 7, 10, 11, 16, 17 }
	local T  = TT[math.random(#TT)]
	tfm.exec.chatMessage("<R>#" .. tostring(SEED) .. " ground:" .. tostring(T),"sharpiepoops")
	-- start xml, random bg
	local xml = string.format('<C><P Ca="" L="800" F="%d" /><Z><S>', math.random(9))
	-- floor
	xml = xml .. string.format('<S X="400" Y="400" L="800" H="100" T="%d" P="0,0,0,0,0,0,0,0" />', T)
	-- walls
	xml = xml .. string.format('<S X="20"  Y="220" L="40" H="400" T="%d" P="0,0.3,0.2,0,0,0,0,0" />', T)
	xml = xml .. string.format('<S X="780" Y="220" L="40" H="400" T="%d" P="0,0.3,0.2,0,0,0,0,0,0" />', T)
	xml = xml .. '</S><D>'
	-- hole
	xml = xml .. string.format('<T X="400" Y="380" />')
	-- cheeses
	vertical_cheese_spacing = 360 / cheese
	X = 30
	for i = 0, cheese-1, 2 do
		Y = vertical_cheese_spacing * i
		xml = xml .. string.format('<F X="%d" Y="%d" />', X,     Y)
		xml = xml .. string.format('<F X="%d" Y="%d" />', 800-X, Y)
	end
	xml = xml .. '</D><O>'
	xml = xml .. '</O></Z></C>'
	return xml
end




SEED = math.random(100000)
math.randomseed(SEED)

SPAWN = {}
SPEED = {}


function eventNewGame()
	tfm.exec.setGameTime(600,true)
	tfm.exec.setUIMapName('<R>Royale With Cheese')
	Map1(10)
end

function eventPlayerDied(p)
end

function eventPlayerWon(p)
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
	tfm.exec.chatMessage("help!", p)
end

function command_admin(p,a)
	if p:lower() == "sharpiepoops#0020" then
		cmd = a[2]:lower()
	end
end

tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoScore(false)
tfm.exec.disableAfkDeath(false)
tfm.exec.setRoomMaxPlayers(30)
tfm.exec.newGame(Map1(1))

-- for p,P in pairs(tfm.get.room.playerList) do
-- 	eventNewPlayer(p)
-- end


