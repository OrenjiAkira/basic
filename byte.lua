
-- MODULES --
local Byte = {}
local _transform = {}
local _translate = {}


-- HELPERS --
local strf   = string.format
local toByte = string.byte
local toChar = string.char
local unpack = table.unpack or unpack -- lua v5.2+ compatibility
local __identity__ = function(...) return ... end

-- ENUMS --
local TYPE_NAME = {
  [0] = "boolean",
  [1] = "integer",
  [2] = "fixed_point",
  [4] = "string",
  [8] = "table",
}

local TYPE_VALUE = {
  boolean     = 0,
  integer     = 1,
  fixed_point = 2,
  string      = 4,
  table       = 8,
}

local TYPE_SIZE = {
  boolean     = 1,
  integer     = 4,
  fixed_point = 4,
}

local TYPE_FORBIDDEN = {
  ["function"] = true,
  ["userdata"] = true,
  ["thread"] = true,
}


-- TYPE GETTERS --
local _getTypeChar
local _getTypeName

function _getTypeChar(val)
  --> number

  -- gets value's type value
  local type_name = type(val)
  local type_value = TYPE_VALUE[type_name]

  if not type_value then
    -- assume it's a number
    if math.floor(val) == val then type_name = "integer"
    else type_name = "fixed_point" end
    type_value = TYPE_VALUE[type_name]
  end

  return _transform.to_boolean(type_value)
end

function _getTypeName(type_integer)
  --> string
  -- gets type value name
  return TYPE_NAME[_translate.from_integer(type_integer)]
end





-- HEX TRANSFORMATIONS --
local _fromHexToNumber
local _fromHexToString
local _fromStringToHex

function _fromHexToNumber(hex)
  -- translate hexcode to number
  return tonumber("0x" .. hex)
end

function _fromHexToString(hex)
  -- translate hexcode to string
  local n = #hex
  local stream = ""
  for i = 1, n, 2 do
    local byte = _fromHexToNumber(hex:sub(i, i+1))
    stream = stream .. toChar(byte)
  end
  return stream
end

function _fromStringToHex(stream)
  -- translate string to hexcode
  local n = #stream
  local hex = ""
  for i = 1, n do
    local byte = toByte(stream, i)
    hex = hex .. strf("%02x", byte)
  end
  return hex
end


-- TRANSFORMATIONS --

function _transform.to_boolean(n)
  -- write unsigned char (1 byte)
  local bits = 8 * TYPE_SIZE.boolean
  if tonumber(n) then
    assert(n < 2 ^ bits, "Char overflow")
    assert(n >= 0, "Char underflow")
  else
    n = n and 1 or 0
  end
  local hex = strf("%02x", n)
  return _fromHexToString(hex)
end

function _transform.to_integer(n)
  -- write signed int (4 bytes)
  local bits = 8 * TYPE_SIZE.integer
  local max = 2 ^ (bits - 1)
  assert(n < max, "Integer overflow")
  assert(n >= -max, "Integer underflow")

  -- dealing with negatives
  n = n >= 0 and n or n + 2^bits
  local hex = strf("%0"..(TYPE_SIZE.integer*2).."x", n)
  return _fromHexToString(hex)
end

function _transform.to_fixed_point(n)
  -- write signed float (4 bytes)
  local bits = 8 * TYPE_SIZE.fixed_point
  local max = 2 ^ (bits/2 - 1)
  assert(n  <  2 ^ (bits/2 - 1), "Integer overflow")
  assert(n >= -2 ^ (bits/2 - 1), "Integer underflow")

  -- dealing with negatives
  n = n >= 0 and n or n + 2^(bits/2)
  -- shift left half the bit length
  n = math.floor(n * 2.0^(bits/2) + .5)

  local hex = strf("%0"..(TYPE_SIZE.fixed_point*2).."x", n)
  return _fromHexToString(hex)
end

_transform.to_string = __identity__


-- TRANSLATIONS --

