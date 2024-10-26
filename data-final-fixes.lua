require("constants")

if settings.startup["Foundations-concrete-variants"].value then
    for _, color in pairs(COLORS) do
        local color_tile = color.name .. "-refined-concrete"

        data.raw["tile"][color_tile].hidden = nil
        data.raw["tile"][color_tile].subgroup = "artificial-tiles"
        data.raw["tile"][color_tile].layer_group = "ground-artificial"
        --data.raw["tile"][color_tile].frozen_variant = "frozen-refined-concrete"
        data.raw["tile"][color_tile].minable = {
            mining_time = 0.1,
            result = color_tile
        }

        table.insert(data.raw.technology["concrete"].effects,
            { type = "unlock-recipe", recipe = color_tile })
    end
end

for _, tile in pairs(data.raw["tile"]) do
    if tile.minable then
        if settings.startup["Foundations-mining-time"].value > 0 then
            tile.minable.mining_time = tonumber(settings.startup["Foundations-mining-time"].value) or 0.1
        end

        if settings.startup["Foundations-clean-sweep"].value then
            tile.decorative_removal_probability = 1
        end
    end
end

if settings.startup["Foundations-added-inventory-rows"].value > 0 then
    data.raw.character.character.inventory_size = data.raw.character.character.inventory_size +
        (settings.startup["Foundations-added-inventory-rows"].value * 10)
end
