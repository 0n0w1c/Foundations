------------------------------------------------------------------------------------------------------
-- Get local variables
------------------------------------------------------------------------------------------------------
local collision_mask_util = require("__core__/lualib/collision-mask-util")

local layer = collision_mask_util.get_first_unused_layer()

local types_to_update = {"accumulator", "solar-panel", "radar", "rocket-silo", "boiler", "generator", "reactor", "heat-pipe", "train-stop", "lamp",
                         "beacon", "electric-turret", "fluid-turret", "artillery-turret", "roboport", "electric-energy-interface", "power-switch",
                         "constant-combinator", "arithmetic-combinator", "decider-combinator", "programmable-speaker"}

local types_to_update_nonburner = {"inserter", "furnace", "lab", "assembling-machine", "burner-generator"}

------------------------------------------------------------------------------------------------------
-- Define functions
------------------------------------------------------------------------------------------------------
--function array_has_value(array, value)
--    for _, arr in pairs(array) do
--        if arr == value then
--            return true
--        end
--    end
--    return false
--end

function update_collision_mask(entity)
    if entity.collision_mask then
        table.insert(entity.collision_mask, layer)
    else
        local mask = collision_mask_util.get_mask(entity)
        table.insert(mask, layer)
        entity.collision_mask = mask
    end
end

------------------------------------------------------------------------------------------------------
-- Update prototypes
------------------------------------------------------------------------------------------------------

-- Tiles
for _, tile in pairs(data.raw["tile"]) do
    if not string.find(tile.name, "stone")
        and not string.find(tile.name, "concrete")
        and not string.find(tile.name, "plate")
        and not string.find(tile.name, "foundation")
        and not string.find(tile.name, "dect%-")
    then
        update_collision_mask(tile)
    end
end

-- Regular entities by group
for _, prop in pairs(types_to_update) do
    for _, entity in pairs(data.raw[prop]) do
        if not (string.find(entity.name, "fluidic") and string.find(entity.name, "pole"))
           and entity.name ~= "ll-arc-furnace-reactor"
        then
            update_collision_mask(entity)
        end
    end
end

-- Regular non-burner entities by group
for _, prop in pairs(types_to_update_nonburner) do
    for _, entity in pairs(data.raw[prop]) do
        if not (string.find(entity.name, "fluidic") and string.find(entity.name, "pole"))
           and entity.name ~= "ll-telescope"
           and entity.name ~= "stone-furnace"
        then
            update_collision_mask(entity)
        end
    end
end

-- Electric poles
for _, entity in pairs(data.raw["electric-pole"]) do
    local box = entity.selection_box
    -- Only entities larger than 1.5x1.5 tile
    if (-box[1][1] + box[2][1]) > 1.5 and (-box[1][2] + box[2][2]) > 1.5 then
        if entity.name ~= "fish-pole" then
           update_collision_mask(entity)
        end
    end
end

-- add fluid storage tanks and Fluidic Power accumulators
for _, entity in pairs(data.raw["storage-tank"]) do
    if string.find(entity.name, "fluidic")
        or string.find(entity.name, "storage%-tank")
        or string.find(entity.name, "fluid%-tank")
        or string.find(entity.name, "kr%-fluid%-storage")
    then
        update_collision_mask(entity)
    end
end

-- add Fluidic Power switch
if mods["FluidicPower"] then
    update_collision_mask(data.raw["pump"]["fluidic-power-switch"])
end

-- containers are normally exempt from the foundation requirement
if mods["LunarLandings"] then
    update_collision_mask(data.raw["container"]["ll-landing-pad"])
    update_collision_mask(data.raw["logistic-container"]["ll-mass-driver-requester"])
end

-- add all furnaces in Industrial Revolution 3 (must have same collision mask as upgrade)
if mods["IndustrialRevolution3"] then
    for _, entity in pairs(data.raw["furnace"]) do
        update_collision_mask(entity)
    end
    for _, entity in pairs(data.raw["assembling-machine"]) do
        if string.find(entity.name, "furnace") then
            update_collision_mask(entity)
        end
    end
else
    if mods["aai-industry"] then
        -- aai industry adds stone tiles, require a foundation for stone furnace
        -- upgradable via the upgrade planner
        update_collision_mask(data.raw["furnace"]["stone-furnace"])
    else
        -- stone furnace is required to make a stone brick foundation
        -- next_upgrade collision mask must match, so remove next upgrade
        -- upgrade planner will now ignore them
        data.raw["furnace"]["stone-furnace"].next_upgrade = nil
    end
end

-- add turrets, except early-game turrets depending on settings
for _, entity in pairs(data.raw["ammo-turret"]) do
    if entity.name == "gun-turret" then
        if settings.startup["Foundations-gun-turret-needs-foundation"].value then
            update_collision_mask(entity)
        end
    elseif entity.name == "scattergun-turret" then
        if settings.startup["Foundations-IR3-scattergun-turret-needs-foundation"].value then
            update_collision_mask(entity)
        end
    else
        update_collision_mask(entity)
    end
end
