local gears = require("gears")
---Runs each_cb on each of for_each in parellel and calls done_cb when all are done
---@generic T, R
---@param val T
---@param ret table a table to store the result in. It will be stored in ret[stat]
---@param done_tbl boolean[] A table to store true in when done
---@param index integer
---@param each_cb fun(val: T, cb: fun(res: R), ...: any) the function to call with each piece of information. The return value is kept
---@param done_cb fun(res: R[], ...: any) the function to call when the data has been retrieved
---@param ... any passed to each_cb and done_cb functions after all other arguments
local function run_callbacks_in_parellel(done_tbl, index, ret, each_cb, done_cb, val, ...)
  local function is_false(v)
    return v == false
  end
  each_cb(val, function(res)
    ret[val] = res
    done_tbl[index] = true
    local first_false = gears.table.find_first_key(done_tbl, is_false, false)
    local is_done = first_false == nil -- All are true
    if is_done then
      done_tbl[index] = false -- Reduce the chance of race conditions, subsequent calculations will return false
      return done_cb(ret)
    end
  end, ...)
end

---Runs each_cb on each of for_each in parellel and calls done_cb when all are done
---@generic T, R
---@param for_each T[]
---@param each_cb fun(val: T, cb: fun(res: R), ...: any) the function to call with each piece of information. The return value is kept
---@param done_cb fun(res: R[], ...: any) the function to call when the data has been retrieved
---The done_cb will be called with a table containing the results of all the callbacks
---with each ret[key] being the result of each_cb(for_each[key], function(res) end)
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

return parallel_async
