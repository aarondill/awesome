---@alias GSeekType "SET"|"CUR"|"END"

---@class GSeekable
---@field seek fun(self: GSeekable, offset: integer, type: Enum<GSeekType>): suc: boolean, GError?
---@field can_seek fun(self: GSeekable): boolean
---@field can_truncate fun(self: GSeekable): boolean
---@field tell fun(self: GInputStream): integer -- Zero if not seekable
---@field truncate fun(self: GSeekable, offset: integer, cancellable?: GCancellable): boolean, GError?

---@class GInputStream :GSeekable -- An abstract class for reading data from a stream.
---@field read_bytes_async fun(self: GInputStream, count: integer, io_priority: number, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field read_bytes_finish fun(self: GInputStream, task: GAsyncResult): GBytes, GError?
---@field close fun(self: GInputStream, cancellable?: GCancellable): boolean, GError?
---@field close_async fun(self: GInputStream, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field is_closed fun(self: GInputStream): boolean
---@field skip fun(self: GInputStream, count: integer, cancellable?: GCancellable): skpped: integer, GError?
---@field skip_async fun(self: GInputStream, count: integer, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field skip_finish fun(self: GInputStream, task: GAsyncResult): skpped: integer, GError?

---@class GDataInputStreamStatic
---@field new fun(stream: GInputStream): GDataInputStream

---@class GDataInputStream :GInputStream
---@field read_line fun(self: GDataInputStream, cancellable?: GCancellable): string?, integer|GError?
---@field read_line_async fun(self: GDataInputStream, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GInputStream>)
---@field read_line_finish fun(self: GInputStream, task: GAsyncResult): line: string?, len: number|GError?

---@class GUnixInputStreamStatic
---@field new fun(fd: integer, close_fd?: boolean): GUnixInputStream
---@class GUnixInputStream :GInputStream
