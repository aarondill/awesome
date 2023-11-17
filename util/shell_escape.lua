---@param args string[] | string
---@return string escaped
return function(args)
  if type(args) == "string" then args = { args } end
  local ret = {}
  for _, a in pairs(args) do
    local s = tostring(a)
    if s:match("[^A-Za-z0-9_/:-]") then -- If contains special chars
      s = table.concat({
        "'",
        s:gsub("'", "'\\''"),
        "'",
      })
    end
    table.insert(ret, s)
  end
  return table.concat(ret, " ")
end
