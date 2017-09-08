
require 'basic.tableutility'
require 'basic.logarithm'

local Mover = require 'basic.physics.mover'
local DynamicBody = require 'basic.physics.dynamic_body'
local Grid = require 'basic.grid'
local Queue = require 'basic.queue'

local Physics = {}

local _unit
local _maps
local _bodies
local _collisions

function Physics.load (params)
  params = params or {}
  _maps = {}
  _bodies = {}
  _unit = params.unit or 32
  _collisions = Queue:new { params.max_collisions or 4096 }
  Mover.load(_bodies, _unit, _collisions)
end

function Physics.getUnit ()
  -- get unit
  return _unit
end

function Physics.setUnit (u)
  -- set unit
  _unit = u
end

function Physics.newMap (width, height)
  -- creates new map
  local map = Grid:new { width, height }
  _maps[map] = true
  return map
end

function Physics.newMapFromTable (t)
  -- creates new map from table
  local map = Grid.newFromTable(t)
  _maps[map] = true
  return map
end

function Physics.removeMap (map)
  _maps[map] = nil
end

function Physics.newBody (map, x, y, w, h, layers, collision_layers)
  -- creates new body
  local body = DynamicBody:new { x, y, w, h }
  body:setMap(map)
  body:setLayers(layers or { 1 })
  body:setCollisionLayers(collision_layers or { 1 })
  _bodies[body] = true
  return body
end

function Physics.removeBody (body)
  -- removes body
  _bodies[body] = nil
end

function Physics.getCollisions ()
  -- pops and returns collisions from collision Queue
  local col_list = {}
  while not _collisions:isEmpty() do
    table.insert(col_list, _collisions:pop())
  end
  return col_list
end

function Physics.update ()
  _collisions:clear()
  for body in pairs(_bodies) do
    -- resolve movement
    Mover.resolve(body)
  end
end

return Physics

