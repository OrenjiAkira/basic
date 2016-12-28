
require 'basic.tableutility'
require 'basic.logarithm'

local physics = {}
local modules = require 'basic.pack' 'basic.physics'

local maps = {}
local bodies = {}
local collisions = require 'basic.queue' :new { 4096 }

function physics.new_map (width, height, unit)
  -- creates new map
  local map = modules.map:new { width, height, unit }
  table.insert(maps, map)
  return map
end

function physics.new_map_from_matrix (matrix, unit)
  local map = modules.map:new { #matrix[1], #matrix, unit }
  map:set_from_matrix(matrix)
  return map
end

function physics.remove_map (map)
  -- removes map
  local k = table.find(maps, map)
  table.remove(maps, k)
end

function physics.new_body (map, x, y, w, h, layers, collision_layers)
  -- creates new body
  local body = modules.dynamic_body:new { x, y, w, h }
  body:set_map(map)
  body:set_bodylist(bodies)
  body:set_layers(layers or { 1 })
  body:set_collision_layers(collision_layers or { 1 })
  table.insert(bodies, body)
  return body
end

function physics.remove_body (body)
  -- removes body
  local k = table.find(bodies, body)
  table.remove(bodies, k)
end

function physics.get_next_collision ()
  -- pops and returns collision from collision queue
  return collisions:dequeue()
end

function physics.update ()
  collisions:clear()
  for i = 1, #bodies do
    local body = bodies[i]
    -- resolve movement
    body:resolve_movement()
    -- resolve collisions
    for j = i + 1, #bodies do
      local other = bodies[j]
      if body:intersects_with(other) then
        if body:is_layer_colliding(other) then
          collisions:enqueue { body, other }
        end
        if other:is_layer_colliding(body) then
          collisions:enqueue { other, body }
        end
      end
    end
  end
end

return physics
