
local _resume = coroutine.resume
coroutine.resume = function(...)
  return assert(_resume(...))
end


