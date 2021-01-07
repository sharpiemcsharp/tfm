ADMINS = { "Sharpiepoops#0020" }
Ticks  = 15
Radius = 10
Roof   = 1

#include "lib/Debug.lua"
#include "lib/Commands.lua"
#include "lib/Admin.lua"



Tick           = 0
TickDelta      = 0
DegreesPerTick = 0


Admin.add(ADMINS)


AdminCommands = {}
AdminCommands._auth = Admin.isAdmin
AdminCommands.ticks = Commands.property(_G, "Ticks", tonumber)
AdminCommands.roof  = Commands.property(_G, "Roof",  tonumber)

Commands.add(AdminCommands)
Commands.add(Admin.Commands)

eventChatCommand = Commands.eventChatCommand


function eventLoop(t,r)

	if t < 3000 then
		return
	end

	local ad = Tick * DegreesPerTick
	local ar = math.rad(ad)
	local x = Radius * math.sin(ar)
	local y = Radius * math.cos(ar)

	DEBUG("tick:%04d angle:%02d [%.2f,%.2f]", t, ad, x, y)

	tfm.exec.setWorldGravity(x, y)
	tfm.exec.addShamanObject(0, 400 + x * 10, 220 + y * 10, (180 - ad) - 180, 0, 0, false)

	Tick = Tick + TickDelta
end

function eventNewGame()

	if Roof == 1 then
		roof = {}
		roof.type = 10
		roof.width = 1600
		roof.height = 20
		roof.foreground = false
		roof.friction = 0
		roof.restitution = 0
		roof.angle = 0
		roof.color = 0
		roof.miceCollison = true
		roof.groundCollision = false
		roof.dynamic = false
		roof.mass = 0
		roof.linearDamping = 0
		tfm.exec.addPhysicObject(0, 400, -10, roof)
	end

	Tick = 0
	DegreesPerTick = 360 / Ticks
	if tfm.get.room.mirroredMap then
		TickDelta = -1
	else
		TickDelta = 1
	end

end


tfm.exec.newGame()
