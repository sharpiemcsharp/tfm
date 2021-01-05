#include "lib/TableExtensions.lua"

t = {}
t["name"] = "Sharpie"
t["address"] = "123 Cheese Street"
t["age"] = 9000

s = table.concat(table.keys(t, true), ", ")
print(s)
s = table.concat(table.values(t), ", ")
print(s)

