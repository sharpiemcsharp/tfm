##pragma once

#include "Debug.lua"

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
	
	DEBUG("Admin.add: begin: %s %d", tostring(type(obj)), level)

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
		DEBUG("Admin.isAdmin: %s True", p)
		return true
	else
		DEBUG("Admin.isAdmin: %s False", p)
		return false
	end
end

Admin.getLevel = function(p)
	return Admin.List[p]
end


-- Provide a default command bag for admin management
Admin.Commands = {}

Admin.Commands._auth = Admin.isAdmin

Admin.Commands.admins = function(p, a)
	tfm.exec.chatMessage("<font color='#AAAAAA'>admins: " .. table.concat(table.keys(Admin.List, true), ", "), p)
end

Admin.Commands.admin = function(p, a)
	if #a >= 2 then
		-- TODO Validate username
		if Admin.isAdmin(a[2]) then
			tfm.exec.chatMessage(string.format("<R>admin: %s is already an admin", a[2]), p)
		else
			Admin.add(a[2])
			tfm.exec.chatMessage(string.format("<VP>admin: %s is now an admin", a[2]), p)
		end
	end
end

Admin.Commands.meep = function(p, a)
	tfm.exec.giveMeep(a[2] or p)
end



--Admin.Commands.time = function(p, a)
--	if #a >= 2 then
--		local t = tonumber(a[2])
--		if t then
--			tfm.exec.setGameTime(t)
--		end
--	end
--end
