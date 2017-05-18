
local vector = require 'basic.vector'
local rect = require 'basic.rectangle'
local unit = require 'basic.physics' .get_unit

local dynamic_body = require 'basic.physics.collision_object' :new {
  0, 0, 0, 0,
  __type = 'dynamic_body',
}

function dynamic_body:__init ()
  self.shape = rect:new {
    self[1], self[2], self[3], self[4]
  }
  self.pos = self.shape.pos -- i want the pointer to be the same
  self.movement = require 'basic.vector' :new {}
end

function dynamic_body:get_shape ()
  return self.shape:clone()
end

function dynamic_body:actualize_movement (v)
  self.pos:add(v)
  self.movement:sub(v)
end

function dynamic_body:reset_movement ()
  self.movement:set()
end

function dynamic_body:move (v)
  self.movement:add(v)
end

function dynamic_body:get_movement ()
  return self.movement * 1
end

function dynamic_body:intersects_with (body)
  return self:get_shape():intersect(body:get_shape())
end

function dynamic_body:set_pos (x, y)
  self.pos:set(x, y)
end

function dynamic_body:get_pos ()
  return self.pos * 1
end

function dynamic_body:get_center ()
  return self.pos + self.shape:get_size() / 2
end

return dynamic_body
