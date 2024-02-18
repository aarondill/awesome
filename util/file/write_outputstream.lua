local assertions = require("util.types.assertions")

---@class GOutputStream
---@field write_async fun(self: GOutputStream, content: string, len: integer, cancellable?: userdata, callback?: fun(self: GOutputStream, task: userdata))
---@field write_finish fun(self: GOutputStream, task: userdata): new_etags: userdata?, err: userdata?
---@field close fun(self: GOutputStream)

--- Write to a stream - async
---@param stream GOutputStream
---@param content string
---@param cb? fun(err?: userdata): any?
local function outputstream_write(stream, content, cb)
  assertions.type(content, "string", "content")
  assertions.iscallable(cb, true, "cb")
  --- only pass callback if results are needed.
  ---params(stream:write_async) GOutputStream* stream, void* buffer, gsize count, int io_priority, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
  return stream:write_async(content, content:len(), nil, cb and function(file, task)
    local new_etags, err = file:write_finish(task)
    if not new_etags then return cb(err) end
    return cb(nil)
  end or nil)
end

return outputstream_write
