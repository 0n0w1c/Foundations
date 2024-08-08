if mods["Dectorio"] and not mods["alien-biomes"]
   and settings.startup["Foundations-stack-concrete"].value
   and settings.startup["dectorio-painted-concrete"].value
then
    local colors = {
        "red",
        "green",
        "blue",
        "orange",
        "yellow",
        "pink",
        "purple",
        "black",
        "brown",
        "cyan",
        "acid"
    }

    -- set stacking order
    for _, color in ipairs(colors) do
        data.raw.tile[color.."-refined-concrete"].layer = settings.startup["Foundations-"..color.."-tile-layer"].value
        data.raw.tile[color.."-refined-concrete"].transition_merges_with_tile = nil
    end

    data.raw.tile["refined-concrete"].layer = settings.startup["Foundations-refined-tile-layer"].value

    -- update the layer for all tiles that merge with refined-concrete
    for _, tile in pairs(data.raw["tile"]) do
        if tile.transition_merges_with_tile and tile.transition_merges_with_tile == "refined-concrete" then
            tile.layer = settings.startup["Foundations-refined-tile-layer"].value
        end
    end
end
