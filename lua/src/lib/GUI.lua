#pragma once

#include "Events.lua"

GUI = {}

Events.addHandler(GUI)

GUI.rgb = function(r,g,b)
	return r * 256 * 256 + g * 256 + b
end

GUI.null = {}
GUI.null.isVisibleForPlayer = function(p)
	return false
end

GUI.Controls = {}
GUI.baseid = 0
GUI.defaultbg = GUI.rgb(0,0,128)
GUI.defaultbc = GUI.rgb(255,255,255)
GUI.defaultba = 0.8

GUI.autoCloseEqual = 1
GUI.autoCloseGreaterThanOrEqual = 2


-- Control base class
GUI.Control = {}

GUI.Control.show = function(c,p)
	--print('GUI.show:'..tostring(c)..':'..tostring(c.x)..','..tostring(c.y))
	
	-- auto close members of same autoCloseGroup
	if c.autoCloseGroup then
		--print('autoCloseGroup:'..c.autoCloseGroup)
		for i,c2 in ipairs(GUI.Controls) do
			if c2.autoCloseGroup and c.id ~= c2.id then
				--print('- autoCloseGroup:'..c2.autoCloseGroup .. ' header:'..c2.header.. ' behaviour:'..c.autoCloseGroupBehaviour)
				if c.autoCloseGroupBehaviour == GUI.autoCloseEqual and c.autoCloseGroup == c2.autoCloseGroup then
					c2:hide(p)
				elseif c.autoCloseGroupBehaviour == GUI.autoCloseGreaterThanOrEqual and c2.autoCloseGroup >= c.autoCloseGroup then
					c2:hide(p)
				end	
			end
		end
	end

	-- call onShow
	if c.onShow then
		c:onShow()
	end

	-- show
	ui.addTextArea(GUI.baseid + c.id, c.html, p, c.x, c.y, c.w, c.h, c.bg, c.bc, c.ba)
	if p then
		c.isVisible[p] = true
	else
		c.isVisible = {}
		c.isVisible['*'] = true
	end
end

GUI.Control.hide = function(c,p)
	-- call onHide
	if c.onHide then
		c:onHide()
	end
	-- hide
	ui.removeTextArea(GUI.baseid + c.id, p)
	if p then
		c.isVisible[p] = false
	else
		c.isVisible = {}
	end
	-- destroy if needed
	if c.destroyOnClose == true then
		GUI.Controls[c.id] = GUI.null
	end
end

GUI.Control.toggle = function(c,p)
	if c:isVisibleForPlayer(p) then
		c:hide(p)
	else
		c:show(p)
	end
	end

GUI.Control.isVisibleForPlayer = function(c,p)
	if c.isVisible[p] == true then
		return true
	end
	if c.isVisible['*'] == true then
		return true
	end		
	return false
end


function GUI.Control:new(x,y,w,h)
	local c = {}
	c.x    = x
	c.y    = y
	c.w    = w
	c.h    = h
	c.id   = #GUI.Controls + 1
	c.text = ""
	c.html = ""
	c.isVisible = {}
	c.isVisibleForPlayer = GUI.Control.isVisibleForPlayer
	c.autoCloseGroupBehaviour = GUI.autoCloseEqual
	c.destroyOnClose = false
	c.bg   = GUI.defaultbg
	c.bc   = GUI.defaultbc
	c.ba   = GUI.defaultba
	--print("id:" .. c.id)
	table.insert(GUI.Controls,c)
	
	-- set up methods
	c.show   = GUI.Control.show
	c.hide   = GUI.Control.hide
	c.toggle = GUI.Control.toggle

	return c
end

-- Label ----------------------------------------------------------------------
GUI.Label = {}
GUI.Label.setText = function(c,text)
	if not text then
		text = ""
	end
	c.text = text
	c.html = text
end

function GUI.Label:new(x,y,w,h,text)
	c = GUI.Control:new(x,y,w,h)
	c.type = "GUI.Label"
	c.setText = GUI.Label.setText
	c:setText(text)
	return c
end

-- Button ---------------------------------------------------------------------
GUI.Button = {}
GUI.Button.setText = function(c,text)
	if not text then
		text = ""
	end
	c.text = text
	c.html = '<a href="event:' .. c.id .. '" >' .. text .. '</a>'
end

function GUI.Button:new(x,y,w,h,text)
	c = GUI.Control:new(x,y,w,h)
	c.type = "GUI.Button"
	c.setText = GUI.Button.setText
	c:setText(text)
	return c
end
	
-- List -----------------------------------------------------------------------
GUI.List = {}	

GUI.List.clear = function(c)
	c.children = {}
end

GUI.List.add = function(c, child)
	-- update the id to reflect its position in the table
	child.parent = c
	child.id = #c.children + 1
	child:setText(child.text)
	table.insert(c.children, child)
	-- TODO: This is slow as n increases
	c.html = '' --'<ol>'
	for i,child in ipairs(c.children) do
		if c.html:len() > 1950 then
			break
		end
		if child.type == "GUI.Label" then
			c.html = c.html .. child.html .. '<br>'
		elseif child.type == "GUI.Button" then
			c.html = c.html .. child.html .. '<br>'
			--c.html = c.html .. '<li>' .. child.html-- .. '</li>'
		end
	end
	--c.html = c.html .. '</ol>'
end

function GUI.List:new(x,y,w,h)
	c = GUI.Control:new(x,y,w,h)
	c.type = "GUI.List"
	c.children = {}
	c.add   = GUI.List.add
	c.clear = GUI.List.clear
	return c
end

-- Default event callback handler.
GUI.eventTextAreaCallback = function(id,p,callback)
	--tfm.exec.chatMessage('['..p..'] id:'.. id .. ' event:' .. callback)
	local c = GUI.Controls[id]
	if c then
		if c.onClick then
			c:onClick(id,p,callback)
			return Events.STOP
		end
	end
end

GUI.eventMouse = function(p,x,y)
	bAutoClose = true
	r = Events.CONTINUE

	-- see if the click was on an open control
	for i,c in ipairs(GUI.Controls) do
		if c:isVisibleForPlayer(p) and x > c.x and x < (c.x+c.w) and y > c.y and y < (c.y + c.h) then
			bAutoClose = false
			r = Events.STOP
		end
	end
		-- auto close members of same autoCloseGroup
	if bAutoClose == true then
		for i,c in ipairs(GUI.Controls) do
			if c.autoCloseGroup and c:isVisibleForPlayer(p) then
				c:hide(p)
				r = Events.STOP
			end
		end
	end

	--print('GUI.eventMouse: consumed:' .. tostring(r))
	return r
end
