	-- Sharpiepoops' tfm.* namespace browser v0.02

	gui = {}

	gui.rgb = function(r,g,b)
		return r * 256 * 256 + g * 256 + b
	end

	gui.null = {}
	gui.null.isVisibleForPlayer = function(p)
		return false
	end

	gui.controls = {}
	gui.baseid = 0
	gui.defaultbg = gui.rgb(0,0,128)
	gui.defaultbc = gui.rgb(255,255,255)
	gui.defaultba = 0.8

	gui.autoCloseEqual = 1
	gui.autoCloseGreaterThanOrEqual = 2

	gui.control = {}

	gui.control.show = function(c,p)
		--print('gui.show:'..tostring(c)..':'..tostring(c.x)..','..tostring(c.y))
	
		-- auto close members of same autoCloseGroup
		if c.autoCloseGroup then
			--print('autoCloseGroup:'..c.autoCloseGroup)
			for i,c2 in ipairs(gui.controls) do
				if c2.autoCloseGroup and c.id ~= c2.id then
					--print('- autoCloseGroup:'..c2.autoCloseGroup .. ' header:'..c2.header.. ' behaviour:'..c.autoCloseGroupBehaviour)
					if c.autoCloseGroupBehaviour == gui.autoCloseEqual and c.autoCloseGroup == c2.autoCloseGroup then
						c2:hide(p)
					elseif c.autoCloseGroupBehaviour == gui.autoCloseGreaterThanOrEqual and c2.autoCloseGroup >= c.autoCloseGroup then
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
		ui.addTextArea(gui.baseid + c.id, c.html, p, c.x, c.y, c.w, c.h, c.bg, c.bc, c.ba)
		if p then
			c.isVisible[p] = true
		else
			c.isVisible = {}
			c.isVisible['*'] = true
		end
	end

	gui.control.hide = function(c,p)
		-- call onHide
		if c.onHide then
			c:onHide()
		end
		-- hide
		ui.removeTextArea(gui.baseid + c.id, p)
		if p then
			c.isVisible[p] = false
		else
			c.isVisible = {}
		end
		-- destroy if needed
		if c.destroyOnClose == true then
			gui.controls[c.id] = gui.null
		end
	end

	gui.control.toggle = function(c,p)
		if c:isVisibleForPlayer(p) then
			c:hide(p)
		else
			c:show(p)
		end
	end

	gui.control.isVisibleForPlayer = function(c,p)
		if c.isVisible[p] == true then
			return true
		end
		if c.isVisible['*'] == true then
			return true
		end		
		return false
	end


	gui.newControl = function(x,y,w,h)
		local c = {}
		c.x    = x
		c.y    = y
		c.w    = w
		c.h    = h
		c.id   = table.getn(gui.controls)+1
		c.text = ""
		c.html = ""
		c.isVisible = {}
		c.isVisibleForPlayer = gui.control.isVisibleForPlayer
		c.autoCloseGroupBehaviour = gui.autoCloseEqual
		c.destroyOnClose = false
		c.bg   = gui.defaultbg
		c.bc   = gui.defaultbc
		c.ba   = gui.defaultba
		--print("id:" .. c.id)
		table.insert(gui.controls,c)
	
		-- set up methods
		c.show   = gui.control.show
		c.hide   = gui.control.hide
		c.toggle = gui.control.toggle
	
		return c
	end

	-- Label ----------------------------------------------------------------------
	gui.label = {}
	gui.label.setText = function(c,text)
		c.text = text
		c.html = text
	end

	gui.newLabel = function(x,y,w,h,text)
		c = gui.newControl(x,y,w,h)
		c.type = "gui.label"
		c.setText = gui.label.setText
		c:setText(text)
		return c
	end

	-- Button ---------------------------------------------------------------------
	gui.button = {}
	gui.button.setText = function(c,text)
		c.text = text
		c.html = '<a href="event:' .. c.id .. '" >' .. text .. '</a>'
	end

	gui.newButton = function(x,y,w,h,text)
		c = gui.newControl(x,y,w,h)
		c.type = "gui.button"
		c.setText = gui.button.setText
		c:setText(text)
		return c
	end
	
	-- List -----------------------------------------------------------------------
	gui.list = {}	

	gui.list.resetItems = function(c)
		c.children = {}
	end

	gui.list.addItem = function(c,child)
		-- update the id to reflect it's position in the table
		child.parent = c
		child.id = table.getn(c.children) + 1
		child:setText(child.text)
		table.insert(c.children, child)
		c.html = '<ol>'
		for i,child in ipairs(c.children) do
			if child.type == "gui.label" then
				c.html = c.html .. child.html .. '<br>'
			elseif child.type == "gui.button" then
				c.html = c.html .. '<li>' .. child.html .. '</li>'
			end
		end
		c.html = c.html .. '</ol>'
	end

	gui.newList = function(x,y,w,h)
		c = gui.newControl(x,y,w,h)
		c.type = "gui.list"
		c.children = {}
		c.addItem    = gui.list.addItem
		c.resetItems = gui.list.resetItems
		return c
	end


	-- Default event callback handler.
	gui.eventTextAreaCallback = function(id,p,callback)
		--tfm.exec.chatMessage('['..p..'] id:'.. id .. ' event:' .. callback)
		local c = gui.controls[id]
		if c then
			if c.onClick then
				c:onClick(id,p,callback)
			end
		end
	end

	gui.eventMouse = function(p,x,y)
		bAutoClose = true
		r = false
	
		-- see if the click was on an open control
		for i,c in ipairs(gui.controls) do
			if c:isVisibleForPlayer(p) and x > c.x and x < (c.x+c.w) and y > c.y and y < (c.y + c.h) then
				bAutoClose = false
				r = true
			end
		end

		-- auto close members of same autoCloseGroup
		if bAutoClose == true then
			for i,c in ipairs(gui.controls) do
				if c.autoCloseGroup and c:isVisibleForPlayer(p) then
					c:hide(p)
					r = true
				end
			end
		end
	
		--print('gui.eventMouse: consumed:' .. tostring(r))
		return r
	end


	onShow = function(self)
		self:resetItems()
		self:addItem( gui.newLabel(0,0,0,0,self.header)  )
		for p,_ in pairs(self.root) do
			self:addItem( gui.newButton(0,0,0,0,p)  )
		end
	end

	onClick = function(self,id,p,callback)
		--tfm.exec.chatMessage('list1: onClick: event:' .. callback)
		text = self.children[tonumber(callback)].text
		full = self.header .. text
		--tfm.exec.chatMessage('list1: onClick: text='..text .. ' full:' .. full)
		local _,depth = string.gsub(full, "%.", "")
		local value = self.root[text]
		if type(value)=="table" then
			-- descend
			-- local sublist = gui.newList(self.x + self.w + 16, self.y, self.w, self.h)
			local sublist = gui.newList(self.x + self.w + 16, 30, self.w, 360)
			sublist.root = value
			sublist.onShow = self.onShow
			sublist.onClick = self.onClick
			sublist.header = full .. '.'
			sublist.autoCloseGroup = depth
			sublist.autoCloseGroupBehaviour = gui.autoCloseGreaterThanOrEqual
			sublist.destroyOnClose = true
			sublist:show(p)
		else
			-- just pop value
			-- local label = gui.newLabel(self.x + self.w + 16, self.y + (tonumber(callback)-1)*12, self.w, 30, '['..type(value)..'] '..tostring(value))
			local label = gui.newLabel(self.x + self.w + 16, 30, self.w, 360, '['..type(value)..'] '..tostring(value))
			label.autoCloseGroup = depth
			label.autoCloseGroupBehaviour = gui.autoCloseGreaterThanOrEqual
			label.destroyOnClose = true
			label:show(p)
		end
	end

	list_tfm = gui.newList(10,30,180,80)
	list_tfm.header = 'tfm.'
	list_tfm.root = tfm
	list_tfm.onShow = onShow
	list_tfm.onClick = onClick

	list_system = gui.newList(10,120,180,180)
	list_system.header = 'system.'
	list_system.root = system
	list_system.onShow = onShow
	list_system.onClick = onClick

	list_ui = gui.newList(10,310,180,80)
	list_ui.header = 'ui.'
	list_ui.root = ui
	list_ui.onShow = onShow
	list_ui.onClick = onClick

	tfm.exec.newGame()
	list_tfm:show()
	list_system:show()
	list_ui:show()

	function eventNewGame()
		for p,_ in pairs(tfm.get.room.playerList) do
			system.bindMouse(p,yes)
		end
	end

	function eventTextAreaCallback(id,p,callback)
		--print('eventTextAreaCallback')
		gui.eventTextAreaCallback(id,p,callback)
	end

	function eventMouse(p,x,y)
		--print('eventMouse')
		if not gui.eventMouse(p,x,y) then
			-- gui did not handle this event
		end
	end