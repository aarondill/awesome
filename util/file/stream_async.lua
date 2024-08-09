local lgi = require("lgi")
local new_file_for_path = require("util.file.new_file_for_path")
local GLib, Gio = lgi.GLib, lgi.Gio

---@class GInputStreamAsyncHelper
---@field data_stream GDataInputStream?
---@field stream GInputStream
local GioInputStreamAsyncHelper = {
  ---@param self GInputStreamAsyncHelper
  ---@param count integer
  ---@param callback fun(content?: string, error?: userdata):any
  read_bytes = function(self, count, callback)
    return self.stream:read_bytes_async(count, GLib.PRIORITY_DEFAULT, nil, function(source, gtask)
      local gbytes, err = source:read_bytes_finish(gtask)
      return callback(gbytes and gbytes:get_data(), err)
    end)
  end,
  ---@param self GInputStreamAsyncHelper
  get_data_stream = function(self)
    self.data_stream = self.data_stream or Gio.DataInputStream.new(self.stream)
    local type = GLib.SeekType.SET -- From beginning
    self.data_stream:seek(self:tell(), type) -- Sync the offset to the main stream's offset.
    return self.data_stream
  end,
  ---@param self GInputStreamAsyncHelper
  ---Note that line may be nil even if no error occurred! (EOF)
  ---@param callback fun(line?: string, error?: userdata):any
  read_line = function(self, callback)
    local data_stream = self:get_data_stream()
    local old_location = self:tell() -- The old position is lost after read_line_async. Record it here for later.

    return data_stream:read_line_async(-1, nil, function(obj, res)
      local line, length = obj:read_line_finish(res)
      if type(length) ~= "number" then return callback(nil, length) end -- Error
      self:seek(old_location + length + 1, "start") -- Move the main stream position forward -- The old positon is lost! -- Plus 1 for newline
      return callback(line, nil)
    end)
  end,
  ---@param self GInputStreamAsyncHelper
  ---Note that line may be nil even if no error occurred! (EOF)
  ---return `false` to stop reading.
  ---Iteration will stop if an error occurs (done will be called with the error)
  ---@param callback fun(line?: string): boolean?
  ---Called when the operation is done. only called once.
  ---success will be false if cancelled early (by returning false) or true if all lines were read successfully
  ---Note: if an error occurs, success will be false and error will be set. Else if stopped early, success will be false and error will be nil.
  ---Note: The default done callback closes the stream!
  ---@param done? false|fun(success: boolean, error?: userdata): boolean?
  each_line = function(self, callback, done)
    if done == nil then
      -- Cleanup after ourselves
      done = function() return self:close() end
    end
    local function handler(line, err)
      if err then return done and done(false, err) end
      if not line then return done and done(true, nil) end -- All lines were read successfully
      local res = callback(line)
      if res == false then return done and done(false, nil) end -- false means stop
      return self:read_line(handler) -- Loop the next line.
    end
    return self:read_line(handler)
  end,
  ---@param self GInputStreamAsyncHelper
  ---@param count integer
  ---@param callback fun(lines?: string[], error?: userdata):any
  read_lines = function(self, count, callback)
    local data_stream = Gio.DataInputStream.new(self.stream)
    local lines = {}
    local function _read()
      local old_location = self:tell() -- The old position is lost after read_line_async. Record it here for later.
      return data_stream:read_line_async(-1, nil, function(source, task)
        local line, length = source:read_line_finish(task)
        if type(length) ~= "number" then return callback(nil, length) end -- Error
        self:seek(old_location + length + 1, "start") -- Move the main stream position forward -- The old positon is lost! -- Plus 1 for newline

        lines[#lines + 1] = line
        if not line or #lines >= count then return callback(lines, nil) end -- EOF or reached user count!

        return _read()
      end)
    end
    return _read()
  end,
  ---@param self GInputStreamAsyncHelper
  ---@param callback fun(content?: string, error?: userdata):any
  read_to_end = function(self, callback)
    local BLKSZE = 1024 -- block size
    local chunks = {}
    local function handler(data, err) -- Recursive implementation
      if not data then return callback(nil, err) end -- We lose the previous chunks, but whatever.
      chunks[#chunks + 1] = data
      if #data == 0 then -- All the data has been read
        return callback(table.concat(chunks, ""), err)
      end

      return self:read_bytes(BLKSZE, handler)
    end
    return self:read_bytes(BLKSZE, handler)
  end,
  ---@param self GInputStreamAsyncHelper
  ---@param count integer
  ---@param callback fun(skipped?: integer, error?: userdata):any
  skip = function(self, count, callback)
    return self.stream:skip_async(count, -1, nil, function(source, gtask)
      local skipped, err = source:skip_finish(gtask)
      --- Pass nil if skipped is -1
      return callback(skipped == -1 and nil or skipped, err)
    end)
  end,
  ---@param self GInputStreamAsyncHelper
  ---@param offset integer
  ---@param from 'current'|'end'|'start'?
  ---@return boolean success
  ---@return userdata? error
  seek = function(self, offset, from)
    local key_hash = { ["start"] = "SET", ["current"] = "CUR", ["end"] = "END" }
    local key = from and key_hash[from:lower()] or key_hash.start -- Defaults to from start
    local type = GLib.SeekType[key]
    return self.stream:seek(offset, type)
  end,
  ---@param self GInputStreamAsyncHelper
  ---@return integer
  tell = function(self) return self.stream:tell() end,
  ---Note: this is an async close. You can not use the steam after calling this anyways though. Regardless of the possibilty of race conditions.
  ---@param self GInputStreamAsyncHelper
  ---@param callback? fun(suc: boolean, error: string?):any?
  close = function(self, callback)
    return self.stream:close_async(-1, nil, callback and function(source, task)
      local suc, err = source:close_finish(task)
      return callback(suc, err)
    end or nil)
  end,
}

---@param stream GInputStream
---@return GInputStreamAsyncHelper
local function gen_stream_ret(stream) return setmetatable({ stream = stream }, { __index = GioInputStreamAsyncHelper }) end

---Gets a GInputStream and GInputStreamAsyncHelper for the given filepath
---@param path string
---@param callback fun(stream?: GInputStreamAsyncHelper, error?: userdata): any
local function get_stream(path, callback)
  return new_file_for_path(path):read_async(-1, nil, function(file, task)
    local stream, error = file:read_finish(task)
    if not stream then return callback(nil, error) end
    local ret = gen_stream_ret(stream)
    return callback(ret, nil)
  end)
end

return get_stream
