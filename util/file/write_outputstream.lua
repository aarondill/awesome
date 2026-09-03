local GLib = require("lgi").GLib
local assertions = require("util.types.assertions")

--- Write to a stream - async
---@param stream GOutputStream
---@param content string|GBytes
---@param cb? fun(err?: GError): any?
local function outputstream_write(stream, content, cb)
  assertions.type(content, "string", "content")
  assertions.iscallable(cb, true, "cb")
  if type(content) == "string" then -- convert to GBytes
    content = GLib.Bytes.new(content)
  end
  return stream:write_bytes_async(content, GLib.PRIORITY_DEFAULT, nil, function(file, task)
    if not cb then return end --- only finish if results are needed.
    local new_etags, err = file:write_finish(task)
    if not new_etags then return cb(err) end
    return cb(nil)
  end)
end

return outputstream_write
