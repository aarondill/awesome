---@meta

---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete.
---If a field is missing, add it and report it.

---@class Gio
---@field FILE_ATTRIBUTE_STANDARD_TYPE "standard::type"
---@field File GFileStatic

---@class GFileStatic
---@field new_for_path fun(path: string): GFile
---@field new_for_uri fun(uri: string): GFile
---@field new_tmp fun(tmpl?: string): GFile, GFileIOStream
---@field new_tmp fun(tmpl?: string): GError
---@field new_tmp_async fun (tmpl?:string, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<nil>)
---@field new_tmp_finish fun(task: GAsyncResult): GFile, GFileIOStream
---@field new_tmp_finish fun(task: GAsyncResult): GError

---@class GFileIOStream

---@class GCancellable
---@field cancel fun(self: GCancellable)
---callback is called at most once, either directly at the time of the connect if cancellable is already cancelled, or when cancellable is cancelled in some thread.
---@field connect fun(self: GCancellable, callback: fun()): handler_id: number|0
---@field disconnect fun(self: GCancellable, handler_id: number)
---@field is_cancelled fun(self: GCancellable): boolean
---Resets cancellable to its uncancelled state.
---Note: BAD IDEA™. Just create a new cancellable
---@field reset fun(self: GCancellable)

local lgi = require("lgi") ---@type lgi
return lgi.Gio
