#include "lib/Debug.lua"
#include "lib/Commands.lua"
#include "lib/Admin.lua"

ADMINS = "Sharpiepoops#0020"
Ticks  = 15
Radius = 10


Tick           = 0
TickDelta      = 0
DegreesPerTick = 360 / Ticks


AdminCommands = {}
AdminCommands._auth = Admin.isAdmin
AdminCommands.TICKS = nil


function eventLoop(t,r)

	local ad = Tick * DegreesPerTick
	local ar = math.rad(ad)
	local x = Radius * math.sin(ar)
	local y = Radius * math.cos(ar)

	DEBUG("%02d [%.2f,%.2f]", ad, x, y)

	tfm.exec.setWorldGravity(x, y)
	tfm.exec.addShamanObject(0, 400 + x * 10, 220 + y * 10, (180 - ad) - 180, 0, 0, false)

	Tick = Tick + TickDelta
end

function eventNewGame()

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

	Tick = 0
	if tfm.get.room.mirroredMap then
		TickDelta = -1
	else
		TickDelta = 1
	end

end
