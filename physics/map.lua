
local matrix = require 'basic.matrix'

local map = require 'basic.prototype' :new {
  16, 10, 32,
  __type = 'map'
}

function map:__init ()
  local w, h = self[1], self[2]
  self.grid = matrix:new { w, h, false }
  for i, j in self.grid:iterate() do
    self.grid:set_cell(i, j, 0)
  end
  self.unit = self[3]
end

function map:get_unit ()
  return self.unit
end

function map:get_grid ()
  return self.grid
end

function map:occupy (x, y)
  self.grid:set_cell(y, x, 1)
end

function map:unoccupy (x, y)
  self.grid:set_cell(y, x, 0)
end

function map:is_occupied (x, y)
  return self.grid:get_cell(y, x) == 1
end

function map:get_width ()
  return self:get_grid():get_width()
end

function map:get_height ()
  return self:get_grid():get_height()
end

function map:get_dimensions ()
  return self:get_width(), self:get_height()
end

function map:set_from_matrix (m)
  for i, j, u in matrix.iterate(m) do
    if u == 0 then
      self.grid:set_cell(i, j, u)
    else
      self.grid:set_cell(i, j, 1)
    end
  end
end

return map
