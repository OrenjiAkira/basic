
local matrix = require 'basic.prototype' :new {
  3, 3, 0,
  __type = 'matrix'
}

local function fill_matrix (t, width, height, fill)
  for i = 1, height do
    t[i] = {}
    for j = 1, width do
      t[i][j] = fill or 0
    end
  end
end

function matrix:__init ()
  local width, height, fill = self[1], self[2], self[3]
  fill_matrix(self, width, height, fill)
end

function matrix:set_cell (i, j, fill)
  assert(self[i], "Invalid row: " .. i)
  assert(self[i][j], "Invalid column: " .. j)
  self[i][j] = fill or 0
end

function matrix:get_cell (i, j)
  local dummy = {}
  return (self[i] or dummy)[j]
end

function matrix:get_width ()
  return #self[1]
end

function matrix:get_height ()
  return #self
end

function matrix.iterate (t)
  local init_s = { 1, 0, tbl = t }
  return function(s, var)
    local m = s.tbl

    -- advancing column
    s[2] = s[2] + 1
    i, j = s[1], s[2]
    var = m[i] and m[i][j]

    -- end of column
    if not var then
      -- advancing row, resetting column
      s[1] = s[1] + 1
      s[2] = 1
      i, j = s[1], s[2]
      var = m[i] and m[i][j]
    end

    -- return nil if out of rows; or return i, j, m[i][j]
    return var and i, j, var
  end,
  init_s,
  0
end

function matrix:iteraterows ()
  local t = { 0, m = self }
  return function(s, row)
    local m = s.m
    local i
    s[1] = s[1] + 1
    i = s[1]
    row = m[i]
    return row and i, row
  end,
  t,
  0
end

return matrix
