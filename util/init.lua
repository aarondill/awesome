local mt = {
	__index = function(_, key)
		return require("util." .. key)
	end,
}
return setmetatable({}, mt)
