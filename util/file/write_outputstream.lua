local GLib = require("lgi.GLib")
local assertions = require("util.types.assertions")

--- Write to a stream - async
---@param stream GOutputStream
---@param content string|GBytes
---@param cb? fun(err?: userdata): any?
local function outputstream_write(stream, content, cb)
  assertions.type(content, "string", "content")
  assertions.iscallable(cb, true, "cb")
  if type(content) == "string" then -- convert to GBytes
    content = GLib.Bytes.new(content)
  end
  --- only pass callback if results are needed.
  return stream:write_bytes_async(content, GLib.PRIORITY_DEFAULT, nil, cb and function(file, task)
    local new_etags, err = file:write_finish(task)
    if not new_etags then return cb(err) end
    return cb(nil)
  end or nil)
end

return outputstream_write
