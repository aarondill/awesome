---Concat arguments to a command. This function will handle quoting.
---@param command string|string[] the command to concat onto
---@param args string[] arguments to append to the command
---@return string|string[] new_command the new command with `args` appended
local function concat_command(command, args)
	if type(command) == "string" then
		local new_command = command
		for _, arg in ipairs(args) do
			new_command = ("%s '%s'"):format(new_command, arg) -- handles quotes
		end
		return new_command
	elseif type(command) == "table" then
		-- shallow copy the table.
		-- This shouldn't be an issue since strings are stateless
		local new_command = table.move(command, 1, #command, 1, {})
		for _, arg in ipairs(args) do
			table.insert(new_command, arg)
		end
		return new_command
	else
		error("command must be a string or table", 2)
	end
end

return concat_command
