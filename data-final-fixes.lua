require("constants")

if settings.startup["Foundations-added-inventory-rows"].value > 0 then
    data.raw.character.character.inventory_size = data.raw.character.character.inventory_size +
        (settings.startup["Foundations-added-inventory-rows"].value * 10)
end

if mods["quality"] then
    recycling = require("__quality__/prototypes/recycling")
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

local hidden = settings.startup["Foundations-concrete-variants"].value == false

for _, color in pairs(COLORS) do
    local color_tile = color.name .. "-refined-concrete"

    local offset = 0
    if mods["Dectorio"] then
        offset = 65
    end

    tiles[color_tile].name = color_tile
    tiles[color_tile].hidden = hidden
    tiles[color_tile].minable = { mining_time = 0.1, result = color_tile }
    tiles[color_tile].placeable_by = { item = color_tile, count = 1 }
    tiles[color_tile].transition_overlay_layer_offset = 0
    tiles[color_tile].frozen_variant = nil
    tiles[color_tile].layer_group = "ground-artificial"
    tiles[color_tile].layer = tonumber(settings.startup["Foundations-" .. color_tile .. "-layer"].value) + 27 + offset
end

for _, color in pairs(COLORS) do
    local template = table.deepcopy(data.raw.item["refined-concrete"])
    local name = color.name .. "-refined-concrete"

    if template then
        template.name = name
        template.place_as_tile.result = name
        template.subgroup = "terrain"
        template.hidden = hidden
        template.order = "b[concrete]-e[refined-colors]"
        template.icons = { { icon = template.icon, tint = data.raw["tile"][name].tint } }

        data.extend({ template })
    end
end

for _, color in pairs(COLORS) do
    local template = table.deepcopy(data.raw.recipe["refined-concrete"])
    local name = color.name .. "-refined-concrete"

    if template then
        template.name = name
        template.enabled = false
        template.hidden = hidden
        template.ingredients = { { type = "item", name = "refined-concrete", amount = 10 } }
        template.results = { { type = "item", name = template.name, amount = 10 } }
        template.energy_required = 0.25
        template.auto_recycle = true

        data.extend({ template })

        if mods["quality"] then
            recycling.generate_recycling_recipe(template)
        end
    end

    table.insert(data.raw.technology["concrete"].effects, { type = "unlock-recipe", recipe = name })
end

if mods["space-platform-for-ground"] and tiles["acid-refined-concrete"] and data.raw["item"]["stone-brick"] then
    tiles["space-platform-for-ground"].layer = tiles["acid-refined-concrete"].layer + 2
    data.raw["item"]["space-platform-for-ground"].subgroup = data.raw["item"]["stone-brick"].subgroup
    data.raw["item"]["space-platform-for-ground"].order = "00[a-x]"
end

if mods["Dectorio"] then
    local tile = data.raw["tile"]["concrete"]
    local layer = tile.layer

    if data.raw["item"]["dect-concrete-grid"] then
        local template = table.deepcopy(tile)
        local name = "dect-concrete-grid"

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
        tiles["dect-stone-gravel"].layer = layer - 3
        tiles["dect-stone-gravel"].layer_group = "ground-natural"
        tiles["dect-coal-gravel"].layer = layer - 4
        tiles["dect-coal-gravel"].layer_group = "ground-natural"
        tiles["dect-copper-ore-gravel"].layer = layer - 5
        tiles["dect-copper-ore-gravel"].layer_group = "ground-natural"
        tiles["dect-iron-ore-gravel"].layer = layer - 6
        tiles["dect-iron-ore-gravel"].layer_group = "ground-natural"
    end

    for _, color in pairs(COLORS) do
        local item = data.raw["item"][color.name .. "-refined-concrete"]

        if item and settings.startup["Foundations-concrete-variants"] then
            item.subgroup = data.raw["item"]["refined-hazard-concrete"].subgroup
            item.order = "00[c-refined-variants]"
        end

        if data.raw["recipe"]["dect-" .. color.name .. "-refined-concrete"] then
            data.raw["recipe"]["dect-" .. color.name .. "-refined-concrete"].hidden = true
            data.raw["item"]["dect-" .. color.name .. "-refined-concrete"].hidden_in_factoriopedia = true
        end
    end

    if settings.startup["dectorio-painted-concrete"] and settings.startup["dectorio-painted-concrete"].value then
        local variants = {
            "danger",
            "emergency",
            "caution",
            "radiation",
            "defect",
            "operations",
            "safety"
        }

        local directions = {
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
                    "__Dectorio__/graphics/terrain/refined-concrete/" ..
                    variant .. "-" .. dir .. "/hr-refined-concrete.png"

                data.extend({ template, refined_template })
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

    if mods["space-age"] then
        local items = data.raw["item"]
        local subgroup = items["landfill"].subgroup

        items["artificial-yumako-soil"].subgroup = subgroup
        items["artificial-jellynut-soil"].subgroup = subgroup
        items["overgrowth-yumako-soil"].subgroup = subgroup
        items["overgrowth-jellynut-soil"].subgroup = subgroup
        items["ice-platform"].subgroup = subgroup
        items["foundation"].subgroup = subgroup
    end
end
