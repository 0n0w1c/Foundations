require("constants")

if mods["quality"] then
    recycling = require("__quality__/prototypes/recycling")
end

if settings.startup["Foundations-added-inventory-rows"].value > 0 then
    data.raw["character"].character.inventory_size =
        data.raw["character"].character.inventory_size +
        settings.startup["Foundations-added-inventory-rows"].value * 10
end

local tiles = data.raw["tile"]
local items = data.raw["item"]
local recipes = data.raw["recipe"]
local concrete_layer = tiles["concrete"].layer

for _, color in pairs(COLORS) do
    local tile_name = color.name .. "-refined-concrete"

    local offset = 28
    if mods["Dectorio"] then offset = 68 end

    if tiles[tile_name] and items[tile_name] then
        tiles[tile_name].transition_overlay_layer_offset = 0
        tiles[tile_name].transition_merges_with_tile = nil
        tiles[tile_name].layer = tonumber(settings.startup["Foundations-" .. tile_name .. "-layer"].value) + offset

        if mods["Dectorio"] then
            items[tile_name].subgroup = items["dect-" .. tile_name].subgroup
            items[tile_name].order = items["dect-" .. tile_name].order
        else
            items[tile_name].subgroup = items["refined-hazard-concrete"].subgroup
            items[tile_name].order = items["refined-hazard-concrete"].order .. "z"
        end

        local hidden = settings.startup["Foundations-concrete-variants"].value == false
        tiles[tile_name].hidden = hidden
        items[tile_name].hidden = hidden
        recipes[tile_name].hidden = hidden
    end
end

if mods["aai-industry"] and tiles["rough-stone-path"] then
    data.raw["tile"]["rough-stone-path"].layer = concrete_layer - 3
end

if mods["space-platform-for-ground"] and tiles["acid-refined-concrete"] and items["stone-brick"] then
    tiles["space-platform-for-ground"].layer = tiles["acid-refined-concrete"].layer + 2
    items["space-platform-for-ground"].subgroup = items["stone-brick"].subgroup
    items["space-platform-for-ground"].order = "00[a-x]"
end

if mods["Dectorio"] then
    if tiles["dect-concrete-grid"] then
        local name = "dect-concrete-grid"

        local template = table.deepcopy(tiles["concrete"])
        template.name = name
        template.minable = { mining_time = 0.1, result = name }
        template.placeable_by = { item = name, count = 1 }
        template.transition_overlay_layer_offset = 0
        template.layer = tiles["acid-refined-concrete"].layer + 1
        template.transition_merges_with_tile = nil
        template.frozen_variant = nil
        template.variants.material_background.picture = "__Dectorio__/graphics/terrain/concrete/grid/hr-concrete.png"

        data.extend({ template })
    end

    if tiles["dect-wood-floor"] then
        tiles["dect-wood-floor"].layer_group = "ground-artificial"
        tiles["dect-wood-floor"].layer = tiles["acid-refined-concrete"].layer + 3
    end

    if tiles["dect-stone-gravel"] then
        tiles["dect-stone-gravel"].layer = concrete_layer - 4
        tiles["dect-stone-gravel"].layer_group = "ground-artificial"
        tiles["dect-coal-gravel"].layer = concrete_layer - 5
        tiles["dect-coal-gravel"].layer_group = "ground-artificial"
        tiles["dect-copper-ore-gravel"].layer = concrete_layer - 6
        tiles["dect-copper-ore-gravel"].layer_group = "ground-artificial"
        tiles["dect-iron-ore-gravel"].layer = concrete_layer - 7
        tiles["dect-iron-ore-gravel"].layer_group = "ground-artificial"
    end

    if settings.startup["dectorio-painted-concrete"] and settings.startup["dectorio-painted-concrete"].value then
        local variants =
        {
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

        for _, variant in pairs(variants) do
            for dir, opp_dir in pairs(directions) do
                local template = table.deepcopy(tiles["hazard-concrete-" .. dir])
                template.name = "dect-paint-" .. variant .. "-" .. dir
                template.minable = { mining_time = 0.1, result = "dect-paint-" .. variant }
                template.placeable_by = { item = "dect-paint-" .. variant, count = 1 }
                template.next_direction = "dect-paint-" .. variant .. "-" .. opp_dir
                template.frozen_variant = nil
                template.variants.material_background.picture =
                    "__Dectorio__/graphics/terrain/concrete/" .. variant .. "-" .. dir .. "/hr-concrete.png"

                local refined_template = table.deepcopy(tiles["refined-hazard-concrete-" .. dir])
                refined_template.name = "dect-paint-refined-" .. variant .. "-" .. dir
                refined_template.minable = { mining_time = 0.1, result = "dect-paint-refined-" .. variant }
                refined_template.placeable_by = { item = "dect-paint-refined-" .. variant, count = 1 }
                refined_template.next_direction = "dect-paint-refined-" .. variant .. "-" .. opp_dir
                refined_template.frozen_variant = nil
                refined_template.variants.material_background.picture =
                    "__Dectorio__/graphics/terrain/refined-concrete/" ..
                    variant .. "-" .. dir .. "/hr-refined-concrete.png"

                data.extend({ template, refined_template })

                if mods["crushing-industry"] then
                    data.raw["recipe"]["dect-paint-" .. variant].ingredients = {}
                    local recipe = data.raw["recipe"]["dect-paint-" .. variant]
                    if recipe then
                        recipe.ingredients = { { type = "item", name = "concrete", amount = 10 } }
                        recipe.category = "crafting"
                    end
                end
            end
        end
    end

    for _, color in pairs(COLORS) do
        local tile_name = "dect-" .. color.name .. "-refined-concrete"

        if items[tile_name] then
            items[tile_name].hidden = true
        end
        if recipes[tile_name] then
            recipes[tile_name].hidden = true
        end
        if recipes[tile_name .. "-recycling"] then
            recipes[tile_name .. "-recycling"].hidden = true
        end
    end

    if mods["space-age"] then
        tiles["frozen-concrete"].layer = concrete_layer + 1
        tiles["frozen-hazard-concrete-left"].layer = concrete_layer + 3
        tiles["frozen-hazard-concrete-right"].layer = concrete_layer + 3

        local refined_concrete_layer = tiles["refined-concrete"].layer
        tiles["frozen-refined-concrete"].layer = refined_concrete_layer + 1
        tiles["frozen-refined-hazard-concrete-left"].layer = refined_concrete_layer + 3
        tiles["frozen-refined-hazard-concrete-right"].layer = refined_concrete_layer + 3
    end

    if mods["space-age"] then
        local subgroup = items["landfill"].subgroup
        items["artificial-yumako-soil"].subgroup = subgroup
        items["artificial-jellynut-soil"].subgroup = subgroup
        items["overgrowth-yumako-soil"].subgroup = subgroup
        items["overgrowth-jellynut-soil"].subgroup = subgroup
        items["ice-platform"].subgroup = subgroup
        items["foundation"].subgroup = subgroup
    end
end

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
