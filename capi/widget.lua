---@meta

---@class wibox :AwesomeSignalClassInstance
---@field get_children_by_id fun(self: wibox, name: string): widget[] This is scheduled to be deprecated.
---@field buttons fun(self: wibox, buttons_table?: AwesomeButton[]): AwesomeButton[]?
---@field geometry fun(self: wibox, geometry_table?: AwesomeGeometry): AwesomeGeometry?
---@field struts fun(self: wibox, strut_table?: AwesomeStruts): AwesomeStruts?
---@field setup fun(self: wibox, args: table) same as setting widget after calling wibox.widget(args)
---@field find_widgets fun(self: wibox, x: integer, y: integer): table
---@field to_widget fun(self: wibox): widget Create a widget that reflects the current state of this wibox.
---@field save_to_svg fun(self: wibox, path: string, context?: table): boolean Save a screenshot of the wibox to path.
---@field draw fun(self: wibox) Redraw a wibox. You should never have to call this explicitely because it is automatically called when needed.
---@field bg gears.color?
---@field bgimage CairoSurface | function?
---@field border_color string
---@field border_width integer
---@field cursor string
---@field drawable AwesomeDrawable
---@field fg gears.color?
---@field height integer
---@field input_passthrough boolean
---@field ontop boolean
---@field opacity number
---@field screen AwesomeScreenInstance?
---@field shape gears.shape
---@field shape_bounding CairoSurface
---@field shape_clip CairoSurface
---@field shape_input CairoSurface
---@field type AwesomeClientType
---@field visible boolean
---@field widget widget
---@field width integer
---@field window string
---@field x integer
---@field y integer

---@class widget :AwesomeSignalClassInstance
---@field visible boolean
---@field buttons fun(s: widget, b?: AwesomeButton[]): AwesomeButton[]
---@field children widget[]
---Only available when declaring a widget as a table
---@field get_children_by_id nil | fun(self: widget, id: string): widget[]

---@class wibox.container :widget
---@field replace_widget fun(self: wibox.container, from: widget, to: widget, recursive?: boolean): boolean

---@class widget.imagebox :widget
---@field set_image fun(self: widget.imagebox, image: CairoSurface|string?)

---@class container.background :widget
---@field set_shape fun(self: container.background, shape: gears.shape)
---@field set_bg fun(self: container.background, bg: string)
---@field set_bgimage fun(self: container.background, bg_image: string)

---@class widget.textbox :widget
---@field set_markup_silently fun(self: widget.textbox, markup: string): boolean
---@field set_markup fun(self: widget.textbox, markup: string): boolean
---@field set_text fun(self: widget.textbox, text: string)
---@field get_preferred_size fun(self: widget.textbox, screen: AwesomeScreenInstance): integer, integer

---@class widget.textclock :widget
---@field force_update fun(self: widget.textclock)

---@class awful.widget.tasklist :widget
---@field reset fun(self: awful.widget.tasklist)
---@field add fun(self: awful.widget.tasklist, w: widget)

---@class awful.tooltip
---@field set_markup fun(self: awful.tooltip, markup: string)
---@field set_text fun(self: awful.tooltip, text: string)
---@field add_to_object fun(self: awful.tooltip, w: AwesomeSignalClassInstance)
