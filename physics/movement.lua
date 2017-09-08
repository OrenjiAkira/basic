
local Movement = {}

local _bodylist
local _unit
local _collisions

local function _canItBeThere (rectangle, map)
  -- get points, check points
  local yes = true
  local points = rectangle:getBorderPoints()

  for n = 1, #points do
    local point = points[n]
    local x, y = math.floor(point.x), math.floor(point.y)
    if map:isOccupied(x, y) then
      yes = false
    end
  end

  return yes
end

local function _nobodyInTheWay (body, rectangle)
  local nobody = true
  for other in pairs(_bodylist) do
    if body ~= other then
      if rectangle:intersect(other:getShape()) and body:isLayerColliding(other) then
        _collisions:push { body, other }
        if other:isSolid() then
          nobody = false
        end
      end
    end
  end
  return nobody
end

local function _shouldItMove (body, collision_box)
  -- get map; if no map, error
  local map = body:getMap()
  assert(map, "Body's map is undefined. Create a map and set the body to it first.")

  return _canItBeThere(collision_box, map) and _nobodyInTheWay(body, collision_box)
end

local function _isMoveable (body, movement)
  -- get rectangle for new position
  local collision_box = body:getShape()
  collision_box.pos:add(movement)

  return _shouldItMove (body, collision_box)
end

local function _moveAsCloseAsPossible (body, movement)
  local tries = math.ceil(logn(_unit, 2))
  local collision_box = body:getShape()

  for n = 1, tries do
    movement:mul(1 / 2 ^ n)
    local npos = body:getPos() + movement
    collision_box:setPos(npos:unpack())
    if _shouldItMove(body, collision_box) then
      body:actualizeMovement(movement)
    end
  end
end

local function _slide (body, movement)
  local x_move = movement:xcomp()
  local y_move = movement:ycomp()
  _moveAsCloseAsPossible (body, x_move)
  _moveAsCloseAsPossible (body, y_move)
end

function movement.load (list_of_bodies, tile_size, collision_queue)
  _bodylist = list_of_bodies
  _collisions = collision_queue
  _unit = tile_size
end

function movement.resolve (body)
  local movement = body:getMovement()

  -- if no movement, return
  if movement:sqrlen() == 0 then return end

  -- check if nothing is in the way
  if _isMoveable(body, movement) then
    -- nothing in the way; move, you little shit
    body:actualizeMovement(movement)
  else
    -- if something is in the way, move as close to it as possible
    _moveAsCloseAsPossible(body, movement)
    -- update movement
    movement = body:getMovement()
    -- if movement is not finished, slide
    _slide(body, movement)
  end

  -- finally, reset movement
  body:resetMovement()
end

return movement
