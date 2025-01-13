require("constants")

if (mods["Dectorio"] and settings.startup["dectorio-painted-concrete"] and settings.startup["dectorio-painted-concrete"].value) then
    -- hide the Dectorio colored refined conrete recipes
    for _, color in pairs(COLORS) do
        data.raw["recipe"]["dect-" .. color.name .. "-refined-concrete"].hidden = true
    end

    -- "fix" the Dectorio painted concrete
    local variants = {
        "danger",
        "emergency",
        "caution",
        "radiation",
        "defect",
        "operations",
        "safety"
    }

    local directions =
    {
        ["left"] = "right",
        ["right"] = "left"
    }

    for _, variant in ipairs(variants) do
        for dir, opp_dir in pairs(directions) do
            local tile = data.raw["tile"]["hazard-concrete-" .. dir]
            local template = table.deepcopy(tile)

            template.name = "dect-paint-" .. variant .. "-" .. dir
            template.minable = { mining_time = 0.1, result = "dect-paint-" .. variant }
            template.next_direction = "dect-paint-" .. variant .. "-" .. opp_dir
            template.variants.material_background.picture =
                "__Dectorio__/graphics/terrain/concrete/" .. variant .. "-" .. dir .. "/hr-concrete.png"

            local refined_tile = data.raw["tile"]["refined-hazard-concrete-" .. dir]
            local refined_template = table.deepcopy(refined_tile)

            refined_template.name = "dect-paint-refined-" .. variant .. "-" .. dir
            refined_template.minable = { mining_time = 0.1, result = "dect-paint-refined-" .. variant }
            refined_template.next_direction = "dect-paint-refined-" .. variant .. "-" .. opp_dir
            refined_template.variants.material_background.picture =
                "__Dectorio__/graphics/terrain/refined-concrete/" .. variant .. "-" .. dir .. "/hr-refined-concrete.png"

            data:extend({ template, refined_template })
        end
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
