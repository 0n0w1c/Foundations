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
        flags = { "only-in-cursor", "spawnable", "not-stackable" },
        hidden_in_factoriopedia = true,
        draw_label_for_cursor_render = false,
        subgroup = "tool",
        order = "c[automated-construction]-a[blueprint]",
        stack_size = 1,
        select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        },
        alt_select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        }
    }
})

data:extend({
    {
        type = "selection-tool",
        name = "Foundations-unfill-tool",
        icon = "__base__/graphics/icons/deconstruction-planner.png",
        icon_size = 64,
        flags = { "only-in-cursor", "spawnable", "not-stackable" },
        hidden_in_factoriopedia = true,
        draw_label_for_cursor_render = false,
        subgroup = "tool",
        order = "c[automated-construction]-a[blueprint]",
        stack_size = 1,
        select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        },
        alt_select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        }
    }
})

data:extend({
    {
        type = "selection-tool",
        name = "Foundations-place-tool",
        icon = "__base__/graphics/icons/blueprint.png",
        icon_size = 64,
        flags = { "only-in-cursor", "spawnable", "not-stackable" },
        hidden_in_factoriopedia = true,
        draw_label_for_cursor_render = false,
        subgroup = "tool",
        order = "c[automated-construction]-a[blueprint]",
        stack_size = 1,
        select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        },
        alt_select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        }
    }
})

data:extend({
    {
        type = "selection-tool",
        name = "Foundations-unplace-tool",
        icon = "__base__/graphics/icons/deconstruction-planner.png",
        icon_size = 64,
        flags = { "only-in-cursor", "spawnable", "not-stackable" },
        hidden_in_factoriopedia = true,
        draw_label_for_cursor_render = false,
        subgroup = "tool",
        order = "c[automated-construction]-a[blueprint]",
        stack_size = 1,
        select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        },
        alt_select = {
            border_color = { r = 0.7, g = 0.7, b = 0.7 },
            cursor_box_type = "entity",
            mode = { "any-tile" }
        }
    }
})

if settings.startup["Foundations-concrete-variants"].value then
    for _, color in pairs(COLORS) do
        local color_tile = color.name .. "-refined-concrete"

        data.raw["tile"][color_tile].hidden = nil
        data.raw["tile"][color_tile].minable = { mining_time = 0.1, result = color_tile }
        data.raw["tile"][color_tile].transition_overlay_layer_offset = 0
        data.raw["tile"][color_tile].layer_group = "ground-artificial"
        data.raw["tile"][color_tile].layer =
            tonumber(settings.startup["Foundations-" .. color_tile .. "-layer"].value) + 27
        if mods["space-age"] then
            data.raw["tile"][color_tile].frozen_variant = "frozen-refined-concrete"
        end

        table.insert(data.raw.technology["concrete"].effects, { type = "unlock-recipe", recipe = color_tile })
    end

    local group = "logistics"
    local subgroup = "terrain"

    if mods["Dectorio"] and settings.startup["dectorio-item-group"].value and settings.startup["dectorio-item-group"].value then
        group = "dectorio"
        subgroup = "flooring-basic"
    end

    for _, color in pairs(COLORS) do
        local template = util.table.deepcopy(data.raw.item['refined-concrete'])
        if template and template.name then
            template.name = color.name .. "-" .. template.name
            template.localised_name = { "item-name.Foundations-" .. color.name .. "-refined-concrete" }
            template.place_as_tile.result = template.name
            template.group = group
            template.subgroup = subgroup
            template.order = "b[concrete]-e[refined-colors]"
            template.icons = { { icon = template.icon, tint = data.raw["tile"][template.name].tint } }
            template.hidden = nil

            data:extend({ template })
        end
    end

    for _, color in pairs(COLORS) do
        local template = util.table.deepcopy(data.raw.recipe['refined-concrete'])
        if template and template.name then
            template.name = color.name .. "-" .. template.name
            template.enabled = false
            template.ingredients = { { type = "item", name = "refined-concrete", amount = 10 } }
            template.results = { { type = "item", name = template.name, amount = 10 } }
            template.energy_required = 0.25

            data:extend({ template })
        end
    end
end
