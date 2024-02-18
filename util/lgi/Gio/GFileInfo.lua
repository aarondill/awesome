---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---@meta

---@class GFileInfoStatic: userdata

---@class GFileInfo: userdata
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

---@class GFileEnumerator: userdata
---@field next_files_async fun(self: GFileEnumerator, num_files: integer, io_priority: integer, cancellable?: GCancellable, callback: GAsyncReadyCallback<GFileEnumerator>)
---@field next_files_finish fun(self: GFileEnumerator, task: GAsyncResult): nil, GError
---@field next_files_finish fun(self: GFileEnumerator, task: GAsyncResult): GFileInfo[], nil
---@field close_async fun(self: GFileEnumerator, io_priority: integer, cancellable?: GCancellable, callback?: GAsyncReadyCallback<GFileEnumerator>)
---On error, returns NULL and sets error to the error. If the enumerator is at the end, NULL will be returned and error will be unset.
---@field next_file fun(self: GFileEnumerator, cancellable?: GCancellable): GFileInfo?, GError?
-- To use this, G_FILE_ATTRIBUTE_STANDARD_NAME must have been listed in the attributes list used when creating the GFileEnumerator.
---@field get_child fun(self: GFileEnumerator, info: GFileInfo): GFile

return require("util.lgi.Gio").FileInfo
