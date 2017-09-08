
local path = ...

assert(path, "Do not call init directly from lua, use require.")

if path ~= "basic" then
  path = path:match("(.+)[.]basic")
  assert(path, "Cannot require basiclib from basic dir")
  path = path:gsub("[.]", "/")
  path = "./" .. path .. "/?.lua;./" .. path .. "/?/init.lua"
  -- adds basiclib's parent directory to lua's package pack
  package.path = path .. package.path
end

require 'basic.tableutility'
require 'basic.logarithm'
require 'basic.coroutinefix'

return require 'basic.pack' 'basic'

