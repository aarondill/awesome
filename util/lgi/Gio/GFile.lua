---@meta
---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete. If a field is missing, add it and report it.

---@alias GFileAttributeType "INVALID"| "STRING"| "BYTE_STRING"| "BOOLEAN"| "UINT32"| "INT32"| "UINT64"| "INT64"| "OBJECT"| "STRINGV"
---@alias GFileType "UNKNOWN"|"REGULAR"|"DIRECTORY"|"SYMBOLIC_LINK"|"SPECIAL"|"SHORTCUT"|"MOUNTABLE"
---@alias GFileQueryInfoFlags "NOFOLLOW_SYMLINKS"|"NONE" This needs to be NOFOLLOW_SYMLINKS to get symlink type information
---@alias GFileCreateFlags "NONE" No flags set.
---|"PRIVATE" Create a file that can only be accessed by the current user.
---|"REPLACE_DESTINATION" Replace the destination as if it didn’t exist before.
---Don’t try to keep any old permissions, replace instead of following links.
---This is generally useful if you’re doing a “copy over” rather than a “save
---new version of” replace operation. You can think of it as “unlink
---destination” before writing to it, although the implementation may not be
---exactly like that. This flag can only be used with g_file_replace() and its
---variants, including g_file_replace_contents(). Since 2.20

---@class GFileStatic
---@field new_for_path fun(path: string): GFile
---@field new_for_uri fun(uri: string): GFile
---@field new_tmp fun(tmpl?: string): GFile, GFileIOStream
---@field new_tmp fun(tmpl?: string): GError
---@field new_tmp_async fun (tmpl?:string, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<nil>)
---@field new_tmp_finish fun(task: GAsyncResult): GFile, GFileIOStream
---@field new_tmp_finish fun(task: GAsyncResult): GError

---@class GFile: userdata
---@field equal fun(self: GFile, other: GFile): boolean
---@field get_relative_path fun(self: GFile, other: GFile): string?
---@field query_exists fun(self: GFile, cancellable?: GCancellable): boolean
---Returns G_FILE_TYPE_UNKNOWN if the file does not exist.
---@field query_file_type fun(self: GFile, flags: Enum<GFileQueryInfoFlags>, cancellable?: GCancellable): GFileType
---@field query_info fun(self: GFile, attributes: string, flags: Enum<GFileQueryInfoFlags>, cancellable?: GCancellable): GFileInfo?, GError?
---@field get_parent fun(self: GFile): GFile?
---@field get_path fun(self: GFile): string?
---@field get_basename fun(self: GFile): string?
---@field load_contents_async fun(self: GFile, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field load_contents_finish fun(self: GFile, task: GAsyncResult): nil, GError
---@field load_contents_finish fun(self: GFile, task: GAsyncResult): contents: string, length: number, etag: string
---@field load_contents fun(self: GFile, cancellable?: GCancellable): contents: string, length: number, etag: string
---@field load_contents fun(self: GFile, cancellable?: GCancellable): nil, GError
---@field query_info_async fun(self: GFile, attributes: string, flags: Enum<GFileQueryInfoFlags>, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field query_info_finish fun(self: GFile, task: GAsyncResult): GFileInfo?, GError?
---@field enumerate_children_async fun(self: GFile, attributes: string, flags: Enum<GFileQueryInfoFlags>, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field enumerate_children_finish fun(self: GFile, task: GAsyncResult): GFileEnumerator?, GError?
---@field enumerate_children fun(self: GFile, attributes: string, flags: Enum<GFileQueryInfoFlags>, cancellable?: GCancellable): GFileEnumerator?, GError?
---@field replace_contents_async fun(self: GFile, contents: string, etag?: string, make_backup: boolean, flags: Enum<GFileCreateFlags>, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFile>)
---@field replace_contents_finish fun(self: GFile, task: GAsyncResult): true, new_etag: string?
---@field replace_contents_finish fun(self: GFile, task: GAsyncResult): false, GError
---@field replace_contents fun(self: GFile, contents: string, etag?: string, make_backup: boolean, flags: Enum<GFileCreateFlags>, cancellable?: GCancellable): true, new_etag: string?
---@field replace_contents fun(self: GFile, contents: string, etag?: string, make_backup: boolean, flags: Enum<GFileCreateFlags>, cancellable?: GCancellable): false, GError
---@field delete fun(self: GFile, cancellable?: GCancellable): boolean, GError?

---@class GFileIOStream TODO:

return require("util.lgi.Gio").File
