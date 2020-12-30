function f(object, path)
	for attr,value in pairs(object)
	do
		if type(value)=="table" then
			f(value, path .. "." .. attr)
		else
			local s = string.format("%s %s.%s %s", type(value), path, attr, value)
			print(s)
		end
	end
end

root = {}
root.tfm = tfm
root.system = system
root.ui = ui

f(root, "")