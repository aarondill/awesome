---Stringifies a table of commands/args. Quoting each one and seperating by a space
---Note: arguments that contain the `'` charector are unsafe!
---@param command string[]
---@return string
local function stringify_command(command)
	local new_command, format = "", "%s '%s'"
	for _, arg in ipairs(command) do
		new_command = string.format(format, new_command, arg)
	end
	new_command = new_command:match("^%s*(.-)%s*$") -- Remove leading/trailing whitespace
	return new_command
end

---Modifies a_table!
---Merge a_table into a_table
---@param a_table table
---@param b_table table
---@return table
local function table_merge_append(a_table, b_table)
	for _, i in ipairs(b_table) do
		table.insert(a_table, i)
	end
	return a_table
end

---concat_command when command is a table
---@param command string[]
---@param args string|string[]
---@return string[]|string new_cmd string if args is a string
local function __concat_command_tbl(command, args)
	if type(args) == "string" then
		return stringify_command(command) .. " " .. args
	end
	-- shallow copy the table.
	-- This shouldn't be an issue since strings are stateless
	---@type string[]
	local new_command = table.move(command, 1, #command, 1, {})
	return table_merge_append(new_command, args)
end

---concat_command when command is a string
---@param command string
---@param args string|string[]
---@return string new_cmd
local function __concat_command_str(command, args)
	if type(args) == "string" then
		return command .. " " .. args
	end

	return command .. stringify_command(args) -- handles quotes
end

---Concat arguments to a command.
---If either argument is a string, a string will be returned. Tables are prefered.
---This function will handle quoting, if it's passed a table of args. Arguments that contain `'` are unsafe.
---If a string is passed, no quote handling will be performed on the passed string.
---This function will shallow copy any table passed in. It should be safe to modify the returned table, but if it contains non-strings, be very careful.
---@param command string[] the command to concat onto
---@param args string[] arguments to append to the command
---@return string[] new_command the new command with `args` appended
---@overload fun(command: string, args: string|string[]): string
---@overload fun(command: string[]|string, args: string): string
local function concat_command(command, args)
	do
		local t_args = type(args)
		if t_args ~= "string" and t_args ~= "table" then
			error("args must be a string or a table", 2)
		end
	end

	if type(command) == "string" then
		return __concat_command_str(command, args)
	elseif type(command) == "table" then
		return __concat_command_tbl(command, args)
	else
		error("command must be a string or table", 2)
	end
end

return concat_command
