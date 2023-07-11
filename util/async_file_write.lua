local gio = require("lgi").Gio

---This array is in module scope, allowing values to be placed inside of it, without worrying they will be garbage collected
---Be *CERTAIN* to clear the values when you are done with them. This can and will being a memory leak otherwise.
---@type any[]
local SAVE_FROM_GARBAGE_COLLECTION = {}
--- Used to disable lua-language-server warning about unused variables
SAVE_FROM_GARBAGE_COLLECTION = SAVE_FROM_GARBAGE_COLLECTION

--- Replace a file content or create a new one - Async :)
---@param path string file path to write to
---@param content string content to write to the file
---@source https://github.com/Elv13/awesome-configs/blob/master/utils/fd_async.lua
local function file_write(path, content)
	if type(path) ~= "string" or type(content) ~= "string" then
		error("path and content must be strings", 2)
	end
	--- *Attempt* to remove collisions between inputs. This cannot be done perfectly
	local index = path .. content .. tostring(math.random(1, 5000)) .. tostring(math.random(1, 5000))
	--- Store the content in the global array
	SAVE_FROM_GARBAGE_COLLECTION[index] = content

	---params(replace_contents_async): string contents, string etag, boolean make_backup, GFileCreateFlags flags, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data
	--- NOTE: This function does not copy `content`, so we must protect it from being garbage-collected (resulting in garbage being written to disk)
	gio.File.new_for_path(path):replace_contents_async(content, nil, false, 0, nil, function(file, task)
		--- Finish the write operation and close the file(?)
		file:replace_contents_finish(task)

		--- Clear the content to allow garbage collection - Avoid a memory leak
		SAVE_FROM_GARBAGE_COLLECTION[index] = nil
	end)
end

return file_write
