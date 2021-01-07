#include "lib/Events.lua"
#include "lib/GUI.lua"

function onShow(c)
	c:clear()
	c:add( GUI.Label:new(0, 0, 0, 0, c.header) )
	for p,_ in pairs(c.root) do
		c:add( GUI.Button:new(0, 0, 0, 0, p) )
	end
end
	
function onClick(c, id, p, callback)
	DEBUG('onClick: callback:' .. callback)
	text = c.children[tonumber(callback)].text
	DEBUG('onClick: text length:' .. text:len())
	full = c.header .. text
	--tfm.exec.chatMessage('list1: onClick: text='..text .. ' full:' .. full)
	local _,depth = string.gsub(full, "%.", "")
	local value = c.root[text]
	if type(value)=="table" then
		-- descend
		-- local sublist = gui.newList(c.x + c.w + 16, c.y, c.w, c.h)
		local sublist = GUI.List:new(c.x + c.w + 16, 30, c.w, 360)
		sublist.root = value
		sublist.onShow = c.onShow
		sublist.onClick = c.onClick
		sublist.header = full .. '.'
		sublist.autoCloseGroup = depth
		sublist.autoCloseGroupBehaviour = GUI.autoCloseGreaterThanOrEqual
		sublist.destroyOnClose = true
		sublist:show(p)
	else
		-- just pop value
		-- local label = gui.newLabel(c.x + c.w + 16, c.y + (tonumber(callback)-1)*12, c.w, 30, '['..type(value)..'] '..tostring(value))
		local label = GUI.Label:new(c.x + c.w + 16, 30, c.w, 360, '['..type(value)..'] '..tostring(value))
		label.autoCloseGroup = depth
		label.autoCloseGroupBehaviour = GUI.autoCloseGreaterThanOrEqual
		label.destroyOnClose = true
		label:show(p)
	end
end

GUI.Label:new(700, 300, "Hello")

list_tfm            = GUI.List:new(10, 30, 180, 80)
list_tfm.header     = 'tfm.'
list_tfm.root       = tfm
list_tfm.onShow     = onShow
list_tfm.onClick    = onClick

list_system         = GUI.List:new(10, 120, 180, 180)
list_system.header  = 'system.'
list_system.root    = system
list_system.onShow  = onShow
list_system.onClick = onClick

list_ui             = GUI.List:new(10, 310, 180, 80)
list_ui.header      = 'ui.'
list_ui.root        = ui
list_ui.onShow      = onShow
list_ui.onClick     = onClick

tfm.exec.newGame()

list_tfm:show()
list_system:show()
list_ui:show()

function eventNewGame()
	for p,_ in pairs(tfm.get.room.playerList) do
		system.bindMouse(p,yes)
	end
end

Events.init()
