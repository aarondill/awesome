---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete.
---If a field is missing, add it and report it.

---@alias GFileType "UNKNOWN"|"REGULAR"|"DIRECTORY"|"SYMBOLIC_LINK"|"SPECIAL"|"SHORTCUT"|"MOUNTABLE"
---@alias GFileAttributeType "INVALID"| "STRING"| "BYTE_STRING"| "BOOLEAN"| "UINT32"| "INT32"| "UINT64"| "INT64"| "OBJECT"| "STRINGV"
--- This needs to be Gio.FileQueryInfoFlags.NOFOLLOW_SYMLINKS to get symlink type information
---@alias FileQueryInfoFlags integer|0

---@class GFileInfo
---@field has_attribute fun(self: GFileInfo, attribute: string): boolean
---@field list_attributes fun(self: GFileInfo, namespace?: string): string[]?
---It is an error to call this if the GFileInfo does not contain G_FILE_ATTRIBUTE_STANDARD_TYPE.
---Note: this can't return SYMBOLIC_LINK unless the link is broken or flags contains Gio.FileQueryInfoFlags.NOFOLLOW_SYMLINKS
---@field get_file_type fun(self: GFileInfo): GFileType
---It is an error to call this if the GFileInfo does not contain G_FILE_ATTRIBUTE_STANDARD_NAME.
---@field get_name fun(self: GFileInfo): string
---Gets the file’s size (in bytes)
---It is an error to call this if the GFileInfo does not contain G_FILE_ATTRIBUTE_STANDARD_SIZE.
---@field get_size fun(self: GFileInfo): number
---@field get_attribute_string fun(self: GFileInfo, attribute: string): string?
---@field get_attribute_type fun(self: GFileInfo, attribute: string): GFileAttributeType
---@field get_attribute_object fun(self: GFileInfo, attribute: string): table?
---@field get_attribute_as_string fun(self: GFileInfo, attribute: string): string?

---@class GFileEnumerator
---@field next_files_async fun(self: GFileEnumerator, num_files: integer, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFileEnumerator>)
---@field next_files_finish fun(self: GFileEnumerator, task: GAsyncResult): nil, GError
---@field next_files_finish fun(self: GFileEnumerator, task: GAsyncResult): GFileInfo[], nil
---@field close_async fun(self: GFileEnumerator, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GFileEnumerator>)
---On error, returns NULL and sets error to the error. If the enumerator is at the end, NULL will be returned and error will be unset.
---@field next_file fun(self: GFileEnumerator, cancellable?: GCancellable): GFileInfo?, GError?
-- To use this, G_FILE_ATTRIBUTE_STANDARD_NAME must have been listed in the attributes list used when creating the GFileEnumerator.
---@field get_child fun(self: GFileEnumerator, info: GFileInfo): GFile

---@class GFile: userdata
---@field equal fun(self: GFile, other: GFile): boolean
---@field get_relative_path fun(self: GFile, other: GFile): string?
---@field query_exists fun(self: GFile, cancellable?: GCancellable): boolean
---Returns G_FILE_TYPE_UNKNOWN if the file does not exist.
---@field query_file_type fun(self: GFile, flags: FileQueryInfoFlags, cancellable?: GCancellable): GFileType
---@field query_info fun(self: GFile, attributes: string, flags: FileQueryInfoFlags, cancellable?: GCancellable): GFileInfo?, GError?
---@field get_parent fun(self: GFile): GFile?
---@field get_path fun(self: GFile): string?
---@field get_basename fun(self: GFile): string?
---@field load_contents_async fun(self: GFile, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field load_contents_finish fun(self: GFile, task: GAsyncResult): nil, GError
---@field load_contents_finish fun(self: GFile, task: GAsyncResult): contents: string, length: number, etag: string
---@field query_info_async fun(self: GFile, attributes: string, flags: FileQueryInfoFlags, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field query_info_finish fun(self: GFile, task: GAsyncResult): GFileInfo?, GError?
---@field enumerate_children_async fun(self: GFile, attributes: string, flags: FileQueryInfoFlags, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field enumerate_children_finish fun(self: GFile, task: GAsyncResult): GFileEnumerator?, GError?
---@field enumerate_children fun(self: GFile, attributes: string, flags: FileQueryInfoFlags, cancellable?: GCancellable): GFileEnumerator?, GError?

local Gio = require("util.lgi").Gio
---If a File is passed, it is returned.
---@param path string|GFile
---@return GFile
local function new_file_for_path(path)
  if type(path) ~= "string" then return path end
  assert(type(path) == "string")
  return Gio.File.new_for_path(path)
end
return new_file_for_path
