
local _coroutine_resume = coroutine.resume
coroutine.resume = function (...)
  local state,result = _coroutine_resume(...)
  if not state then
    -- Output error message
    error( tostring(result), 2 )
  end
  return state,result
end

