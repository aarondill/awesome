local stream = require("stream")
---Stringifies a table of commands/args.
---Quotes each one and seperates them with delim
---@param args string[] | string A string is treated as a single argument
---@param delim? string default ' '
---@return string escaped
return function(args, delim)
  return stream
    .new(args)
    :map(function(s)
      if not s:match("[^A-Za-z0-9_/:-]") then return s end
      return table.concat({ "'", s:gsub("'", "'\\''"), "'" }) -- If contains special chars
    end)
    :join(delim or " ")
end
