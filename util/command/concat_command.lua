local rel_require = require("util.rel_require")
local shell_escape = rel_require(..., "shell_escape") ---@module "util.command.shell_escape"
local assertions = require("util.types.assertions")
local tables = require("util.tables")

---concat_command when command is a table
---@param command string[]
---@param args string|string[]
---@return string[]|string new_cmd string if args is a string
local function __concat_command_tbl(command, args)
  if type(args) == "string" then return table.concat({ shell_escape(command), args }, " ") end
  return tables.tbl_join(command, args)
end

---concat_command when command is a string
---@param command string
---@param args string|string[]
---@return string new_cmd
local function __concat_command_str(command, args)
  if type(args) == "table" then args = shell_escape(args) end
  return table.concat({ command, args }, " ") -- handles quotes
end

---Concat arguments to a command.
---If either argument is a string, a string will be returned. Tables are prefered.
---This function will handle quoting, if it's passed a table of args.
---If a string is passed, no quote handling will be performed on the passed string.
---This function will shallow copy any table passed in. It should be safe to modify the returned table, but if it contains non-strings, be very careful.
---@param command string[] the command to concat onto
---@param args string[] arguments to append to the command
---@return string[] new_command the new command with `args` appended
---@overload fun(command: string, args: string|string[]): string
---@overload fun(command: string[]|string, args: string): string
local function concat_command(command, args)
  assertions.type(args, { "string", "table" }, "args", 2)
  assertions.type(command, { "string", "table" }, "command", 2)

  if type(command) == "string" then return __concat_command_str(command, args) end
  return __concat_command_tbl(command, args)
end

return concat_command
