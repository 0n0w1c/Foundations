require("constants")

if settings.startup["Foundations-added-inventory-rows"].value > 0 then
    data.raw.character.character.inventory_size = data.raw.character.character.inventory_size +
        (settings.startup["Foundations-added-inventory-rows"].value * 10)
end

local tiles = data.raw["tile"]

for _, tile in pairs(tiles) do
    if tile.minable then
        if settings.startup["Foundations-mining-time"].value > 0 then
            tile.minable.mining_time = tonumber(settings.startup["Foundations-mining-time"].value) or 0.1
        end

        if settings.startup["Foundations-clean-sweep"].value then
            tile.decorative_removal_probability = 1
        end
    end
end

if mods["space-age"] then
    local concrete_layer = tiles["concrete"].layer
    local refined_concrete_layer = tiles["refined-concrete"].layer

    tiles["frozen-concrete"].layer = concrete_layer
    tiles["frozen-hazard-concrete-left"].layer = concrete_layer
    tiles["frozen-hazard-concrete-right"].layer = concrete_layer

    tiles["frozen-refined-concrete"].layer = refined_concrete_layer
    tiles["frozen-refined-hazard-concrete-left"].layer = refined_concrete_layer
    tiles["frozen-refined-hazard-concrete-right"].layer = refined_concrete_layer
end

if (mods["Dectorio"] and settings.startup["dectorio-painted-concrete"] and settings.startup["dectorio-painted-concrete"].value) then
    for _, color in pairs(COLORS) do
        data.raw["recipe"]["dect-" .. color.name .. "-refined-concrete"].hidden = true
        data.raw["item"]["dect-" .. color.name .. "-refined-concrete"].hidden_in_factoriopedia = true
    end

    local tile = data.raw["tile"]["concrete"]
    local layer = tile.layer
    local template = table.deepcopy(tile)
    local name = "dect-concrete-grid"

    template.name = name
    template.minable = { mining_time = 0.1, result = name }
    template.placeable_by = { item = name, count = 1 }
    template.transition_overlay_layer_offset = 0
    template.layer = layer + 3
    --template.transition_merges_with_tile = "concrete"
    template.transition_merges_with_tile = nil
    template.frozen_variant = nil
    template.variants.material_background.picture = "__Dectorio__/graphics/terrain/concrete/grid/hr-concrete.png"

    data.extend({ template })

    -- "fix" for the Dectorio painted concrete
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
            tile = data.raw["tile"]["hazard-concrete-" .. dir]
            template = table.deepcopy(tile)

            template.name = "dect-paint-" .. variant .. "-" .. dir
            template.minable = { mining_time = 0.1, result = "dect-paint-" .. variant }
            template.placeable_by = { item = "dect-paint-" .. variant, count = 1 }
            template.next_direction = "dect-paint-" .. variant .. "-" .. opp_dir
            template.frozen_variant = nil
            template.variants.material_background.picture =
                "__Dectorio__/graphics/terrain/concrete/" .. variant .. "-" .. dir .. "/hr-concrete.png"

            local refined_tile = data.raw["tile"]["refined-hazard-concrete-" .. dir]
            local refined_template = table.deepcopy(refined_tile)

            refined_template.name = "dect-paint-refined-" .. variant .. "-" .. dir
            refined_template.minable = { mining_time = 0.1, result = "dect-paint-refined-" .. variant }
            refined_template.placeable_by = { item = "dect-paint-refined-" .. variant, count = 1 }
            refined_template.next_direction = "dect-paint-refined-" .. variant .. "-" .. opp_dir
            refined_template.frozen_variant = nil
            refined_template.variants.material_background.picture =
                "__Dectorio__/graphics/terrain/refined-concrete/" .. variant .. "-" .. dir .. "/hr-refined-concrete.png"

            data.extend({ template, refined_template })
        end
    end
end
