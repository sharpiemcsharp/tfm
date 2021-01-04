#pragma once

#include "Debug.lua"

Input = {}

Input.SPACE = 32
Input.LEFT  = 37
Input.RIGHT = 39
Input.UP    = 38
Input.DOWN  = 40

for ii = 65,65+25,1 do
	DEBUG("Input: key:" .. ii .. " " .. string.char(ii))
	Input[string.char(ii)] = ii
end

Input._bind = function(p,k,d,y)
	if type(k)=="table" then
		for _,kk in pairs(k) do
			tfm.exec.bindKeyboard(p,kk,d,y)
			DEBUG("Input:" .. p .. " k:" .. kk)
		end
	else
		tfm.exec.bindKeyboard(p,k,d,y)
		print("Input" .. p .. " k:" .. k)
	end
end

Input._bind_unbind_common = function(p,k,d,y)
	if p and #p>2 then
		Input._bind(p,k,d,y)
	else
		local o = p
		for p,pi in pairs(tfm.get.room.playerList) do
			local bind = true
			if p then
				if o == "S" and pi.isShaman==false then
					-- Sham only requested
					bind = false
				elseif o == "M" and pi.isShaman==true then
					-- Mice only requested
					bind = false
				end
			end
			if bind then
				Input._bind(p,k,d,y)
			end
		end
	end
end

Input.bind = function(p,k,u)
	local d = (u==nil)
	print("bind: d:"..tostring(d))
	Input._bind_unbind_common(p,k,d,true)
end

Input.unbind = function(p,k,u)
	local d = (u==nil)
	Input._bind_unbind_common(p,k,d,false)
end

Input.bind_movement = function(p,u)
	-- left
	local k = {Input.LEFT, Input.RIGHT, Input.UP, Input.DOWN, Input.A, Input.D, Input.W, Input.S, Input.Q, Input.Z }
	Input.bind(p,k,u)
end

Input.left = function(k)
	return (k and (k==Input.LEFT or k==Input.A or k==Input.Q))
end

Input.right = function(k)
	return (k and (k==Input.RIGHT or k==Input.D))
end

Input.up = function(k)
	return (k and (k==Input.UP or k==Input.W or k==Input.Z))
end

Input.down = function(k)
	return (k and (k==Input.DOWN or k==Input.S))
end

