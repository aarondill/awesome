---@class GOutputStream -- An abstract class for writing data to a stream.
---Same as write_async() but takes a GBytes input instead
---@field write_async_bytes fun(self: GOutputStream, content: GBytes, io_priority: integer, cancellable?: userdata, callback?: fun(self: GOutputStream, task: userdata))
---WARNING: This function *does not* copy the contents of `contents` and so it must not be freed. Use write_bytes_async() instead.
---@field write_async fun(self: GOutputStream, content: string, len: integer, io_priority: integer, cancellable?: userdata, callback?: fun(self: GOutputStream, task: userdata))
---@field write_finish fun(self: GOutputStream, task: userdata): new_etags: userdata?, err: userdata?
---@field close fun(self: GOutputStream)