function _translate.from_boolean(b)
  -- read unsigned char (1 byte)
  local hex = _fromStringToHex(b)
  local n = _fromHexToNumber(hex)
  return n ~= 0
end

function _translate.from_integer(b)
  -- read signed int
  local bits = 8 * TYPE_SIZE.integer
  local hex = _fromStringToHex(b)
  local n = _fromHexToNumber(hex)

  -- deal with negatives
  n = n < 2^(bits-1) and n or n - 2^bits

  return n
end

function _translate.from_fixed_point(b)
  -- read signed fixed_point
  local bits = 8 * TYPE_SIZE.fixed_point
  local hex = _fromStringToHex(b)
  local n = _fromHexToNumber(hex)

  -- shift right half the bit length
  n = n / 2.0^(bits/2)
  -- deal with negatives
  n = n < 2^(bits/2-1) and n or n - 2^(bits/2)

  return n
end

_translate.from_string = __identity__


-- VALIDATIONS --

-- check if table is serializeable
local function _isValidForSerialization(t, list)
  local success = true
  local err = "Found reference recursion, cannot serialize."
  list = list or {}

  -- manage table list for protection against infinite recursion
  if list[t] then return false, err end
  list[t] = true

  -- verify table fields
  for key, value in pairs(t) do
    local ktype, vtype = type(key), type(value)

    -- verify for forbidden types
    if TYPE_FORBIDDEN[ktype] then
      success = false
      err = strf("Forbidden type on table index: %s", ktype)
    end
    if TYPE_FORBIDDEN[vtype] then
      success = false
      err = strf("Forbidden type on table value: %s", vtype)
    end

    -- verify nested tables recursively
    if ktype == "table" then
      success = _isValidForSerialization(key, list)
    end
    if vtype == "table" then
      success = _isValidForSerialization(value, list)
    end
  end

  list[t] = nil
  -- return success or failure
  return success
end


-- LOCAL WRITE/READ METHODS -- 
local _serialize
local _deserialize

-- SERIALIZE --
function _serialize(value)
  local t = _getTypeChar(value)
  local type_name = _getTypeName(t)
  -- if table, call recursively
  if type_name == "table" then return Byte.serialize(value) end

  -- else, carry on as normal
  local length = TYPE_SIZE[type_name] or #value
  local s = _transform.to_integer(length)
  local content = _transform["to_"..type_name](value)

  return t..s..content, length
end

function Byte.serialize(tbl)
  assert(_isValidForSerialization(tbl))

  local content = ""
  local type_value = _getTypeChar(tbl)
  local length = 0

  for key, val in pairs(tbl) do
    local k, ksize = _serialize(key)
    local b, vsize = _serialize(val)
    length = length + 5 + ksize + 5 + vsize
    content = content .. k .. b
  end

  local size_int = _transform.to_integer(length)
  return type_value..size_int..content, length
end

-- DESERIALIZE --
function _deserialize(str)
  local type_name = _getTypeName(str:sub(1,1))
  -- if table, call recursively
  if type_name == "table" then return Byte.deserialize(str) end

  -- carry on
  local tail = 2 + TYPE_SIZE.integer
  local length = _translate.from_integer(str:sub(2, tail - 1))
  local value = _translate["from_"..type_name](str:sub(tail, tail + length - 1))

  return value, length
end

function Byte.deserialize(str)
  local type_name = _getTypeName(str:sub(1,1))
  assert(type_name == "table", "Invalid data to deserialize")
  local tbl = {}
  local tail = 2 + TYPE_SIZE.integer
  local length = _translate.from_integer(str:sub(2, tail - 1))

  while tail < length do
    local key, ksize = _deserialize(str:sub(tail))
    tail = tail + 5 + ksize
    local val, vsize = _deserialize(str:sub(tail))
    tail = tail + 5 + vsize
    tbl[key] = val
    print(key, val)
  end

  return tbl, length
end

return Byte

