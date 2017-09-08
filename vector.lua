
local sqrt  = math.sqrt
local floor = math.floor
local acos  = math.acos

local Vector = require 'basic.prototype' :new {
  0, 0, 0,
  __type = 'Vector'
}

function Vector:__index (k)
  if k == 'x' or k == 'j' then return self[1] end
  if k == 'y' or k == 'i' then return self[2] end
  if k == 'z' then return self[3] end
  return Vector[k]
end

function Vector:__newindex (k, v)
  if     k == 'x' or k == 'j' then rawset(self, 1, v)
  elseif k == 'y' or k == 'i' then rawset(self, 2, v)
  elseif k == 'z' then rawset(self, 3, v)
  else rawset(self, k, v) end
end

function Vector.__add (l, r)
  return Vector:new{
    l[1] + r[1],
    l[2] + r[2],
    l[3] + r[3]
  }
end

function Vector.__sub (l, r)
  return Vector:new{
    l[1] - r[1],
    l[2] - r[2],
    l[3] - r[3]
  }
end

function Vector:__eq (v)
  return self[1] == v[1] and self[2] == v[2] and self[3] == v[3]
end

local function _multByNumber (v, f)
  return Vector:new{
    f * v[1],
    f * v[2],
    f * v[3]
  }
end

local function _dotProduct (v1, v2)
  return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end

function Vector.__mul (l, r)
  if type(l) == 'number' then
    return _multByNumber(r, l)
  elseif type(r) == 'number' then
    return _multByNumber(l, r)
  elseif r:getType() == 'matrix' then
    return Vector:new {
      l[1] * r[1][1] + l[2] * r[1][2] + l[3] * r[1][3],
      l[1] * r[2][1] + l[2] * r[2][2] + l[3] * r[2][3],
      l[1] * r[3][1] + l[2] * r[3][2] + l[3] * r[3][3]
    }
  else
    return _dotProduct(l, r)
  end
end

function Vector.__pow (l, r)
  return -Vector:new {
    l[2] * r[3] - l[3] * r[2],
    l[3] * r[1] - l[1] * r[3],
    l[1] * r[2] - l[2] * r[1]
  }
end

function Vector.__div (l, r)
  if type(r) == 'number' then
    return _multByNumber(l, 1.0/r)
  else
    return error(("Can't divide %s by %s"):format(type(l), type(r)))
  end
end

function Vector:__unm ()
  return self * -1
end

function Vector:__tostring ()
  local s = "Vector: { "
  s = s .. self[1] .. ", "
  s = s .. self[2] .. ", "
  s = s .. self[3] .. " }"
  return s
end

function Vector:set (x, y, z)
  self[1] = x or 0
  self[2] = y or 0
  self[3] = z or 0
end

function Vector:unpack (i, j)
  i = i or 1
  j = j or 3
  if i == j then return self[i] end
  return self[i], self:unpack(i+1, j)
end

function Vector:dot(u)
  return self * (u or self)
end

function Vector:size()
  return sqrt(self:dot())
end

function Vector:normalized ()
  return self/self:size()
end

function Vector:normalize ()
  self:mul(1/self:size())
end

function Vector:add (v)
  self[1] = self[1] + v[1]
  self[2] = self[2] + v[2]
  self[3] = self[3] + v[3]
end

function Vector:sub (v)
  self[1] = self[1] - v[1]
  self[2] = self[2] - v[2]
  self[3] = self[3] - v[3]
end

function Vector:mul (f)
  self[1] = self[1] * f
  self[2] = self[2] * f
  self[3] = self[3] * f
end

function Vector:floor()
  self[1] = floor(self[1])
  self[2] = floor(self[2])
  self[3] = floor(self[3])
end

function Vector.angle (v, u)
  return acos( (v * u) / (v:size() * u:size()) )
end

function Vector:xcomp ()
  return Vector:new { self[1], 0, 0 }
end

function Vector:ycomp ()
  return Vector:new { 0, self[2], 0 }
end

function Vector:zcomp ()
  return Vector:new { 0, 0, self[3] }
end

function Vector:comps ()
  return self:xcomp(), self:ycomp(), self:zcomp()
end

return Vector
