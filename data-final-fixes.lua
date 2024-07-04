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
    "ll-telescope"      -- can only be placed on luna mountain surface
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
        if not in_list(excluded_from_types, entity.name)
        then
            update_collision_mask(entity)
        end
    end
end

-- containers
for _, entity in pairs(data.raw["container"]) do
    if entity.name ~= "aai-big-ship-wreck-1"
        and entity.name ~= "aai-big-ship-wreck-2"
        and entity.name ~= "aai-big-ship-wreck-3"
        and entity.name ~= "aai-medium-ship-wreck-1"
        and entity.name ~= "aai-medium-ship-wreck-2"
        and entity.name ~= "kr-crash-site-assembling-machine-1-repaired"
        and entity.name ~= "kr-crash-site-assembling-machine-2-repaired"
        and entity.name ~= "kr-crash-site-lab-repaired"
        and entity.name ~= "kr-crash-site-generator"
        and entity.name ~= "crash-site-spaceship"
        and entity.name ~= "crash-site-chest-1"
        and entity.name ~= "crash-site-chest-2"
        and entity.name ~= "big-ship-wreck-1"
        and entity.name ~= "big-ship-wreck-2"
        and entity.name ~= "big-ship-wreck-3"
        and entity.name ~= "crash-site-spaceship-wreck-big-1"
        and entity.name ~= "crash-site-spaceship-wreck-big-2"
        and entity.name ~= "crash-site-spaceship-wreck-medium-1"
        and entity.name ~= "crash-site-spaceship-wreck-medium-2"
        and entity.name ~= "crash-site-spaceship-wreck-medium-3"
        and entity.name ~= "factorio-logo-11tiles"
        and entity.name ~= "factorio-logo-16tiles"
        and entity.name ~= "factorio-logo-22tiles"
        and entity.name ~= "wood-pallet"
        and entity.name ~= "tin-pallet"
        and entity.name ~= "wooden-chest"
        and entity.name ~= "iron-chest"
        and entity.name ~= "steel-chest"
        and entity.name ~= "tin-chest"
        and entity.name ~= "bronze-chest"
    then
        update_collision_mask(entity)
    end
end

-- electric poles
for _, entity in pairs(data.raw["electric-pole"]) do
    local box = entity.selection_box
    -- Only entities larger than 1.5x1.5 tile
    if (-box[1][1] + box[2][1]) > 1.5 and (-box[1][2] + box[2][2]) > 1.5 then
        if entity.name ~= "fish-pole"
            and entity.name ~= "floating-electric-pole"
        then
            update_collision_mask(entity)
        end
    end
end

-- fluid storage tanks
for _, entity in pairs(data.raw["storage-tank"]) do
    -- exclude Flow Control and Fluid Level Indicator
    if entity.name ~= "check-value"
        and entity.name ~= "overflow-valve"
        and entity.name ~= "underflow-valve"
        and entity.name ~= "pipe-elbow"
        and entity.name ~= "pipe-junction"
        and entity.name ~= "pipe-straight"
        and entity.name ~= "fluid-level-indicator"
        and entity.name ~= "fluid-level-indicator-straight"
    then
        update_collision_mask(entity)
    end
end

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
