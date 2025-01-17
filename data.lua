require("constants")

data.extend({
--    {
--        type = "custom-input",
--        name = "tile-selection",
--        key_sequence = "mouse-button-1"
--    },
    {
        type = "custom-input",
        name = "close-tile-selector-e",
        key_sequence = "E"
    },
    {
        type = "custom-input",
        name = "close-tile-selector-esc",
        key_sequence = "ESCAPE"
    }
})

data.extend({
    {
        type = "sprite",
        name = "Foundations-disabled",
        filename = MOD_PATH .. "/graphics/icons/disabled.png",
        width = 64,
        height = 64,
        priority = "medium"
    }
})

data.extend({
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

data.extend({
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

data.extend({
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

data.extend({
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

        data.raw["tile"][color_tile].name = color_tile
        data.raw["tile"][color_tile].hidden = nil
        data.raw["tile"][color_tile].minable = { mining_time = 0.1, result = color_tile }
        data.raw["tile"][color_tile].placeable_by = { item = color_tile, count = 1 }
        data.raw["tile"][color_tile].transition_overlay_layer_offset = 0
        data.raw["tile"][color_tile].layer_group = "ground-artificial"
        data.raw["tile"][color_tile].layer =
            tonumber(settings.startup["Foundations-" .. color_tile .. "-layer"].value) + 27
    end

    for _, color in pairs(COLORS) do
        local template = util.table.deepcopy(data.raw.item["refined-concrete"])
        local name = color.name .. "-refined-concrete"

        if template then
            template.name = name
            template.place_as_tile.result = name
            template.group = "logisitics"
            template.subgroup = "terrain"
            template.order = "b[concrete]-e[refined-colors]"
            template.icons = { { icon = template.icon, tint = data.raw["tile"][name].tint } }

            data.extend({ template })
        end
    end

    for _, color in pairs(COLORS) do
        local template = util.table.deepcopy(data.raw.recipe["refined-concrete"])
        local name = color.name .. "-refined-concrete"

        if template then
            template.name = name
            template.enabled = false
            template.ingredients = { { type = "item", name = "refined-concrete", amount = 10 } }
            template.results = { { type = "item", name = template.name, amount = 10 } }
            template.energy_required = 0.25

            data.extend({ template })
        end

        table.insert(data.raw.technology["concrete"].effects, { type = "unlock-recipe", recipe = name })
    end
end
