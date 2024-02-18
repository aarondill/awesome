---@meta
---@diagnostic disable: duplicate-doc-field This is used for overloading. Note: It's not perfect because the return types will not be narrowed.
---Note that none of the type definitions in this file are complete. If a field is missing, add it and report it.

---@alias GSubprocessFlags "NONE"|"STDIN_PIPE"|"STDIN_INHERIT"|"STDOUT_PIPE"|"STDOUT_SILENCE"|"STDERR_PIPE"|"STDERR_SILENCE"|"STDERR_MERGE"|"INHERIT_FDS"|"SEARCH_PATH_FROM_ENVP"

---@class GSubprocessStatic
---@field new fun(argv: string[], flags: Enum<GSubprocessFlags>): GSubprocess?, GError?

---@class GSubprocess
---If stdin is given, the subprocess must have been created with "STDIN_PIPE".
---@field communicate fun(self: GSubprocess, stdin: GBytes, cancellable?: GCancellable): stdout: GBytes?, stderr: GBytes?
---@field communicate_async fun(self: GSubprocess)
---@field communicate_finish fun(self: GSubprocess)
---@field communicate_utf8 fun(self: GSubprocess)
---@field communicate_utf8_async fun(self: GSubprocess)
---@field communicate_utf8_finish fun(self: GSubprocess)
---@field force_exit fun(self: GSubprocess)
---@field get_exit_status fun(self: GSubprocess)
---@field get_identifier fun(self: GSubprocess)
---@field get_if_exited fun(self: GSubprocess)
---@field get_if_signaled fun(self: GSubprocess)
---@field get_status fun(self: GSubprocess)
---@field get_stderr_pipe fun(self: GSubprocess)
---@field get_stdin_pipe fun(self: GSubprocess)
---@field get_stdout_pipe fun(self: GSubprocess)
---@field get_successful fun(self: GSubprocess)
---@field get_term_sig fun(self: GSubprocess)
---@field send_signal fun(self: GSubprocess)
---@field wait fun(self: GSubprocess)
---@field wait_async fun(self: GSubprocess)
---@field wait_check fun(self: GSubprocess)
---@field wait_check_async fun(self: GSubprocess)
---@field wait_check_finish fun(self: GSubprocess)
---@field wait_finish fun(self: GSubprocess)

return require("util.lgi.Gio").Subprocess
