
require 'basic.tableutility'
require 'basic.logarithm'

local physics = {}
local modules = require 'basic.pack' 'basic.physics'
local iterate = require 'basic.iterate'
local grid = require 'basic.grid'

local unit
local maps
local bodies
local collisions

function physics.load (params)
  params = params or {}
  maps = {}
  bodies = {}
  unit = params.unit or 32
  collisions = require 'basic.queue' :new { params.collisions or 4096 }
end

function physics.get_unit ()
  -- get unit
  return unit
end

function physics.set_unit (u)
  -- set unit
  unit = u
end

function physics.new_map (width, height)
  -- creates new map
  local map = grid:new { width, height }
  maps[map] = true
  return map
end

function physics.new_map_from_table (t)
  -- creates new map from table
  local map = grid.new_from_table(t)
  maps[map] = true
  return map
end

function physics.remove_map (map)
  maps[map] = false
end

function physics.new_body (map, x, y, w, h, layers, collision_layers)
  -- creates new body
  local body = modules.dynamic_body:new { x, y, w, h }
  body:set_map(map)
  body:set_bodylist(bodies)
  body:set_layers(layers or { 1 })
  body:set_collision_layers(collision_layers or { 1 })
  bodies[body] = true
  return body
end

function physics.remove_body (body)
  -- removes body
  bodies[body] = nil
end

function physics.get_next_collision ()
  -- pops and returns collision from collision queue
  return collisions:dequeue()
end

function physics.update ()
  collisions:clear()
  for body in pairs(bodies) do
    -- resolve movement
    body:resolve_movement()
    -- resolve collisions
    for other in iterate.other(bodies) do
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
