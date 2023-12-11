---@meta

---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete.
---If a field is missing, add it and report it.

---An intentionally opaque class that must be passed to the _finish method. This should only ever be used *once*!
---@class GAsyncResult
---@alias GAsyncReadyCallback<T> fun(self: T, task: GAsyncResult)
---@class GError :userdata

---@class lgi
---@field Gio Gio
---@field GLib GLib
---Use direct access instead. It has better types.
---@field require fun(mod: string): table

local lgi = require("lgi") ---@type lgi

return lgi
