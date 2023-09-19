local pcall_handler = require("util.pcall_handler")
local source_path = require("util.source_path")

---Use in place of require to require relative to the current path
---This will likely need a '@module "MODULE"'
---If called with just one argument, it will immediately call require and return the result
---Note: This is broken when immediately returning it! Something weird about lua's usage of ... in returned values.
---@param this_path string? pass ...
---@param path string the path to require
---@param assert boolean? Whether to error on failure. Default: true
---@return any? mod the module required or nil if not found
---@return unknown? loaderdata the second param returned from require (or nil if not found)
---@overload fun(this_path: string, path: string, assert: true): any, unknown -- Not nil
---@overload fun(module: string, path: nil, assert?: boolean): any, unknown -- The regular require
local function relative_require(this_path, path, assert)
  if assert == nil then assert = true end
  _G.assert(type(assert) == "boolean", "assert must be a boolean")
  _G.assert(type(this_path or "") == "string", "this_path must be a string or nil")
  if type(this_path) == "string" and path == nil then
    path, this_path = this_path, nil -- swap the arguments
    -- Native require function
    if assert then return require(path) end
    local ok, ret = pcall_handler(pcall(require, path))
    return ok and table.unpack(ret, 1, ret.n) or nil
  end
  _G.assert(type(path) == "string", "Path must be a string") -- wait until after above check, in case used like normal require
  if assert then
    _G.assert(this_path, ("Could not find module. Call %s from a required file."):format(debug.getinfo(1, "n").name))
  end
  if not this_path then return nil end
  --- True if the calling file is an init.lua and is called by require('module.sub')
  local is_init_not_called = source_path.filename(2) == "init" and not this_path:match("%.init$")
  local this_module = is_init_not_called and (this_path .. ".") or (this_path):match("^(.-)[^%.]+$") -- returns 'lib.foo.'

  if assert then _G.assert(this_module, ("Could not find dir of module '%s'"):format(this_path)) end
  if not this_module then return nil end

  local module_path = this_module .. path
  local ok, ret = pcall_handler(pcall(require, module_path))
  if assert then _G.assert(ok, ("Could not require module '%s'.\nerror:\n%s"):format(module_path, ret)) end
  if not ok then return nil end
  return table.unpack(ret, 1, ret.n)
end

return relative_require
