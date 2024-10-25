require("constants")
require("technology")

if not mods["Dectorio"] and settings.startup["Foundations-supply-concrete"].value then
    for _, color in pairs(COLORS) do
        data.raw.tile[color.name .. "-refined-concrete"].layer = data.raw.tile["refined-concrete"].layer + 1
        data.raw.tile[color.name .. "-refined-concrete"].transition_merges_with_tile = nil
        data.raw.tile[color.name .. "-refined-concrete"].minable = {
            mining_time = data.raw.tile["refined-concrete"].minable.mining_time,
            hardness = nil,
            --            order = "a[artificial]-c[tier-3]-b[refined-concrete]",
            result = color.name .. "-refined-concrete"
        }
    end

    if not mods["alien-biomes"] then
        if settings.startup["Foundations-layer-concrete"].value then
            -- set the layering order by setting the layer
            local refined_layer = settings.startup["Foundations-refined-concrete-layer"].value * 3 + 200
            data.raw.tile["refined-concrete"].layer = refined_layer

            for _, color in pairs(COLORS) do
                local layer = settings.startup["Foundations-" .. color.name .. "-refined-concrete-layer"].value * 3 + 200
                data.raw.tile[color.name .. "-refined-concrete"].layer = layer
                data.raw.tile[color.name .. "-refined-concrete"].transition_merges_with_tile = nil
            end

            -- update the layer for tiles that merge with refined-concrete
            for _, tile in pairs(data.raw["tile"]) do
                if tile.minable then
                    if tile.transition_merges_with_tile and tile.transition_merges_with_tile == "refined-concrete" then
                        tile.layer = settings.startup["Foundations-refined-concrete-layer"].value * 3 + 200
                    end
                end
            end
        end
    end
end

if mods["Dectorio"] and (not mods["alien-biomes"])
    and settings.startup["dectorio-painted-concrete"].value
    and settings.startup["Foundations-layer-concrete"].value
then
    -- set the layering order by setting the layer
    local refined_layer = settings.startup["Foundations-refined-concrete-layer"].value * 3 + 200
    data.raw.tile["refined-concrete"].layer = refined_layer

    -- set wood floor to be top layer
    if settings.startup["dectorio-wood"].value and data.raw.tile["dect-wood-floor"] then
        data.raw.tile["dect-wood-floor"].layer = WOOD_LAYER
    end

    for _, color in pairs(COLORS) do
        local layer = settings.startup["Foundations-" .. color.name .. "-refined-concrete-layer"].value * 3 + 200
        data.raw.tile[color.name .. "-refined-concrete"].layer = layer
        data.raw.tile[color.name .. "-refined-concrete"].transition_merges_with_tile = nil
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

if mods["Krastorio2"] and (not mods["alien-biomes"])
    and settings.startup["Foundations-layer-concrete"].value
then
    data.raw.tile["kr-white-reinforced-plate"].layer = WHITE_REINFORCED_LAYER
    data.raw.tile["kr-black-reinforced-plate"].layer = BLACK_REINFORCED_LAYER
end
