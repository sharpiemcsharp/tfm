#pragma once

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
