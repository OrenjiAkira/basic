
local collision_object = require 'basic.prototype' :new {
  solid = false,
  __type = 'collision_object',
}

local MAX_LAYERS = 16

local function set_table_nums (t, l)
  for i = 1, MAX_LAYERS do
    t[i] = false
  end
  for _,i in ipairs(l) do
    if i > 0 and i <= MAX_LAYERS then
      t[i] = true
    end
  end
end

function collision_object:__init ()
  self.layers = {}
  self.collision_layers = {}
  self.map = false
  self.bodylist = false
  set_table_nums(self.layers, {})
  set_table_nums(self.collision_layers, {})
end

function collision_object:set_map (m)
  self.map = m
end

function collision_object:get_map ()
  return self.map
end

function collision_object:set_bodylist (b)
  self.bodylist = b
end

function collision_object:get_bodylist ()
  return self.bodylist
end

function collision_object:is_solid ()
  return self.solid
end

function collision_object:set_solid (enable)
  self.solid = enable and true or false
end

function collision_object:set_layers (l)
  assert(type(l) == "table", "Invalid argument to 'set_layers'. Expected 'table', got " .. type(l))
  set_table_nums(self.layers, l)
end

function collision_object:set_collision_layers (l)
  assert(type(l) == "table", "Invalid argument to 'set_collision_layers'. Expected 'table', got " .. type(l))
  set_table_nums(self.collision_layers, l)
end

function collision_object:collides_with_layer (n)
  return self.collision_layers[n]
end

function collision_object:is_in_layer (n)
  return self.layers[n]
end

function collision_object:is_layer_colliding (other_obj)
  for n = 1, MAX_LAYERS do
    if self:collides_with_layer(n) and other_obj:is_in_layer(n) then
      return true
    end
  end
end

return collision_object
