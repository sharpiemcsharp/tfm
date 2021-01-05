#pragma once

-- split
function string:split(sep)
	local r = {}
	for p in string.gmatch(self, "[^" .. sep .. "]+") do
		table.insert(r, p)
	end
	return r
end

-- does s start with prefix p ?
function string:startswith(prefix)
	return string.sub(self, 1, string.len(prefix)) == prefix
end

-- are strings equal?
function string.equal(s1, s2, case_insensitive)
	if case_insensitive then
		return s1:lower() == s2:lower()
	else
		return s1 == s2
	end
end
