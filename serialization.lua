
-- serialization important values
local forbidden = {
  ["function"] = true,
  ["thread"] = true,
  ["userdata"] = true,
}

-- string functions
local get_char = string.char
local get_byte = string.byte
local strf = string.format

-- translate hexcode to number
local function hex_num (hex)
  return tonumber("0x" .. hex)
end

-- translate hexcode to bytecode
local function hex_to_bytes (hex)
  local n = #hex
  local stream = ""
  for i = 1, n, 2 do
    local byte = hex_num(hex:sub(i, i+1))
    stream = stream .. get_char(byte)
  end
  return stream
end

-- translate bytecode to hexcode
local function bytes_to_hex (stream)
  local n = #stream
  local hex = ""
  for i = 1, n do
    local byte = get_byte(stream, i)
    hex = hex .. strf("%02x", byte)
  end
  return hex
end

-- unsigned char (1 byte)
local function byte_char (n)
  assert(math.abs(n) < 2^8, "Char overflow")
  n = n >= 0 and n or n + 2^8
  local hex = strf("%02x", n)
  -- print("0x" .. hex)
  return hex_to_bytes(hex)
end

-- signed int (4 bytes)
local function byte_int (n)
  assert(math.abs(n) <= 2^31, "Integer overflow")
  n = n >= 0 and n or n + 2^32
  local hex = strf("%08x", n)
  -- print("0x" .. hex)
  return hex_to_bytes(hex)
end

-- signed float (4 bytes)
local function byte_fixed (n)
  assert(math.abs(n) <= 2^16, "Float overflow")
  n = math.floor(n * 2.0^16 + .5)
  return byte_int(n)
end

-- read unsigned char (1 byte)
local function unsigned_char (b)
  local hex = bytes_to_hex(b)
  local n = hex_num(hex)
  -- print("num: " .. n)
  return n
end

-- read unsigned int (4 bytes)
local function unsigned_int (b)
  local hex = bytes_to_hex(b)
  local n = hex_num(hex)
  -- print("num: " .. n)
  return n
end

-- read signed int (4 bytes)
local function signed_int (b)
  local hex = bytes_to_hex(b)
  local n = hex_num(hex)
  n = n <= 2^31 - 1 and n or n - 2^32
  -- print("num: " .. n)
  return n
end

-- read signed float (4 bytes)
local function signed_fixed (b)
  local n = signed_int(b)
  return n / 2.0^16
end

-- check if table is serializeable
local function is_serializeable (t, list)
  local success = true
  list = list or {}

  -- manage table list for protection against infinite recursion
  if not list[t] then list[t] = true else return false end

  -- verify table fields
  for key, value in pairs(t) do
    local type_k, type_v = type(key), type(value)
    -- verify for forbidden types
    success = not forbidden[type_k] and not forbidden[type_v]
    -- verify nested tables recursively
    if type_k == "table" then success = is_serializeable(key, list) end
    if type_v == "table" then success = is_serializeable(value, list) end
  end

  -- return success or failure
  return success
end

-- types in bytecode
local TYPE_BOOL  = byte_char(1)
local TYPE_INT   = byte_char(2)
local TYPE_FIXED = byte_char(4)
local TYPE_STR   = byte_char(8)
local TYPE_TBL   = byte_char(16)

-- type getter
local get_type = {
  [1] = "boolean",
  [2] = "integer",
  [4] = "fixed",
  [8] = "string",
  [16] = "table",
}

-- sizes in bytecode
local SIZE_BOOL  = byte_int(1)
local SIZE_NUM   = byte_int(4)

local get_size = {
  boolean = 1,
  integer = 4,
  fixed = 4,
}

local read_data = {
  type = function (data) return get_type[get_byte(data)] end,
  size = function (data) return unsigned_int(data) end,
  integer = function (data) return signed_int(data) end,
  fixed = function (data) return signed_fixed(data) end,
  boolean = function (data) return unsigned_char(data) ~= 0 end,
  string = function (data) return data end,
  table = function (data) return data end,
}

