
local iterate = {}

-- iterator
function iterate.other(t, index)
  return function(s, var)
    var = next(s, var)
    return var, s[var]
  end, t, index
end

-- find
function iterate.find (t, item)
  for k,v in pairs(t) do
    if v == item then return k end
  end
end

return iterate
