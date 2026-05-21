require("constants")

FOUNDATIONS_DEFAULT_COVER_TILES = {}
for name, tile in pairs(data.raw.tile or {}) do
    if tile.default_cover_tile then
        FOUNDATIONS_DEFAULT_COVER_TILES[name] = tile.default_cover_tile
    end
end

FOUNDATION = false
if mods["electric-tiles"] and mods["space-platform-for-ground"] then
    FOUNDATION = true
end

data.extend({
    {
        type = "sprite",
        name = "Foundations",
        filename = MOD_PATH .. "/graphics/icons/foundations.png",
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

data.extend({
    {
        type = "shortcut",
        name = "Foundations-toggle-button",
        action = "lua",
        icon = MOD_PATH .. "/graphics/icons/foundations.png",
        icon_size = 64,
        small_icon = MOD_PATH .. "/graphics/icons/foundations-32x32.png",
        small_icon_size = 32,
        associated_control_input = "give-Foundations-toggle-button",
        style = "default",
        toggleable = false,
        order = "f[toggle-button]"
    }
})

require("prototypes/electric-space-platform-foundation")