local function serialize (t)
  -- returns serialized table in byte-stream string if successful
  -- returns nil if not successful

  -- verify if t is table
  assert(type(t) == "table", "Cannot serialize non-table value: " .. tostring(t))

  -- verify serialization requirements
  assert(is_serializeable(t), "WARNING: Attempt to serialize table with forbidden values or with recursive reference\n>>> " .. tostring(t))

  -- data to save
  local table_size
  local table_type = TYPE_TBL
  local data = next(t) and "" or TYPE_TBL .. "\0\0\0\0"

  for key, field in pairs(t) do
    local type_k, type_f = type(key), type(field)
    -- type 1B, size 1B, value nB
    local key_blob, field_blob
    local key_type, key_size, key_value
    local field_type, field_size, field_value

    -- get key info
    if type_k == "number" then
      if math.floor(key) == key then
        key_type = TYPE_INT
        key_value = byte_int(key)
      else
        key_type = TYPE_FIXED
        key_value = byte_fixed(key)
      end
      key_size = SIZE_NUM
    elseif type_k == "string" then
      key_type = TYPE_STR
      key_size = byte_int(#key)
      key_value = key
    elseif type_k == "table" then
      key_blob = serialize(key)
    end
    -- append key data
    data = data .. (key_blob or key_type .. key_size .. key_value)

    -- get field info
    if type_f == "boolean" then
      field_type = TYPE_BOOL
      field_size = SIZE_BOOL
      field_value = byte_char(field and 1 or 0)
    elseif type_f == "number" then
      if math.floor(field) == field then
        field_type = TYPE_INT
        field_value = byte_int(field)
      else
        field_type = TYPE_FIXED
        field_value = byte_fixed(field)
      end
      field_size = SIZE_NUM
    elseif type_f == "string" then
      field_type = TYPE_STR
      field_size = byte_int(#field)
      field_value = field
    elseif type_f == "table" then
      field_blob = serialize(field)
    end
    -- append field data
    data = data .. (field_blob or field_type .. field_size .. field_value)
  end

  -- append table metadata
  table_size = byte_int(#data)
  data = table_type .. table_size .. data

  return data
end

local function read_slot (data)
  local value_pos = 6
  local walked = 6
  local data_value
  local data_type = read_data.type(data:sub(1, 1))
  local data_size = read_data.size(data:sub(2, 5))
  walked = walked + data_size
  data_value = read_data[data_type](data:sub(value_pos, walked - 1))
  --print("data type:", data_type)
  --print("data size:", data_size)
  --print("data value:", data_value, bytes_to_hex(data:sub(value_pos, walked - 1)))

  return data_type, data_size, data_value
end

local function deserialize (data)
  local t = {}
  local data_type, data_size, inner_data = read_slot(data)
  local pos = 6

  while pos < data_size do
    local key_blob = data:sub(pos)
    local key_type, key_size, key_value = read_slot(key_blob)
    if key_type == "table" then key_value = deserialize(key_blob) end
    pos = pos + key_size + 5

    local field_blob = data:sub(pos)
    local field_type, field_size, field_value = read_slot(field_blob)
    if field_type == "table" then field_value = deserialize(field_blob) end
    pos = pos + field_size + 5

    t[key_value] = field_value
  end

  --print(t)
  return t
end

-- testing
local EPSILON = 2^-8
local s = "hey, what's going on?"
local sample_t = {
  1, 2, 3, 4, 5,
  math.pi,
  hello = "goodbye",
  fuck = "fudge",
  [{ "what", "is", "going", "on?" }] = true,
  "áéíóú",
}
assert(hex_to_bytes(bytes_to_hex(s)) == s, "TEST FAILED: STRING")
assert(128 == unsigned_char(byte_char(128)), "TEST FAILED: UNSIGNED CHAR")
assert(8 == unsigned_char(byte_char(8)), "TEST FAILED: UNSIGNED CHAR")
assert(65535 == unsigned_int(byte_int(65535)), "TEST FAILED: UNSIGNED INT")
assert(-65536 == signed_int(byte_int(-65536)), "TEST FAILED: SIGNED INT")
assert(10.24 - signed_fixed(byte_fixed(10.24)) < EPSILON, "TEST FAILED: SIGNED FIXED")

local binary_ver = serialize (sample_t)
assert(binary_ver, "TEST FAILED: SERIALIZATION")
local unbinary_ver = deserialize(binary_ver)
assert(unbinary_ver, "TEST FAILED: DESERIALIZATION")

local function compare(original, copy)
  for k,v in pairs(original) do
    if type(k) ~= "table" then
      assert(copy[k] ~= nil, "TEST FAILED: PRESERIALIZED TABLE IS DIFFERENT THAN POSTSERIALIZED TABLE")
      if type(v) ~= "table" then
        assert(type(v) == type(copy[k]) and v == copy[k] or v - copy[k] < EPSILON,
          "TEST FAILED: COPIED VALUE OF DESERIALIZED TABLE IS WRONG")
      end
    end
  end
end
compare(sample_t, unbinary_ver)

return {
  serialize = serialize,
  deserialize = deserialize
}

