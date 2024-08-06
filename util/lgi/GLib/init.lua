---@meta

---@class GLib
---@field SeekType EnumDefinition<"SET"|"CUR"|"END">
---@field PRIORITY_DEFAULT 0
---The directory separator as a string. This is “/” on UNIX machines and “\" under Windows.
---@field DIR_SEPARATOR_S string
---The search path separator as a string. This is “:” on UNIX machines and “;” under Windows.
---@field SEARCHPATH_SEPARATOR_S string
---@field build_filenamev fun(args: string[]): string
---Returns TRUE if the given file_name is an absolute file name. Note that this is a somewhat vague concept on Windows.
---@field path_is_absolute fun(path: string): boolean
---If file_name ends with a directory separator it gets the component before the last slash.
---@field path_get_basename fun(path: string): string
---If the file name has no directory components “.” is returned
---@field path_get_dirname fun(path: string): string
---@field get_home_dir fun(): string
---@field get_user_name fun(): string
---@field setenv fun(var: string, val: string, overwrite: boolean): boolean
---@field unsetenv fun(var: string)
---@field find_program_in_path fun(prog: string): string?
---@field Error GErrorStatic
---@field Bytes GBytesStatic

---@class GBytesStatic
---@operator call(string): GBytes
---@field new fun(content: string): GBytes

---@class GBytes
---@field compare fun(self: GBytes, other: GBytes): integer
---@field equal fun(self: GBytes, other: GBytes): boolean
---@field get_data fun(self: GBytes): string? Note: if length == 0, then nil is returned
---@field get_region fun(self: GBytes, element_size: integer, offset: integer, n_elements: integer): userdata this is currently unusable in lua
---@field get_size fun(self: GBytes): integer
---@field hash fun(self: GBytes): integer
---@field new_from_bytes fun(self: GBytes, offset: integer, length: integer): GBytes
---This is added by lgi -- it also allows using #bytes to get the size
---@field data string? Note: if length == 0, then nil is returned

---@type lgi
local lgi = require("lgi")
return lgi.GLib
