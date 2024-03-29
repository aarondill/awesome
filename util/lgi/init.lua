---@meta

---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete.
---If a field is missing, add it and report it.

---LGI handles enums, allowing a string to be passed, or an array of strings, or an integer
---It also allows a table {[T]=any}, but I've chosen not to include this in the type
---@alias Enum<T> T|T[]|integer
---@alias EnumDefinition<T> {[T]: integer, [integer]: T}

---An intentionally opaque class that must be passed to the _finish method. This should only ever be used *once*!
---@class GAsyncResult
---@alias GAsyncReadyCallback<T> fun(self: T, task: GAsyncResult)

---These are performed through lgi
---@alias LGI.Error.domain table|string
---@alias LGI.Error.code string|integer

---@class GError :userdata
---@field message string
---@field domain string
---@field code string
---@field matches fun(self: GError, other: GError): boolean
---@field matches fun(self: GError, domain: LGI.Error.domain, code: LGI.Error.code): boolean

---@class GErrorStatic
---@field new fun(domain: LGI.Error.domain, code: LGI.Error.code, message: string): GError

---@class lgi
---@field Gio Gio
---@field GLib GLib
---Use direct access instead. It has better types.
---@field require fun(mod: string): unknown

local lgi = require("lgi") ---@type lgi

return lgi
