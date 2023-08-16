local gears = require("gears")
---@generic T, R
---@alias each T
---@alias for_each T[]
---@alias each_cb fun(info: T, ...: any): R
---@alias done_cb fun(info: R[], ...: any)

---Runs each_cb on each of for_each in parellel and calls done_cb when all are done
---@param val each
---@param ret table a table to store the result in. It will be stored in ret[stat]
---@param done_tbl boolean[] A table to store true in when done
---@param index integer
---@param each_cb each_cb
---@param done_cb done_cb
---@param ... any passed to each_cb and done_cb functions after all other arguments
local function run_callbacks_in_parellel(done_tbl, index, ret, each_cb, done_cb, val, ...)
  local function not_val(v)
    return not v
  end
  each_cb(function(...)
    ret[val] = { ... }
    done_tbl[index] = true
    local first_false = gears.table.find_first_key(done_tbl, not_val, false)
    local is_done = first_false ~= nil
    if is_done then
      done_tbl[index] = false -- Reduce the chance of race conditions, subsequent calculations will return false
      return done_cb(ret)
    end
  end, ...)
end

---Runs each_cb on each of for_each in parellel and calls done_cb when all are done
---@param for_each for_each
---@param each_cb each_cb the function to call with each piece of information. The return value is kept
---@param done_cb done_cb the function to call when the data has been retrieved
---@param ... any passed to each_cb and done_cb functions after all other arguments
---@return nil
local function parallel_async(for_each, each_cb, done_cb, ...)
  local ret = {}
  if #for_each == 0 then
    done_cb(ret) -- call with empty table, since no items to process
    return
  end
  local done = {}
  for index, v in ipairs(for_each) do
    done[index] = false -- Assign an order to them.
    run_callbacks_in_parellel(done, index, ret, each_cb, done_cb, v, ...)
  end
end

--- The done_cb will be called with a table containing the results of all the callbacks, with each ret[key] being the result of each_cb(for_each[key])
return parallel_async
