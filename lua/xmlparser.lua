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

Map = {}
MapFilter = {}

-- private:

-- This turns an array into a chainable filter thing
Map.__a = function(a,p)
	a = a or {}
	for n,_ in pairs(MapFilter) do
		if string.startswith(n,'with') then
			a[n] = MapFilter[n]
		end
		for _,e in ipairs(a) do
			if p and string.startswith(n,p..'_') then
				e[string.sub(n,3)] = MapFilter[n]
			end
		end
	end
	return a
end

-- The main filtering function (input array,   attribute/key,  operator,  value, inverse/not)
Map.__f = function(a,k,op,V)
	local r = {}
	local m = true
	if inv then m=false end
	for i,e in ipairs(a) do
		if type(e)=='table' then
			local b = false
			local has = false
			local v = e[k]
			if v then has = true end
			if     op == 'has' then b = has
			elseif op == '=='  then b = has and v==V
			elseif op == '!='  then b = has and v~=V
			elseif op == '~='  then b = has and v~=V
			elseif op == '<='  then b = has and v<=V
			elseif op == '>='  then b = has and v>=V
			elseif op == '<'   then b = has and v< V
			elseif op == '>'   then b = has and v> V
			end
			if b==m then
				table.insert(r,e)
			end
		end
	end
	return r
end

-- Simple attribute test
Map.__t = function(e,k)
	if e[k] then return true end
	return false
end


-- public:

-- constants
Map.enum = {}
Map.enum.collsion = { all =1, mice=3, grounds=2, none=4}
Map.enum.ground   = { wood=0, ice =1, tramp  =2, lava=3, choc=4, earth=5, grass=6, sand=7, cloud=8, water=9, stone=10, snow=11, rect=12, circle=13 }


-- get map properties
Map.length = function(C)
	return C.P.L or 800
end
Map.gravity = function(C)
	return C.P.G
end
Map.background = function(C)
	return C.P.F
end
Map.isNightmode = function(C)
	return Map.__t(C.P,'N')
end
Map.isSoulmate = function(C)
	return Map.__t(C.P,'A')
end
Map.isCollision = function(C)
	return Map.__t(C.P,'C')
end

-- get map sections
Map.grounds = function(C)
	return Map.__a(C.Z.S,'S')
end
Map.miceStuff = function(C)
	return Map.__a(C.Z.D,'D')
end
Map.shamanObjects = function(C)
	return Map.__a(C.Z.O,'O')
end
Map.joints = function(C)
	local r = nil
	if C.Z.L then
		r = table.combine(C.Z.L.JD, C.Z.L.JP, C.Z.L.JPL, C.Z.L.JR)
	end
	return Map.__a(r)
end
Map.cheese = function(C)
	return Map.__a(C.Z.D.F)
end
Map.holes = function(C)
	return Map.__a(C.Z.D.T)
end
Map.miceSpawns = function(C)
	return Map.__a(C.Z.D.DS)
end
Map.shamanSpawns = function(C)
	return Map.__a(C.Z.D.DC)
end

-- get ground element properties
MapFilter.S_type = function(e)
	return e.T
end
MapFilter.S_x = function(e)
	return e.X
end
MapFilter.S_y = function(e)
	return e.Y
end
MapFilter.S_length = function(e)
	return e.L
end
MapFilter.S_height = function(e)
	return e.H
end
MapFilter.S_collision = function(e)
	if e.c then
		return Map.enum.collision[e.c]
	end
	return Map.enum.collsion.all
end
MapFilter.S_isForeground = function(e)
	return Map.__t(e,'N')
end
MapFilter.S_isDynamic = function(e)
	if e.P[1]==1 then return true end
	return false
end

-- shaman object 
MapFilter.O_x = function(e)
	return e.X
end
MapFilter.O_y = function(e)
	return e.Y
end


-- filtering functions

MapFilter.with = function(a,attr,op,value,inv)
	op = op or 'has'
	return Map.__a(Map.__f(a,attr,op,value,inv))
end

-- For grounds / decorations
MapFilter.withType = function(a,value)
	return a:with('T','==',value)
end

-- For grounds
MapFilter.withForeground = function(a,value)
	if value==true then	return a:with('N') end
	return a:with('N','has',nil,true)
end

-- For objects
MapFilter.withId = function(a,value)
	return a:with('C','==',value)
end




