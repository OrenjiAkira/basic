
local Vector = require 'basic.vector'

local Rect = require 'basic.prototype' :new {
  0, 0, 0, 0,
  __type = 'rectangle'
}

function Rect:__init ()
  self.pos = Vector:new { self[1], self[2] }
  self.size = Vector:new { self[3], self[4] }
end

function Rect:setPos (x, y)
  self.pos:set(x, y)
end

function Rect:getPos ()
  return self.pos:unpack(1, 2)
end

function Rect:setSize (w, h)
  self.size:set(x, y)
end

function Rect:getSize ()
  return self.size:unpack(1, 2)
end

function Rect:unpack()
  return self:getPos(), self:getSize()
end

function Rect:getMax()
  return self.pos + self.size
end

function Rect:intersect (r)
  local a = { min = self:getPos(), max = self:getMax() }
  local b = { min = r:getPos(), max = r:getMax() }
  if a.min.x > b.max.x or a.min.y > b.max.y or
     b.min.x > a.max.x or b.min.y > a.max.y then
    return false
  end
  return true
end

function Rect:getBorderPoints ()
  local points = {}
  local pos, size = self:getPos(), self:getSize()

  local max_y = math.ceil(size.y)
  for dy = 0, max_y do
    table.insert(points, Vector:new { pos.x,          pos.y + math.min(dy, size.y) })
    table.insert(points, Vector:new { pos.x + size.x, pos.y + math.min(dy, size.y) })
  end

  local max_x = math.ceil(size.x)
  for dx = 1, max_x - 1 do
    table.insert(points, Vector:new { pos.x + math.min(dx, size.x), pos.y })
    table.insert(points, Vector:new { pos.x + math.min(dx, size.x), pos.y + size.y })
  end

  return points
end

return Rect
