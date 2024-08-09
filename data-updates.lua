require("constants")

-- standardize the tile mining times, to be same as refined-concrete
for _, tile in pairs(data.raw["tile"]) do
    if tile.minable then
        tile.minable.mining_time = data.raw.tile["refined-concrete"].minable.mining_time
        if tile.minable.hardness then
            tile.minable.hardness = nil
        end
    end
end

if mods["Dectorio"] and not mods["alien-biomes"]
   and settings.startup["dectorio-painted-concrete"].value
   and settings.startup["Foundations-stack-concrete"].value
then
    -- set the stacking order by setting the layer
    local refined_layer = settings.startup["Foundations-refined-concrete-layer"].value * 3 + 200
    data.raw.tile["refined-concrete"].layer = refined_layer

    for _, color in ipairs(PAINTED_COLORS) do
        local layer = settings.startup["Foundations-"..color.."-refined-concrete-layer"].value * 3 + 200
        data.raw.tile[color.."-refined-concrete"].layer = layer
        data.raw.tile[color.."-refined-concrete"].transition_merges_with_tile = nil
    end

    -- update the layer for tiles that merge with refined-concrete
    for _, tile in pairs(data.raw["tile"]) do
        if tile.minable then
            if tile.transition_merges_with_tile and tile.transition_merges_with_tile == "refined-concrete" then
                tile.layer = refined_layer
            end
        end
    end
end
