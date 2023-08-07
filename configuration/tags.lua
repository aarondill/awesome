---@alias tag boolean
---| string
---| number
---| fun(screen: integer, index: integer, array: table): props: table
---| table --> a table of tag properties, and name to set the display value
--- If icon is given, it will be the only thing shown.
---   Unless name or icon_only=false are specified
--- If true, all default options will be applied.
--- If false, the tag will be skipped.
--- If string or number, it will be cast to a string and used as the name
--- If function, it will be called with the screen, index in the table, and the tags table
---    The function must return a table containing the properties of a tag.
--- If table, passed to awful.tag.add(name, table) to create a new tag.
---@type tag[]
local tags = {
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
}
return tags
