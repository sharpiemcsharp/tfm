#pragma once

#include "StringExtensions.lua"

-- table contains value
table.contains = function(t, value, case_insensitive)
	for _, v in pairs(t) do
		if string.equal(v, value, case_insensitive) then
			return true
		end
	end
	return false
end

-- combine some arrays (not tables!)
table.combine = function(...)
	local r = {}
	for _, a in pairs(arg) do
		if a and type(a)=='table' then
			for _,e in pairs(a) do
				table.insert(r,e)
			end
		end
	end
	return r
end


-- key
table.keys = function(t, sort)
	r = {}
	for k, _ in pairs(t) do
		table.insert(r, k)
	end
	if sort then
		table.sort(r)
	end
	return r
end

-- values
table.values = function(t, sort)
	r = {}
	for _, v in pairs(t) do
		table.insert(r, v)
	end
	if sort then
		table.sort(r)
	end
	return r
end

