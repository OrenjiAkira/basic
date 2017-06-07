
-- individual timer
local timer = require 'basic.prototype' :new {
  target = 1,
  loop = 1,
  handle_frame = function (dt) end,
  handle_period = function () end,
  __type = 'timer'
}

local timeunit = 1

function timer:__init ()
  self.target = self.target * timeunit
  self.update = coroutine.create(self.routine)
end

function timer:routine (dt)
  while self.loop > 0 or self.loop == -1 do
    local count = 0
    while count < self.target do
      self.handle_frame(dt)
      count = count + dt * timeunit
      self, dt = coroutine.yield()
    end
    self.handle_period()
    self.loop = self.loop == -1 and -1 or self.loop -1
  end
end

-- timer manager
local timer_manager = require 'basic.prototype' :new {
  __type = 'timer_manager'
}

function timer_manager:__init ()
  self.timers = {}
end

function timer_manager:clear ()
  for id in pairs(self.timers) do
    self.timers[id] = nil
  end
end

function timer_manager:cancel (t)
  assert(t, "TimerManager method 'cancel' must receive timer handle as argument.")
  self.timers[t] = nil
end

function timer_manager:update (dt)
  for t in pairs(self.timers) do
    local unfinished, status = coroutine.resume(t.update, t, dt)
    --if status then print(status) end
    if not unfinished then
      self.timers[t] = nil
    end
  end
end

function timer_manager:after (s, func)
  assert(s > 0, "Must give a positive time in seconds as first argument.")
  assert(type(func)=='function', "Must give a valid function as second argument.")
  local t = timer:new {
    target = s,
    handle_period = func,
  }
  self.timers[t] = t
  return t
end

function timer_manager:every (s, func, times)
  assert(s > 0, "Must give a positive time in seconds as first argument.")
  assert(type(func)=='function', "Must give a valid function as second argument.")
  local t = timer:new {
    target = s,
    handle_period = func,
    loop = times or -1,
  }
  self.timers[t] = t
  return t
end

function timer_manager:during (s, func_during, func_after)
  assert(s > 0, "Must give a positive time in seconds as first argument.")
  assert(type(func_during)=='function', "Must give a valid function as second argument.")
  local t = timer:new {
    target = s,
    handle_frame = func_during,
    handle_period = func_after or function () end,
  }
  self.timers[t] = t
  return t
end

return timer_manager:new {}

