
local vector = require 'basic.vector'
local matrix = require 'basic.prototype' :new {
  { 1, 0, 0 },
  { 0, 1, 0 },
  { 0, 0, 1 },
  __type = 'matrix'
}

function matrix:__init ()
  self[1] = vector:new(self[1])
  self[2] = vector:new(self[2])
  self[3] = vector:new(self[3])
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

function matrix:determinant ()
  return self[1][1] * (self[2][2] * self[3][3] - self[2][3] * self[3][2]) -
         self[1][2] * (self[2][1] * self[3][3] - self[2][3] * self[3][1]) +
         self[1][3] * (self[2][1] * self[3][2] - self[2][2] * self[3][1])
end

function matrix:transpose ()
  return matrix:new {
    { self[1][1], self[2][1], self[3][1] },
    { self[1][2], self[2][2], self[3][2] },
    { self[1][3], self[2][3], self[3][3] },
  }
end

local function matrix_multiplication(a, b)
  return matrix:new {
    {
      a[1][1] * b[1][1] + a[1][2] * b[2][1] + a[1][3] * b[3][1],
      a[1][1] * b[1][2] + a[1][2] * b[2][2] + a[1][3] * b[3][2],
      a[1][1] * b[1][3] + a[1][2] * b[2][3] + a[1][3] * b[3][3],
    },
    {
      a[2][1] * b[1][1] + a[2][2] * b[2][1] + a[2][3] * b[3][1],
      a[2][1] * b[1][2] + a[2][2] * b[2][2] + a[2][3] * b[3][2],
      a[2][1] * b[1][3] + a[2][2] * b[2][3] + a[2][3] * b[3][3],
    },
    {
      a[3][1] * b[1][1] + a[3][2] * b[2][1] + a[3][3] * b[3][1],
      a[3][1] * b[1][2] + a[3][2] * b[2][2] + a[3][3] * b[3][2],
      a[3][1] * b[1][3] + a[3][2] * b[2][3] + a[3][3] * b[3][3],
    },
  }
end

function matrix.__mul (l, r)
  if type(l) == 'number' then
    for i, j, val in matrix.iterate(r) do
      r:set_cell(i, j, val * r)
    end
  elseif type(r) == 'number' then
    for i, j, val in matrix.iterate(l) do
      l:set_cell(i, j, val * r)
    end
  elseif r:get_type() == 'vector' then
    return error("Cannot multiply 3x3 matrix by 1x3 vector. Did you mean to multiply 1x3 vector by 3x3 matrix?")
  else
    return matrix_multiplication(l, r)
  end
end

function matrix:__tostring ()
  return "Matrix {\n" ..
    '  ' .. self[1][1] .. ' ' .. self[1][2] .. ' ' .. self[1][3] .. '\n' ..
    '  ' .. self[2][1] .. ' ' .. self[2][2] .. ' ' .. self[2][3] .. '\n' ..
    '  ' .. self[3][1] .. ' ' .. self[3][2] .. ' ' .. self[3][3] .. '\n}'
end

function matrix:iterate ()
  local init_s = { 1, 0, tbl = self }
  return function(s, value)
    local m = s.tbl

    s[2] = s[2] + 1
    i, j = s[1], s[2]
    value = m[i] and m[i][j]

    if not value then
      s[1] = s[1] + 1
      s[2] = 1
      i, j = s[1], s[2]
      value = m[i] and m[i][j]
    end

    return value and i, j, value
  end,
  init_s,
  0
end

return matrix
