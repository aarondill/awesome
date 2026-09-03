---@meta

---@class wibox :AwesomeSignalClassInstance

---@class widget :AwesomeSignalClassInstance
---@field visible boolean
---@field buttons fun(s: widget, b?: AwesomeButton[]): AwesomeButton[]
---@field children widget[]
---Only available when declaring a widget as a table
---@field get_children_by_id nil | fun(self: widget, id: string): widget[]
---TODO: rest of the methods

---@class wibox.container :widget
---@field replace_widget fun(self: wibox.container, from: widget, to: widget, recursive?: boolean): boolean
