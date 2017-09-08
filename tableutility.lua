
-- unpack
unpack = table.unpack or unpack
table.unpack = unpack or table.unpack

-- pack
table.pack = table.pack or function (...) return {...} end
pack = pack or table.pack

-- find, linear and simple
table.find = table.find or function (t, s)
  for k,v in pairs(t) do
    if v == s then
      return k, s
    end
  end
end


