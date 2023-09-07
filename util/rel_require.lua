---Gets the file name of the file that contains the function at level 'level'
---Doesn't include the path or the extension of the file
---@param level integer? pass the same number as you would to debug.getinfo(level).
-- Defaults to 2. The caller of the caller of this function
---@return string
local function filename(level)
  level = level or 2 -- caller of caller
  local str = debug.getinfo(level + 1, "S").source:sub(2)
  return str:match("^.*/(.*).lua$") or str
end

---Use in place of require to require relative to the current path
---This will likely need a '@module "MODULE"'
---If called with just one argument, it will immediately call require and return the result
---@param this_path string? pass ...
---@param path string the path to require
---@param assert boolean? Whether to error on failure. Default: true
---@return any? mod the module required or nil if not found
---@return unknown? loaderdata the second param returned from require (or nil if not found)
---@overload fun(this_path: string, path: string, assert: true): any, unknown -- Not nil
---@overload fun(module: string): any, unknown -- The regular require
local function relative_require(this_path, path, assert)
  _G.assert(type(assert or false) == "boolean", "assert must be a boolean or nil")
  _G.assert(type(this_path or "") == "string", "this_path must be a string or nil")
  assert = assert == nil and true or assert
  if type(this_path) == "string" and path == nil then
    -- Native require function
    if assert then return require(this_path) end
    local ret = table.pack(require(this_path))
    return ret[1] and table.unpack(ret, 2, ret.n) or nil
  end
  _G.assert(type(path) == "string", "Path must be a string") -- wait until after above check, in case used like normal require
  if assert then
    _G.assert(this_path, ("Could not find module. Call %s from a required file."):format(debug.getinfo(1, "n").name))
  end
  if not this_path then return nil end
  --- True if the calling file is an init.lua and is called by require('module.sub')
  local is_init_not_called = filename(2) == "init" and not this_path:match("%.init$")
  local this_module = is_init_not_called and (this_path .. ".") or (this_path):match("^(.-)[^%.]+$") -- returns 'lib.foo.'

  if assert then _G.assert(this_module, ("Could not find dir of module '%s'"):format(this_path)) end
  if not this_module then return nil end

  local module_path = this_module .. path
  local ok, mod, loaderdata = pcall(require, module_path)
  if assert then _G.assert(ok, ("Could not require module '%s'.\nerror:\n%s"):format(module_path, mod)) end
  if not ok then return nil end
  return mod, loaderdata
end

return relative_require
