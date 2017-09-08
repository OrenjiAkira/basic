
local CollisionObject = require 'basic.prototype' :new {
  solid = false,
  __type = 'CollisionObject',
}

local MAX_LAYERS = 16

local function _setTableNums (t, l)
  for i = 1, MAX_LAYERS do
    t[i] = false
  end
  for _,i in ipairs(l) do
    if i > 0 and i <= MAX_LAYERS then
      t[i] = true
    end
  end
end

function CollisionObject:__init ()
  self.layers = {}
  self.collision_layers = {}
  self.map = false
  self.bodylist = false
  _setTableNums(self.layers, {})
  _setTableNums(self.collision_layers, {})
end

function CollisionObject:setMap (m)
  self.map = m
end

function CollisionObject:getMap ()
  return self.map
end

function CollisionObject:isSolid ()
  return self.solid
end

function CollisionObject:setSolid (enable)
  self.solid = enable and true or false
end

function CollisionObject:setLayers (l)
  assert(type(l) == "table", "Invalid argument to 'setLayers'. Expected 'table', got " .. type(l))
  _setTableNums(self.layers, l)
end

function CollisionObject:setCollisionLayers (l)
  assert(type(l) == "table", "Invalid argument to 'setCollisionLayers'. Expected 'table', got " .. type(l))
  _setTableNums(self.collision_layers, l)
end

function CollisionObject:collidesWithLayer (n)
  return self.collision_layers[n]
end

function CollisionObject:isInLayer (n)
  return self.layers[n]
end

function CollisionObject:isLayerColliding (other_obj)
  for n = 1, MAX_LAYERS do
    if self:collidesWithLayer(n) and other_obj:isInLayer(n) then
      return true
    end
  end
end

return CollisionObject
