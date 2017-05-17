
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
  return self.shape
end

function dynamic_body:move (v)
  self.pos:add(v)
  self.movement:sub(v)
end

function dynamic_body:get_movement ()
  return self.movement * 1
end

function dynamic_body:resolve_movement ()
  -- if no movement, return
  if self.movement:sqrlen() == 0 then return end

  if self:moveable() then
    -- if nothing is in the way, move
    self:move(self.movement)
  else
    -- if something is in the way, move as close to it as possible
    self:move_as_close_as_possible()
    self:slide()
  end

  -- finally, reset movement
  self.movement:set()
end

local function can_it_be_there (rectangle, map)
  -- get points, check points
  local moveable = true
  local points = rectangle:get_border_points()

  for n = 1, #points do
    local point = points[n]
    local x, y = math.floor(point.x), math.floor(point.y)
    if map:is_occupied(x, y) then
      moveable = false
    end
  end

  return moveable
end

local function nobody_in_the_way (body, rectangle, bodylist)
  local nobody = true
  for i = 1, #bodylist do
    local other = bodylist[i]
    if body ~= other then
      if rectangle:intersect(other:get_shape()) and body:is_layer_colliding(other) and other:is_solid() then
        nobody = false
      end
    end
  end
  return nobody
end

function dynamic_body:moveable ()
  -- if no map, error
  local map = self:get_map()
  assert(map, "Body's map is undefined. Create a map and set the body to it first.")

  -- get bodylist
  local bodylist = self:get_bodylist()

  -- get rectangle for new position
  local pos, size = self:get_pos(), self:get_shape():get_size()
  pos:add(self.movement)
  local my_collision_box = rect:new { pos.x, pos.y, size.x, size.y }

  return can_it_be_there(my_collision_box, map) and nobody_in_the_way(self, my_collision_box, bodylist)
end

function dynamic_body:move_as_close_as_possible ()
  local map = self:get_map()
  local bodylist = self:get_bodylist()
  local movement = self:get_movement()
  local tries = math.ceil(logn(unit(), 2))
  local pos, size = self:get_pos(), self:get_shape():get_size()
  local newrect = rect:new { pos.x, pos.y, size.x, size.y }

  for n = 1, tries do
    movement:mul(1 / 2 ^ n)
    local npos = self:get_pos() + movement
    newrect:set_pos(npos:unpack())
    if can_it_be_there(newrect, map) and nobody_in_the_way(self, newrect, bodylist) then
      self:move(movement)
    end
  end
end

function dynamic_body:slide ()
  local map = self:get_map()
  local bodylist = self:get_bodylist()
  local pos, size = self:get_pos(), self:get_shape():get_size()

  local horizontal = vector:new { self:get_movement().x, 0 }
  local vertical = vector:new { 0, self:get_movement().y }

  local hor_rect = rect:new { pos.x + horizontal.x, pos.y + horizontal.y, size.x, size.y }
  local ver_rect = rect:new { pos.x + vertical.x,   pos.y + vertical.y,   size.x, size.y }

  if can_it_be_there(hor_rect, map) and nobody_in_the_way(self, hor_rect, bodylist) then
    self:move(horizontal)
  end

  if can_it_be_there(ver_rect, map) and nobody_in_the_way(self, ver_rect, bodylist) then
    self:move(vertical)
  end
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
