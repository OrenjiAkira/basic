
local unique = require 'basic.prototype':new {
  nextID = 0
  __type = 'unique'
}

local FMT = "#%d"

function unique:generate ()
  self.nextID = self.nextID + 1
  return string.format(FMT, self.nextID)
end

return unique:new {}
