local collision_mask_util = require("__core__/lualib/collision-mask-util")

local layer = collision_mask_util.get_first_unused_layer()

local foundations = {
    "concrete",
    "stone",
    "plate",
    "foundation",
    "dect%-"
}

local types_to_update = {
    "accumulator", "solar-panel", "radar", "rocket-silo", "boiler", "generator", "reactor", "heat-pipe", "train-stop", "lamp",
    "beacon", "electric-turret", "fluid-turret", "artillery-turret", "roboport", "electric-energy-interface", "power-switch",
    "constant-combinator", "arithmetic-combinator", "decider-combinator", "programmable-speaker", "logistic-container",
    "inserter", "furnace", "lab", "assembling-machine", "burner-generator"
}

local excluded_from_types = {
    "stone-furnace",    -- special handling below
    "ll-telescope",     -- can only be placed on luna mountain surface
    "port",             -- cargo ships
    "bridge_base"       -- cargo ships
}

local excluded_from_containers = {
    "aai-big-ship-wreck-1",
    "aai-big-ship-wreck-2",
    "aai-big-ship-wreck-3",
    "aai-medium-ship-wreck-1",
    "aai-medium-ship-wreck-2",
    "kr-crash-site-assembling-machine-1-repaired",
    "kr-crash-site-assembling-machine-2-repaired",
    "kr-crash-site-lab-repaired",
    "kr-crash-site-generator",
    "crash-site-spaceship",
    "crash-site-chest-1",
    "crash-site-chest-2",
    "big-ship-wreck-1",
    "big-ship-wreck-2",
    "big-ship-wreck-3",
    "crash-site-spaceship-wreck-big-1",
    "crash-site-spaceship-wreck-big-2",
    "crash-site-spaceship-wreck-medium-1",
    "crash-site-spaceship-wreck-medium-2",
    "crash-site-spaceship-wreck-medium-3",
    "factorio-logo-11tiles",
    "factorio-logo-16tiles",
    "factorio-logo-22tiles",
    "wood-pallet",
    "tin-pallet",
    "wooden-chest",
    "iron-chest",
    "steel-chest",
    "tin-chest",
    "bronze-chest"
}

local excluded_from_electrical_poles = {
    "fish-pole",
    "floating-electric-pole"
}

local excluded_from_storage_tanks = {
    "check-value",
    "overflow-valve",
    "underflow-valve",
    "pipe-elbow",
    "pipe-junction",
    "pipe-straight",
    "fluid-level-indicator",
    "fluid-level-indicator-straight"
}

local function is_foundation(tile_name)
    for _, tile in pairs(foundations) do
        if string.find(tile_name, tile) then
            return true
        end
    end
    return false
end

local function in_list(list, item)
    for _, value in pairs(list) do
        if value == item then
            return true
        end
    end
    return false
end

local function update_collision_mask(entity)
    if entity.collision_mask then
        table.insert(entity.collision_mask, layer)
    else
        local mask = collision_mask_util.get_mask(entity)
        table.insert(mask, layer)
        entity.collision_mask = mask
    end
end

-- tiles
for _, tile in pairs(data.raw["tile"]) do
    -- prevent the mining of tiles from underneath entities requiring a foundation
    -- which in turn, prevents the entity from being voided
    tile.check_collision_with_entities = true

    if not is_foundation(tile.name) then
        update_collision_mask(tile)
    end
end

-- entity types without much special handling
for _, type in pairs(types_to_update) do
    for _, entity in pairs(data.raw[type]) do
        if not in_list(excluded_from_types, entity.name) then
            update_collision_mask(entity)
        end
    end
end

-- containers
for _, entity in pairs(data.raw["container"]) do
    if not in_list(excluded_from_containers, entity.name) then
        update_collision_mask(entity)
    end
end

-- electric poles
for _, entity in pairs(data.raw["electric-pole"]) do
    local box = entity.selection_box
    -- Only entities larger than 1.5x1.5 tile
    if (-box[1][1] + box[2][1]) > 1.5 and (-box[1][2] + box[2][2]) > 1.5 then
        if not in_list(excluded_from_electrical_poles, entity.name) then
            update_collision_mask(entity)
        end
    end
end

-- fluid storage tanks
for _, entity in pairs(data.raw["storage-tank"]) do
    if not in_list(excluded_from_storage_tanks, entity.name) then
        update_collision_mask(entity)
    end
end

-- unique items
if mods["IndustrialRevolution3"] then
    update_collision_mask(data.raw["land-mine"]["transfer-plate"])
    update_collision_mask(data.raw["land-mine"]["transfer-plate-2x2"])
end

-- stone furnace
if settings.startup["Foundations-required-stone-furnace"].value then
    if data.raw["furnace"]["stone-furnace"] then
        update_collision_mask(data.raw["furnace"]["stone-furnace"])
    end
    -- some mods (K2) switch types
    if data.raw["assembling-machine"]["stone-furnace"] then
        update_collision_mask(data.raw["assembling-machine"]["stone-furnace"])
    end
else
    -- stone furnace is required to make a stone brick foundation
    -- next_upgrade collision mask must match, so remove next upgrade
    -- upgrade planner will now ignore them
    if data.raw["furnace"]["stone-furnace"] then
        data.raw["furnace"]["stone-furnace"].next_upgrade = nil
    end
    -- some mods (K2) switch types
    if data.raw["assembling-machine"]["stone-furnace"] then
        data.raw["assembling-machine"]["stone-furnace"].next_upgrade = nil
    end
end

-- turrets, except early-game turrets depending on settings
for _, entity in pairs(data.raw["ammo-turret"]) do
    if entity.name == "gun-turret" then
        if settings.startup["Foundations-required-gun-turret"].value then
            update_collision_mask(entity)
        end
    elseif entity.name == "scattergun-turret" then
        if settings.startup["Foundations-required-IR3-scattergun-turret"].value then
            update_collision_mask(entity)
        end
    else
        update_collision_mask(entity)
    end
end
