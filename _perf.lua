local M = {}
---@param name string
---@generic T
---@param func fun(): T
---@return T, ...
function M.profile(name, func)
  local start = os.clock()
  local result = table.pack(func())
  local end_time = os.clock()
  local naughty = require("naughty")
  naughty.notify({ text = string.format("profile: %s took %.3f ms", name, (end_time - start) * 1000) })
  return table.unpack(result, 1, result.n)
end

function M.profile_require()
  local old_require = _G.require
  ---@class PerfNode
  ---@field name string
  ---@field children PerfNode[]
  ---@field time number
  ---@field self_time number

  ---@type PerfNode[]
  local stack = {}

  local rootstart = os.clock()
  stack[1] = { name = "root", children = {}, time = 0, self_time = 0 }

  ---@param node PerfNode
  ---@param start number
  local function compute_time(node, start)
    node.time = os.clock() - start
    local children_time = 0
    for _, child in ipairs(node.children) do
      children_time = children_time + child.time
    end
    node.self_time = node.time - children_time
  end

  _G.require = function(name)
    local start = os.clock()

    ---@type PerfNode
    local node = {
      name = name,
      children = {},
      time = 0,
      self_time = 0,
    }

    local parent = assert(stack[#stack], "no parent node")
    table.insert(parent.children, node)

    table.insert(stack, node)

    local ok, result = pcall(old_require, name)

    compute_time(node, start)

    table.remove(stack)

    if not ok then error(result, 1) end

    return result
  end

  return function(max_depth) ---@param max_depth integer?
    max_depth = max_depth or math.huge
    compute_time(stack[1], rootstart)

    _G.require = old_require

    local lines = {}

    ---@param node PerfNode
    ---@param prefix string
    ---@param is_last boolean
    ---@param depth integer
    local function print_tree(node, prefix, is_last, depth)
      local branch = is_last and "└─ " or "├─ "
      table.insert(
        lines,
        string.format(
          "%s%s%s (self: %.3f ms, total: %.3f ms)",
          prefix,
          branch,
          node.name,
          node.self_time * 1000,
          node.time * 1000
        )
      )

      local child_prefix = prefix .. (is_last and "   " or "│  ")

      --- Sort by (total) time
      table.sort(node.children, function(a, b) return a.self_time > b.self_time end)
      if depth < max_depth then
        for i, child in ipairs(node.children) do
          print_tree(child, child_prefix, i == #node.children, depth + 1)
        end
      end
    end

    local root = stack[1]
    print_tree(root, "", true, 1)

    return table.concat(lines, "\n")
  end
end

return M
