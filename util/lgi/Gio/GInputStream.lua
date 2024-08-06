---@class GSeekable
---@field seek fun(self: GSeekable, offset, type): suc: boolean, error: userdata
---@field can_seek fun(self: GSeekable): boolean
---@field can_truncate fun(self: GSeekable): boolean
---@field tell fun(self: GInputStream): integer -- Zero if not seekable
---@field truncate fun(self: GSeekable, offset: integer, cancellable?: GCancellable): boolean, GError?

---@class GInputStream :GSeekable -- An abstract class for reading data from a stream.
---@field read_bytes_async fun(self: GInputStream, count: integer, io_priority: number, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field read_bytes_finish GAsyncFinish<GInputStream, GBytes> returns gbytes
---@field close fun(self: GInputStream, cancellable?: GCancellable): boolean, GError?
---@field close_async fun(self: GInputStream, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field is_closed fun(self: GInputStream): boolean
---@field skip fun(self: GInputStream, count: integer, cancellable?: GCancellable): integer, GError?
---@field skip_async fun(self: GInputStream, count: integer, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field skip_finish GAsyncFinish<GInputStream, integer> returns skipped

---@class GDataInputStreamStatic
---@field new fun(stream: GInputStream): GDataInputStream

---@class GDataInputStream :GInputStream
---@field read_line fun(self: GDataInputStream, cancellable?: GCancellable): string, integer
---@field read_line_async fun(self: GDataInputStream,io_p:integer, cancel, cb: fun(source: GDataInputStream, task:unknown))
---@field read_line_finish fun(source: GDataInputStream, task:unknown): line: string, len_or_err: number|userdata
