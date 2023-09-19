local mt = {}
local m_path = ...
function mt:__index(key)
  local require = require("util.rel_require")
  local mod = require(m_path, key, false)
  return mod
end
return setmetatable({}, mt)