-- xml is either a string, or blank/nil to use tfm.get.room.xmlMapInfo
Map.parse = function(xml)
	local C = {}
	if xml==nil then
		local mi = tfm.get.room.xmlMapInfo
		if string.startswith(tfm.get.room.currentMap,'@')==false then
			-- vanilla
			return nil
		end
		C.__cat = mi.permCode
		xml = mi.xml
	end

	local E = string.split(xml,'><')
	local p = C
	p.__tag = 'C'
	for _,e in ipairs(E) do
		e = string.gsub(e,'%"','')
		local A = string.split(e,' ')
		if table.getn(A) == 1 then
			-- In tfm XML, a tag without attributes is only used for sections (I think)...  I'm relying on that :-)
			if string.find(A[1],'/') then
				-- ascend from a section
				if p.__parent then
					p = p.__parent
				end
			elseif A[1]~='C' then
				-- descend into a section. We'll make a new table for it
				p[A[1]] = {}
				p[A[1]].__parent = p
				p = p[A[1]]
				p.__tag = A[1]
			end
		else
			-- Tag has attributes, we'll parse it out and stick it in our current table (p)
			local t = {}
			for _,a in ipairs(A) do
				if string.find(a,'=') then
					local v = string.split(a,'=')
					if table.getn(v)==1 then
						-- value was blank, we'll force something in there
						table.insert(v,'')
					end
					local L = string.split(v[2],',')
					if table.getn(L)>1 then
						-- list of comma-seperated values  (eg multispawn, or ground P attribute)
						local lt = {}
						for _,l in ipairs(L) do
							table.insert(lt,tonumber(l) or l)
						end
						t[v[1]] = lt
					else
						-- simple attr=value
						t[v[1]] = tonumber(v[2]) or v[2]
					end
				end
			end
			if p.__tag == A[1] then
				-- tag has same name as the current section, so it can be added there  (S/D/O)
				table.insert(p,t)
			else
				-- make a new array for this tag if needed, and add
				if not p[A[1]] then
					p[A[1]] = {}
				end
				table.insert(p[A[1]],t)
			end
		end
	end
	C.P = C.P[1]
	
	for n,_ in pairs(Map) do
		C[n] = Map[n]
	end
	
	return C
end


-----------------------------------------------------------------------------------------------------------------------

tfm.exec.newGame('@4316482')

function eventNewGame()
	tfm.exec.chatMessage('<R>----------------------------------------------')
	map = Map.parse()
	if map then
		tfm.exec.chatMessage('<R>map parameters:')
		for a,v in pairs(map.P) do
			tfm.exec.chatMessage('<VP>  a:' .. a .. ' value:' .. tostring(v) .. ' type:' .. type(v) )
		end
		tfm.exec.chatMessage(string.format('<R>  map length:%d background:%s night:%s soulmate:%s collision:%s',map:length(),tostring(map:background()),tostring(map:isNightmode()),tostring(map:isSoulmate()),tostring(map:isCollision())))
		--tfm.exec.chatMessage('<VP>Cheese count:' .. #map:cheese())
		--tfm.exec.chatMessage('<VP>Hole count:' .. #map:holes())
		--tfm.exec.chatMessage('<VP>Mice spawn count:' .. #map:miceSpawns())
		--tfm.exec.chatMessage('<VP>Shaman spawn count:' .. #map:shamanSpawns())
		--tfm.exec.chatMessage('<J>grounds:'   .. #map:grounds())
		--tfm.exec.chatMessage('<J>woods:'   .. #map:grounds():withType(0))
		
		for i,wood in ipairs(map:grounds():withType(Map.enum.ground.wood)) do
			--print(string.format('<VP>  wood:%d x:%d y:%d l:%d h:%d fg?:%s dy?:%s',i,wood:x(),wood:y(),wood:length(),wood:height(), tostring(wood:isForeground()), tostring(wood:isDynamic()) ))
		end
		
		--tfm.exec.chatMessage('<J>ice:'     .. #map:grounds():withType(1))
		--tfm.exec.chatMessage('<J>tramp:'   .. #map:grounds():withType(2))
		--tfm.exec.chatMessage('<J>rects:'   .. #map:grounds():withType(12))
		--tfm.exec.chatMessage('<J>circles:' .. #map:grounds():withType(13))
		--tfm.exec.chatMessage('<J>woods with x lt 400:  ' .. #map:grounds():withType(0):with('X','<',400))
		--tfm.exec.chatMessage('<VP>joints:'   .. #map:joints())

		tfm.exec.chatMessage('<J>Objects with C=14:'   .. #map:shamanObjects():withId(14))
		for i,o in ipairs(map:shamanObjects():withId(14)) do
			print(string.format('<VP>  o:%d x:%d y:%d',i,o:x(),o:y()))
		end

		tfm.exec.chatMessage('<J>Objects with C=15:'   .. #map:shamanObjects():withId(15))
		for i,o in ipairs(map:shamanObjects():withId(15)) do
			print(string.format('<VP>  o:%d x:%d y:%d',i,o:x(),o:y()))
		end
	end
end

