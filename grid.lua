
local Grid = require 'basic.prototype' :new {
  3, 3, 0,
  unit = 32,
  __type = 'Grid'
}

local function _fillGrid (t, width, height, fill)
  for x = 1, width do
    t[x] = {}
    for y = 1, height do
      t[x][y] = fill or 0
    end
  end
end

function Grid:_init ()
  self.container = {}
  self:clear()
end

function Grid:setCell (x, y, fill)
  assert(self.container[x], "Invalid x pos: " .. x)
  assert(self.container[x][y], "Invalid y pos: " .. y)
  self.container[x][y] = fill or 0
end

function Grid:getCell (x, y)
  return (self.container[x] or {})[y]
end

function Grid:isOccupied (x, y)
  local cell = self:getCell(x, y)
  return cell and cell ~= 0
end

function Grid:getWidth ()
  return self[1]
end

function Grid:getHeight ()
  return self[2]
end

function Grid:getDimensions ()
  return self[1], self[2]
end

function Grid:getUnit ()
  return self.unit
end

function Grid:setUnit (u)
  self.unit = u
end

function Grid:getBase ()
  return self[3]
end

function Grid:clear ()
  _fillGrid(self.container, self[1], self[2], self[3])
end

function Grid.newFromTable (t)
  local m = Grid:new { #t[1], #t }
  for i in ipairs(t) do
    for j in ipairs(t[i]) do
      m:setCell(j, i, t[i][j])
    end
  end
  return m
end

function Grid.newFromVector (t, w)
  local n = #t
  local h = math.floor(n / w)
  local m = Grid:new { w, h }
  for k = 1, n do
    local x = (k - 1) % w + 1
    local y = math.floor((k - 1) / w) + 1
    m:setCell(x, y, t[k])
  end
  return m
end

function Grid:iterate ()
  local init_s = { 1, 0, tbl = self.container }
  return function(s, value)
    local m = s.tbl

    s[2] = s[2] + 1
    x, y = s[1], s[2]
    value = m[x] and m[x][y]

    if not value then
      s[1] = s[1] + 1
      s[2] = 1
      x, y = s[1], s[2]
      value = m[x] and m[x][y]
    end

    return value and x, y, value
  end,
  init_s,
  0
end

function Grid:__tostring ()
  local s = "\n"
  for x, y, value in self:iterate() do
    s = s .. "[" .. x .. ", " .. y .. "]: " .. value .. "\n"
  end
  s = s .. "\n"
  return s
end

return Grid
