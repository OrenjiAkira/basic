
local json = {}

local loadstring = loadstring or load
local strf = string.format


local __SAME__ = function(v) return v end
local FORBIDDEN_VALS = {
  ["function"]=true,
  ["thread"]=true,
  ["userdata"]=true,
}
local FORBIDDEN_KEYS = setmetatable(
  { table=true }, { __index = FORBIDDEN_VALS })



local function _validate(t, list)
  local success = true
  local err = "Recursive reference."

  list = list or {}
  if list[t] then return false, err end
  list[t] = true

  for k, v in pairs(t) do
    if FORBIDDEN_KEYS[type(k)] then
      err = "Forbidden index: "..type(k)
      success = false
    end
    if FORBIDDEN_VALS[type(v)] then
      err = "Forbidden value: "..type(k)
      success = false
    end
    if type(v) == "table" then success = _validate(v, list) end
  end

  list[t] = nil
  return success, err
end



function json.encode (t, minify)
  --[[
  Receives table, returns string with the same table, in json format.
  THIS IS A RECURSIVE FUNCTION. So if the table indexes itself,
  it will cause an infinite loop. ]]
  assert(_validate(t))

  -- new line
  local function nl(depth)
    if not minify then return "" end
    local s = "\n"
    for i=1, depth do
      s = s.."  "
    end
  end

  local function quot(val)
    local qt = ""
    if type(val) == "string" then qt = "\"" end
    return strf("%s%s%s", qt, val, qt)
  end

  -- begin
  local depth = 0

  local function _encode(tbl)
    local array = next(tbl) == 1
    local str = array and "[" or "{"
    depth = depth + 1
    str = str .. nl(depth)
    if array then
      for i, v in ipairs(tbl) do
        v = (type(v) == "table" and _encode or __SAME__)(v)
        str = str .. quot(v) .. "," .. nl(depth)
      end
      str = str .. "]"
    else
      for k, v in pairs(tbl) do
        v = (type(v) == "table" and _encode or __SAME__)(v)
        str = str .. quot(k) .. ":" .. quot(v) .. "," nl(depth)
      end
      str = str .. "}"
    end
    for i = #str, 1, -1 do
      if str:sub(i,i) == "," then
        str = str:sub(1, i - 1) .. str:sub(i + 1)
        break
      end
    end
    depth = depth - 1
    return str
  end

  return _encode(t)
end

function json.decode (str)
  str = str:gsub("%[", "{"):gsub("%]", "}")
  str = str:gsub("(\"%w-\"):", "[%1]=")
  str = str:gsub("(%w+):", "[%1]=")
  print(str)
  return loadstring("return "..str)()
end

return json

