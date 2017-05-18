
local movement = {}
local bodylist
local unit

local function can_it_be_there (rectangle, map)
  -- get points, check points
  local yes = true
  local points = rectangle:get_border_points()

  for n = 1, #points do
    local point = points[n]
    local x, y = math.floor(point.x), math.floor(point.y)
    if map:is_occupied(x, y) then
      yes = false
    end
  end

  return yes
end

local function nobody_in_the_way (body, rectangle)
  local nobody = true
  for other in pairs(bodylist) do
    if body ~= other then
      if rectangle:intersect(other:get_shape()) and body:is_layer_colliding(other) and other:is_solid() then
        nobody = false
      end
    end
  end
  return nobody
end

local function should_it_move (body, collision_box)
  -- get map; if no map, error
  local map = body:get_map()
  assert(map, "Body's map is undefined. Create a map and set the body to it first.")

  return can_it_be_there(collision_box, map) and nobody_in_the_way(body, collision_box)
end

local function is_moveable (body, movement)
  -- get rectangle for new position
  local collision_box = body:get_shape()
  collision_box.pos:add(movement)

  return should_it_move (body, collision_box)
end

local function move_as_close_as_possible (body, movement)
  local tries = math.ceil(logn(unit, 2))
  local collision_box = body:get_shape()

  for n = 1, tries do
    movement:mul(1 / 2 ^ n)
    local npos = body:get_pos() + movement
    collision_box:set_pos(npos:unpack())
    if should_it_move(body, collision_box) then
      body:actualize_movement(movement)
    end
  end
end

local function slide (body, movement)
  local x_move = movement:xcomp()
  local y_move = movement:ycomp()

  local x_box = body:get_shape()
  local y_box = body:get_shape()
  x_box.pos:add(x_move)
  y_box.pos:add(y_move)

  if should_it_move(body, x_box) then
    body:actualize_movement(x_move)
  end

  if should_it_move(body, y_box) then
    body:actualize_movement(y_move)
  end
end

function movement.load (list_of_bodies, box_size)
  bodylist = list_of_bodies
  unit = box_size
end

function movement.resolve (body)
  local movement = body:get_movement()

  -- if no movement, return
  if movement:sqrlen() == 0 then return end

  -- check if nothing is in the way
  if is_moveable(body, movement) then
    -- nothing in the way; move, you little shit
    body:actualize_movement(movement)
  else
    -- if something is in the way, move as close to it as possible
    move_as_close_as_possible(body, movement)
    -- update movement
    movement = body:get_movement()
    -- if movement is not finished, slide
    slide(body, movement)
  end

  -- finally, reset movement
  body:reset_movement()
end

return movement
