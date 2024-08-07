data:extend({
    {
        type = "sprite",
        name = "Foundations-disabled",
        filename = "__base__/graphics/icons/deconstruction-planner.png",
        width = 64,
        height = 64,
--        filename = "__core__/graphics/no-recipe.png",
--        width = 101,
--        height = 101,
        priority = "medium"
    }
})

data:extend({
    {
      type = "selection-tool",
      name = "foundations-fill-tool",
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

if not mods["aliend-biomes"] and mods["Dectorio"] then
-- Read settings
local refined_tile_layer = settings.startup["Foundations-refined_tile_layer"].value
local red_tile_layer = settings.startup["Foundations-red_tile_layer"].value
local green_tile_layer = settings.startup["Foundations-green_tile_layer"].value
local blue_tile_layer = settings.startup["Foundations-blue_tile_layer"].value
local orange_tile_layer = settings.startup["Foundations-orange_tile_layer"].value
local yellow_tile_layer = settings.startup["Foundations-yellow_tile_layer"].value
local pink_tile_layer = settings.startup["Foundations-pink_tile_layer"].value
local purple_tile_layer = settings.startup["Foundations-purple_tile_layer"].value
local black_tile_layer = settings.startup["Foundations-black_tile_layer"].value
local brown_tile_layer = settings.startup["Foundations-brown_tile_layer"].value
local cyan_tile_layer = settings.startup["Foundations-cyan_tile_layer"].value
local acid_tile_layer = settings.startup["Foundations-acid_tile_layer"].value

-- Apply settings to tile layers
data.raw.tile["refined-concrete"].layer = refined_tile_layer
--data.raw.tile["red-refined-concrete"].transition_merges_with_tile = "refined-concrete"
data.raw.tile["red-refined-concrete"].layer = red_tile_layer
data.raw.tile["red-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["green-refined-concrete"].layer = green_tile_layer
data.raw.tile["green-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["blue-refined-concrete"].layer = blue_tile_layer
data.raw.tile["blue-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["orange-refined-concrete"].layer = orange_tile_layer
data.raw.tile["orange-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["yellow-refined-concrete"].layer = yellow_tile_layer
data.raw.tile["yellow-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["pink-refined-concrete"].layer = pink_tile_layer
data.raw.tile["pink-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["purple-refined-concrete"].layer = purple_tile_layer
data.raw.tile["purple-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["black-refined-concrete"].layer = black_tile_layer
data.raw.tile["black-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["brown-refined-concrete"].layer = brown_tile_layer
data.raw.tile["brown-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["cyan-refined-concrete"].layer = cyan_tile_layer
data.raw.tile["cyan-refined-concrete"].transition_merges_with_tile = "nil"
data.raw.tile["acid-refined-concrete"].layer = acid_tile_layer
data.raw.tile["acid-refined-concrete"].transition_merges_with_tile = "nil"

-- Log the applied layers for debugging purposes
log(string.format("Refined Tile Layer: %d", refined_tile_layer))
log(string.format("Red Tile Layer: %d", red_tile_layer))
log(string.format("Green Tile Layer: %d", green_tile_layer))
log(string.format("Blue Tile Layer: %d", blue_tile_layer))
log(string.format("Orange Tile Layer: %d", orange_tile_layer))
log(string.format("Yellow Tile Layer: %d", yellow_tile_layer))
log(string.format("Pink Tile Layer: %d", pink_tile_layer))
log(string.format("Purple Tile Layer: %d", purple_tile_layer))
log(string.format("Black Tile Layer: %d", black_tile_layer))
log(string.format("Brown Tile Layer: %d", brown_tile_layer))
log(string.format("Cyan Tile Layer: %d", cyan_tile_layer))
log(string.format("Acid Tile Layer: %d", acid_tile_layer))
end
