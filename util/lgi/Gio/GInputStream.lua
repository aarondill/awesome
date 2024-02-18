---@class GDataInputStreamStatic TODO:
---@field new fun(stream: GInputStream): GDataInputStream

---@class GInputStream
---@field read_bytes_async fun(self: GInputStream, count: integer, io_p: integer, cancel, cb?: fun(source: GInputStream, task: unknown))
---@field skip_async fun(self: GInputStream, count: integer, io_p: integer, cancel, cb?: fun(source: GInputStream, task: unknown))
---@field seek fun(self: GInputStream, offset, type): suc: boolean, error: userdata
---@field tell fun(self: GInputStream): integer -- Zero if not seekable
---@field close_async fun(self: GInputStream, io_p: integer, cancel, cb?: fun(source: GInputStream, task: unknown))
---@field read_bytes_finish fun(source: GInputStream, task: unknown): gbytes: table?, error: userdata?
---@field skip_finish fun(source: GInputStream, task: unknown): skipped: integer, error: userdata?

---@class GInputStreamStatic TODO:

---@class GDataInputStream :GInputStream
---@field read_line fun(self: GDataInputStream, cancellable?: GCancellable): string, integer
---@field read_line_async fun(self: GDataInputStream,io_p:integer, cancel, cb: fun(source: GDataInputStream, task:unknown))
---@field read_line_finish fun(source: GDataInputStream, task:unknown): line: string, len_or_err: number|userdata
