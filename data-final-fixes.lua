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

local offset = 31
if mods["Dectorio"] then offset = 71 end

for _, color in pairs(COLORS) do
    local tile_name = color.name .. "-refined-concrete"

    if tiles[tile_name] and items[tile_name] then
        tiles[tile_name].transition_overlay_layer_offset = 0
        tiles[tile_name].transition_merges_with_tile = nil
        tiles[tile_name].minable = { mining_time = 0.5, results = { { type = "item", name = tile_name, amount = 1 } } }
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

local highest_layer = offset + 11
local lowest_layer = concrete_layer - 2

if mods["aai-industry"] and tiles["rough-stone-path"] then
    lowest_layer = lowest_layer - 1
    data.raw["tile"]["rough-stone-path"].layer = lowest_layer
end

if mods["Dectorio"] and tiles["dect-stone-gravel"] then
    lowest_layer = lowest_layer - 1
    tiles["dect-stone-gravel"].layer = lowest_layer
    tiles["dect-stone-gravel"].layer_group = "ground-artificial"

    lowest_layer = lowest_layer - 1
    tiles["dect-coal-gravel"].layer = lowest_layer
    tiles["dect-coal-gravel"].layer_group = "ground-artificial"

    lowest_layer = lowest_layer - 1
    tiles["dect-copper-ore-gravel"].layer = lowest_layer
    tiles["dect-copper-ore-gravel"].layer_group = "ground-artificial"

    lowest_layer = lowest_layer - 1
    tiles["dect-iron-ore-gravel"].layer = lowest_layer
    tiles["dect-iron-ore-gravel"].layer_group = "ground-artificial"
end

if mods["AsphaltRoadsPatched"] then
    lowest_layer = lowest_layer - 1

    for _, tile in pairs(tiles) do
        if string.match(tile.name, "^Arci") then
            tile.layer = lowest_layer
        end
    end
end

if mods["Dectorio"] and tiles["dect-concrete-grid"] then
    local name = "dect-concrete-grid"
    local template = table.deepcopy(tiles["concrete"])

    template.name = name
    template.minable = { mining_time = 0.1, result = name }
    template.placeable_by = { item = name, count = 1 }
    template.transition_overlay_layer_offset = 0
    highest_layer = highest_layer + 1
    template.layer = highest_layer
    template.transition_merges_with_tile = nil
    template.frozen_variant = nil
    template.variants.material_background.picture = "__Dectorio__/graphics/terrain/concrete/grid/hr-concrete.png"

    data.extend({ template })
end

if mods["Dectorio"] and tiles["dect-wood-floor"] then
    highest_layer = highest_layer + 3
    tiles["dect-wood-floor"].layer_group = "ground-artificial"
    tiles["dect-wood-floor"].layer = highest_layer
end

if mods["electric-tiles"] then
    if tiles["F077ET-stone-path"] then
        highest_layer = highest_layer + 3
        tiles["F077ET-stone-path"].layer = highest_layer
    end

    if tiles["F077ET-concrete"] then
        highest_layer = highest_layer + 3
        tiles["F077ET-concrete"].layer = highest_layer
    end

    if tiles["F077ET-refined-concrete"] then
        highest_layer = highest_layer + 3
        tiles["F077ET-refined-concrete"].layer = highest_layer
    end
end

if mods["Dectorio"] then
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

if mods["space-platform-for-ground"] then
    highest_layer = highest_layer + 1
    tiles["space-platform-for-ground"].layer = highest_layer

    items["space-platform-for-ground"].subgroup = items["stone-brick"].subgroup
    items["space-platform-for-ground"].order = "00[a-x]"
end

FOUNDATION = false
if mods["electric-tiles"] and mods["space-platform-for-ground"] then
    if settings.startup["Foundations-space-platform-foundation"] then
        FOUNDATION = settings.startup["Foundations-space-platform-foundation"].value == true
    end
end

if FOUNDATION then
    ElectricTilesDataInterface.adaptTilePrototype({
        {
            tile = data.raw.tile["esp-foundation"],
            item = data.raw.item["esp-foundation"],
            recipe = data.raw.recipe["esp-foundation"],
            others = { add_copper_wire_icon = true },
            technology = { "electric-tiles-tech" }
        }
    })

    local electric_foundation = "F077ET-esp-foundation"
    local recipe = recipes[electric_foundation]
    if recipe then
        recipe.results = { { type = "item", name = electric_foundation, amount = 10 } }
    end

    --lowest_layer = lowest_layer - 1
    --tiles[electric_foundation].layer = lowest_layer
    table.insert(data.raw["technology"]["electric-tiles-tech"].prerequisites, "landfill")

    for _, tile in pairs(tiles) do
        if string.sub(tile.name, 1, 7) == "F077ET-" and tile.name ~= electric_foundation then
            if tile.minable then
                tile.minable.results = { { type = "item", name = electric_foundation, amount = 1 } }
            end
        end
    end

    for _, recipe in pairs(recipes) do
        if string.sub(recipe.name, 1, 7) == "F077ET-" and recipe.name ~= electric_foundation then
            if recipe then
                recipe.hidden = true
            end
        end
    end
end
