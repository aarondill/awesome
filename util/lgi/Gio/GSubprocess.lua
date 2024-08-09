---@meta
---@diagnostic disable: duplicate-doc-field
---Note that none of the type definitions in this file are complete. If a field is missing, add it and report it.

-- Note that the default for stdin is to redirect from /dev/null. For stdout
-- and stderr the default are for them to inherit the corresponding descriptor
-- from the calling process.
---@alias GSubprocessFlags
---|"NONE" No flags.
---|"STDIN_PIPE" Create a pipe for the stdin of the spawned process.
---|"STDIN_INHERIT" Stdin is inherited from the calling process.
---|"STDOUT_PIPE" Create a pipe for the stdout of the spawned process.
---|"STDOUT_SILENCE" Silence the stdout of the spawned process. (ie: redirect to /dev/null)
---|"STDERR_PIPE" Create a pipe for the stderr of the spawned process.
---|"STDERR_SILENCE" Silence the stderr of the spawned process. (ie: redirect to /dev/null)
---|"STDERR_MERGE" Merge the stderr of the spawned process with whatever the stdout happens to be.
---|"INHERIT_FDS" Spawned process inherits the file descriptors of thier parents (excluding std{in,out,err}).
---|"SEARCH_PATH_FROM_ENVP" If path searching is needed when spawning the subprocess, use the PATH in the launcher environment.

---@class GSubprocessStatic
---@field new fun(argv: string[], flags: Flags<GSubprocessFlags>): GSubprocess?, GError?

---@class GSubprocess
---If stdin is given, the subprocess must have been created with "STDIN_PIPE".
---@field communicate fun(self: GSubprocess, stdin?: GBytes, cancellable?: GCancellable): stdout: GBytes?, stderr: GBytes?
---@field communicate fun(self: GSubprocess, stdin?: GBytes, cancellable?: GCancellable): false, GError
---@field communicate_async fun(self: GSubprocess, stdin?: GBytes, cancellable?: GCancellable, callback: GAsyncReadyCallback<GSubprocess>)
---@field communicate_finish fun(self: GSubprocess, result: GAsyncResult): stdout: GBytes?, stderr: GBytes?
---@field communicate_finish fun(self: GSubprocess, result: GAsyncResult): false, GError
---@field communicate_utf8 fun(self: GSubprocess, stdin?: GBytes, cancellable?: GCancellable): stdout: GBytes?, stderr: GBytes?
---@field communicate_utf8 fun(self: GSubprocess, stdin?: GBytes, cancellable?: GCancellable): false, GError
---@field communicate_utf8_async fun(self: GSubprocess, stdin?: GBytes, cancellable?: GCancellable, callback: GAsyncReadyCallback<GSubprocess>)
---@field communicate_utf8_finish fun(self: GSubprocess, result: GAsyncResult): stdout: GBytes?, stderr: GBytes?
---@field communicate_utf8_finish fun(self: GSubprocess, result: GAsyncResult): false, GError
---@field force_exit fun(self: GSubprocess) On Unix, this function sends SIGKILL.
---It is an error to call this function before g_subprocess_wait() and unless g_subprocess_get_if_exited() returned TRUE.
---@field get_exit_status fun(self: GSubprocess): integer
---On UNIX, returns the process ID as a decimal string. On Windows, returns the result of GetProcessId() also as a string. If the subprocess has terminated, this will return NULL.
---@field get_identifier fun(self: GSubprocess): string?
---It is an error to call this function before g_subprocess_wait() has returned.
---@field get_if_exited fun(self: GSubprocess): boolean
---It is an error to call this function before g_subprocess_wait() has returned.
---@field get_if_signaled fun(self: GSubprocess): boolean
---It is an error to call this function before g_subprocess_wait() has returned.
---@field get_status fun(self: GSubprocess): integer
---The process must have been created with G_SUBPROCESS_FLAGS_STDERR_PIPE, otherwise NULL will be returned.
---@field get_stderr_pipe fun(self: GSubprocess): GInputStream?
---@field get_stdin_pipe fun(self: GSubprocess): GOutputStream?
---@field get_stdout_pipe fun(self: GSubprocess): GInputStream?
---It is an error to call this function before g_subprocess_wait() has returned.
---@field get_successful fun(self: GSubprocess): integer
---It is an error to call this function before g_subprocess_wait() and unless g_subprocess_get_if_signaled() returned TRUE.
---@field get_term_sig fun(self: GSubprocess): integer
-- Sends the UNIX signal signal_num to the subprocess, if it is still running. This API is not available on Windows.
---@field send_signal fun(self: GSubprocess, signal: integer)
---@field wait fun(self: GSubprocess, cancellable?: GCancellable): boolean, GError Synchronously wait for the subprocess to terminate.
---@field wait_async fun(self: GSubprocess, cancellable?: GCancellable, callback: GAsyncReadyCallback<GSubprocess>)
---@field wait_check fun(self: GSubprocess, cancellable?: GCancellable): boolean, GError Combines g_subprocess_wait() with g_spawn_check_wait_status().
---@field wait_check_async fun(self: GSubprocess, cancellable?: GCancellable, callback: GAsyncReadyCallback<GSubprocess>)
---@field wait_check_finish fun(self: GSubprocess, result: GAsyncResult): boolean, GError
---@field wait_finish fun(self: GSubprocess, result: GAsyncResult): boolean, GError

return require("util.lgi.Gio").Subprocess
