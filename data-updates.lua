if mods["Dectorio"] and not mods["alien-biomes"] and settings.startup["Foundations-stack-concrete"].value then
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

    -- update the layer for all tiles that merge with refined-concrete
    for _, tile in pairs(data.raw["tile"]) do
        if tile.transition_merges_with_tile and tile.transition_merges_with_tile == "refined-concrete" then
            tile.layer = refined_tile_layer
        end
    end

    data.raw.tile["refined-concrete"].layer = refined_tile_layer
    data.raw.tile["red-refined-concrete"].layer = red_tile_layer
    data.raw.tile["red-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["green-refined-concrete"].layer = green_tile_layer
    data.raw.tile["green-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["blue-refined-concrete"].layer = blue_tile_layer
    data.raw.tile["blue-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["orange-refined-concrete"].layer = orange_tile_layer
    data.raw.tile["orange-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["yellow-refined-concrete"].layer = yellow_tile_layer
    data.raw.tile["yellow-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["pink-refined-concrete"].layer = pink_tile_layer
    data.raw.tile["pink-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["purple-refined-concrete"].layer = purple_tile_layer
    data.raw.tile["purple-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["black-refined-concrete"].layer = black_tile_layer
    data.raw.tile["black-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["brown-refined-concrete"].layer = brown_tile_layer
    data.raw.tile["brown-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["cyan-refined-concrete"].layer = cyan_tile_layer
    data.raw.tile["cyan-refined-concrete"].transition_merges_with_tile = nil
    data.raw.tile["acid-refined-concrete"].layer = acid_tile_layer
    data.raw.tile["acid-refined-concrete"].transition_merges_with_tile = nil
end
