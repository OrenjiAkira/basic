
-- logarithm

function math.basen (n, b)
  n = math.floor(n)
  if not b or b == 10 then return tostring(n) end
  local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local t = {}
  local sign = ""
  if n < 0 then
      sign = "-"
  n = -n
  end
  repeat
      local d = (n % b) + 1
      n = math.floor(n / b)
      table.insert(t, 1, digits:sub(d,d))
  until n == 0
  return sign .. table.concat(t,"")
end

function math.logn (n, b)
  return math.log10(basen(n, b), b)
end
