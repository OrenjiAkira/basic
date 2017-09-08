
local Stack = require 'basic.prototype' :new {
  __type = 'Stack'
}

function Stack:__init ()
  self.list = {}
  self.head = 0
end

function Stack:push (item)
  self.head = self.head + 1
  self.list[self.head] = item
end

function Stack:pop ()
  local item = self.list[self.head]
  self.list[self.head] = nil
  self.head = self.head - 1
  return item
end

function Stack:isEmpty ()
  return self.head == 0
end

function Stack:getHead ()
  return self.list[self.head]
end

return Stack

