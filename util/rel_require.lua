---Use in place of require to require relative to the current path
---This will likely need a '@module "MODULE"'
---@param this_path string? pass ...
---@param path string the path to require
---@param assert boolean? Whether to error on failure. Default: true
---@return any? mod the module required or nil if not found
---@overload fun(this_path: string, path: string, assert: true): any -- Not nil
local function relative_require(this_path, path, assert)
  _G.assert(type(this_path or "") == "string", "this_path must be a string or nil")
  _G.assert(type(path) == "string", "Path must be a string")
  _G.assert(type(assert or false) == "boolean", "assert must be a boolean or nil")
  assert = assert == nil and true or assert
  if assert then
    _G.assert(this_path, ("Could not find module. Call %s from a required file."):format(debug.getinfo(1, "n").name))
  end
  if not this_path then return nil end

  local this_module = (this_path):match("^(.-)[^%.]+$") -- returns 'lib.foo.'
  if assert then _G.assert(this_module, ("Could not find dir of module '%s'"):format(this_path)) end
  if not this_module then return nil end

  local module_path = this_module .. path
  local ok, mod = pcall(require, module_path)
  if assert then _G.assert(ok, ("Could not require module '%s'.\nerror:\n%s"):format(module_path, mod)) end
  return ok or nil and mod
end

return relative_require
