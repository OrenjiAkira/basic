
local Vector = require 'basic.vector'
local Rect = require 'basic.rectangle'

local DynamicBody = require 'basic.physics.collision_object' :new {
  0, 0, 0, 0,
  __type = 'DynamicBody',
}

function DynamicBody:__init ()
  self.shape = Rect:new {
    self[1], self[2], self[3], self[4]
  }
  self.pos = self.shape.pos -- i want the pointer to be the same
  self.movement = Vector:new {}
end

function DynamicBody:getShape ()
  return Rect:new { self.shape:unpack() }
end

function DynamicBody:actualizeMovement (v)
  self.pos:add(v)
  self.movement:sub(v)
end

function DynamicBody:resetMovement ()
  self.movement:set()
end

function DynamicBody:move (v)
  self.movement:add(v)
end

function DynamicBody:getMovement ()
  return self.movement * 1
end

function DynamicBody:intersectsWith (body)
  return self:getShape():intersect(body:getShape())
end

function DynamicBody:setPos (x, y)
  self.pos:set(x, y)
end

function DynamicBody:getPos ()
  return self.pos:unpack(1, 2)
end

function DynamicBody:getCenter ()
  return self.pos + self.shape:getSize() / 2
end

return DynamicBody
