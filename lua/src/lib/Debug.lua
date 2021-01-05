#pragma once

#ifndef DEBUG
function DEBUG(fmt, ...)
	print("DEBUG: " .. string.format(fmt, ...))
end
#endif

