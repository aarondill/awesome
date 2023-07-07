--- Replace a file content or create a new one - Async :)
---@param path string file path to write to
---@param content string content to write to the file
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_write(path, content)
	local gio = require("lgi").Gio
	gio.File.new_for_path(path):replace_contents_async(content, nil, function(file, task)
		file:replace_contents_finish(task)
	end, 0)
end

return file_write
