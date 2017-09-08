
local iterate = {}

-- iterator
function iterate.other(t, index)
  return function(s, var)
    var = next(s, var)
    return var, s[var]
  end, t, index
end

return iterate

