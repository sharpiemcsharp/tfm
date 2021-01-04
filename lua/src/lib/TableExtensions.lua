#pragma once

-- table contains value
table.contains = function(t, value)
	for _,v in pairs(t) do
		if v==value then
			return true
		end
	end
	return false
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
