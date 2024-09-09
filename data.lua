util = util or require('__core__/lualib/util')
settings = settings or {}
data = data or {}
mods = mods or {}

require("constants")

data:extend({
    {
        type = "sprite",
        name = "Foundations-disabled",
        filename = "__Foundations__/graphics/icons/disabled.png",
        width = 64,
        height = 64,
        priority = "medium"
    }
})

data:extend({
    {
      type = "selection-tool",
      name = "Foundations-fill-tool",
      icon = "__base__/graphics/icons/blueprint.png",
      icon_size = 64,
      flags = {},
      subgroup = "tool",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      alt_selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"any-tile"},
      selection_cursor_box_type = "entity",
      alt_selection_cursor_box_type = "entity",
    }
})
data:extend({
    {
      type = "selection-tool",
      name = "Foundations-unfill-tool",
      icon = "__base__/graphics/icons/deconstruction-planner.png",
      icon_size = 64,
      flags = {},
      subgroup = "tool",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      alt_selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"any-tile"},
      selection_cursor_box_type = "entity",
      alt_selection_cursor_box_type = "entity",
    }
})
data:extend({
    {
      type = "selection-tool",
      name = "Foundations-place-tool",
      icon = "__base__/graphics/icons/blueprint.png",
      icon_size = 64,
      flags = {},
      subgroup = "tool",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      alt_selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"any-tile"},
      selection_cursor_box_type = "entity",
      alt_selection_cursor_box_type = "entity",
    }
})
data:extend({
    {
      type = "selection-tool",
      name = "Foundations-unplace-tool",
      icon = "__base__/graphics/icons/deconstruction-planner.png",
      icon_size = 64,
      flags = {},
      subgroup = "tool",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      alt_selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"any-tile"},
      selection_cursor_box_type = "entity",
      alt_selection_cursor_box_type = "entity",
    }
})

if not mods["Dectorio"] and settings.startup["Foundations-supply-concrete"].value then
    -- add placement items for each color
    for _, color in pairs(COLORS) do
        local template = util.table.deepcopy(data.raw.item['refined-concrete'])
        -- make local name then add item name
        if template and template.name then
            template.localised_name = {"", {"color."..color.name}, " ", {"tile-name."..template.name}}
            template.name = color.name.."-"..template.name
            -- tint icon
            template.icons = {{
                icon = template.icon,
                tint = color.rgb_color
            }}
            template.icon = nil
--            template.order = 'b[concrete]-e[refined-' .. color.name .. ']'
            template.place_as_tile =
            {
              result = template.name,
              condition_size = 1,
              condition = { "water-tile" }
            }
            data:extend({template})
        end
    end

    -- Add recipes for each color
    for _, color in pairs(COLORS) do
        local template = util.table.deepcopy(data.raw.recipe['refined-concrete'])
        if template and template.name then
            template.localised_name = {"", {"color."..color.name}, " ", {"tile-name."..template.name}}
            template.name = color.name.."-"..template.name
            template.category = "crafting"
--            template.order = "a[artificial]-c[tier-3]-b[refined-concrete]"
            template.enabled = false
            template.ingredients = {
                {"refined-concrete", 10}
            }
            if mods["IndustrialRevolution3"] then
                template.subgroup = "ir-tiles"
            end
            template.energy_required = 0.25
            template.result = template.name
            data:extend({template})
        end
    end
end
