
-- unpack
if unpack and not table.unpack then table.unpack = unpack end

-- pack
if not table.pack then table.pack = function (...) return {...} end end

-- copy (recursive, be careful of self references and metatables)
if not table.copy then
  table.copy = function (t)
    local u = {}
    for k, v in pairs(t) do
      if type(v) == "table" then
        u[k] = table.copy(v)
      else
        u[k] = v
      end
    end
    return u
  end
end

-- find, linear and simple
if not table.find then
  table.find = function (t, s)
    for k,v in pairs(t) do
      if v == s then
        return k, s
      end
    end
  end
end
