#pragma once

Admin = {}
Admin.List = {}

Admin.Add = function(obj, level)
	if level == nil then
		level = 0
	end
	
	if type(obj) == string then
		Admin.List[obj] = level
	else
		for _, playerName in ipairs(obj) do
			Admin.List[playerName] = level
		end

Admin.IsAdmin = function(playerName)
	if Admin.List[playerName] then
		return true
	end
	return false
end

Admin.GetLevel = function(playerName)
	return Admin.List[playerName]
end
