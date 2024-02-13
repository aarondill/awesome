---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete.
---If a field is missing, add it and report it.

---Compare against gio.FileType.*, or use gio.FileType[GFileType] to get a string
---@alias GFileTypeEnum 0|1|2|3|4|5|6
---@alias GFileType "UNKNOWN"|"REGULAR"|"DIRECTORY"|"SYMBOLIC_LINK"|"SPECIAL"|"SHORTCUT"|"MOUNTABLE"

---@class GFileInfo
---@field has_attribute fun(self: GFileInfo, attribute: string): boolean
---@field list_attributes fun(self: GFileInfo, namespace?: string): string[]?
---It is an error to call this if the GFileInfo does not contain G_FILE_ATTRIBUTE_STANDARD_TYPE.
---@field get_file_type fun(self: GFileInfo): GFileTypeEnum
---It is an error to call this if the GFileInfo does not contain G_FILE_ATTRIBUTE_STANDARD_NAME.
---@field get_name fun(self: GFileInfo): string
---Gets the file’s size (in bytes)
---It is an error to call this if the GFileInfo does not contain G_FILE_ATTRIBUTE_STANDARD_SIZE.
---@field get_size fun(self: GFileInfo): number
---@field get_attribute_string fun(self: GFileInfo, attribute: string): string?

---@class GFile: userdata
---@field equal fun(self: GFile, other: GFile): boolean
---@field get_relative_path fun(self: GFile, other: GFile): string?
---@field get_parent fun(self: GFile): GFile?
---@field get_path fun(self: GFile): string?
---@field get_basename fun(self: GFile): string?
---@field load_contents_async fun(self: GFile, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field load_contents_finish fun(self: GFile, task: GAsyncResult): nil, GError
---@field load_contents_finish fun(self: GFile, task: GAsyncResult): contents: string, length: number, etag: string
---@field query_info_async fun(self: GFile, attributes: string, flags: number, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field query_info_finish fun(self: GFile, task: GAsyncResult): nil, GError
---@field query_info_finish fun(self: GFile, task: GAsyncResult): GFileInfo, nil

local Gio = require("util.lgi").Gio
---If a File is passed, it is returned.
---@param path string|GFile
---@return GFile
local function new_file_for_path(path)
  if type(path) == "userdata" then return path end
  assert(type(path) == "string")
  return Gio.File.new_for_path(path)
end
return new_file_for_path
