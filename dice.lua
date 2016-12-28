
local dice = {}

dice.random = math.random

function dice.throw (N, sides)
  local result = 0

  for i = 1, N do
    result = result + dice.random(1, sides)
  end

  return result
end

return dice
