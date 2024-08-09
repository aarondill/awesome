---@meta
---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete. If a field is missing, add it and report it.

---@class Gio
---@field FILE_ATTRIBUTE_STANDARD_TYPE "standard::type"
---@field FILE_ATTRIBUTE_STANDARD_NAME "standard::name"
---@field FILE_ATTRIBUTE_STANDARD_DISPLAY_NAME "standard::display-name"
---@field FILE_ATTRIBUTE_STANDARD_SIZE "standard::size"
---@field File GFileStatic
---@field DataInputStream GDataInputStreamStatic
---@field FileInfo GFileInfoStatic
---@field FileQueryInfoFlags FlagsDefinition<GFileQueryInfoFlags>
---@field FileCreateFlags FlagsDefinition<GFileCreateFlags>
---@field FileCopyFlags FlagsDefinition<GFileCopyFlags>
---@field FileType EnumDefinition<GFileType>
---@field IOErrorEnum EnumDefinition<string>
---@field Subprocess GSubprocessStatic
---@field SubprocessFlags FlagsDefinition<GSubprocessFlags>
---@field OutputStreamSpliceFlags FlagsDefinition<GOutputStreamSpliceFlags>
---@field UnixInputStream GUnixInputStreamStatic
---@field Cancellable GCancellableStatic

local lgi = require("lgi") ---@type lgi
return lgi.Gio
