
local Queue = require 'basic.prototype' :new {
  256, -- basic size
  __type = 'Queue'
}


function Queue:__init ()

  -- queue attributes (intern use only, please, unless you REALLY know what you're doing)
  self.list = {}
  self.head = 1
  self.tail = 1
  self.size = 0
  self.max = self[1]

  self:clear()
end

function Queue:clear ()
  -- allocating all of the queue in the same space for performance
  for i = 1, self.max do self.list[i] = false end
  self.tail = self.head
  self.size = 0
end

function Queue:first()
  return self.list[self.head]
end

function Queue:isEmpty()
  return self.size == 0
end

function Queue:isFull()
  return self.size == self.max
end

function Queue:push(item)
  assert(not self:isFull(),
    ("Queue overflow. (Max size is %d)"):format(self.max))
  self.list[self.tail] = item
  self.tail = self.tail % self.max + 1
  self.size = self.size + 1
end

function Queue:pop()
  assert(not self:isEmpty(),
    "Cannot pop empty queue.")
  local item = self.list[self.head]
  self.list[self.head] = false
  self.head = self.head % self.max + 1
  self.size = self.size - 1
  return item
end

function Queue:__tostring ()
  local s = ("Queue: SIZE %d, NEXT %s"):format(self.size, self:first())
  return s
end

return Queue

