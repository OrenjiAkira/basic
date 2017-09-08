
local IDGen = require 'basic.prototype':new {
  lastID = 0,
  __type = 'IDGen'
}

local FMT = "#%d"
local BASE = 1000

function IDGen:getLastID()
  return self.lastID
end

function IDGen:generate ()
  local nextID = self.lastID + 1
  self.lastID = nextID
  return FMT:format(BASE + nextID)
end

return IDGen:new {}
