#!/usr/bin/env lua
------------------------------------------
-- GENERATED FILE, DO NOT EDIT DIRECTLY --
------------------------------------------
function string:split(sep)
local r = {}
for p in string.gmatch(self, "[^" .. sep .. "]+") do
table.insert(r, p)
end
return r
end
function string:startswith(prefix)
return string.sub(self, 1, string.len(prefix)) == prefix
end
function string.equal(s1, s2, case_insensitive)
if case_insensitive then
return s1:lower() == s2:lower()
else
return s1 == s2
end
end
table.contains = function(t, value, case_insensitive)
for _, v in pairs(t) do
if string.equal(v, value, case_insensitive) then
return true
end
end
return false
end
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
t = {}
t["name"] = "Sharpie"
t["address"] = "123 Cheese Street"
t["age"] = 9000
s = table.concat(table.keys(t, true), ", ")
print(s)
s = table.concat(table.values(t), ", ")
print(s)
