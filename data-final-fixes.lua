------------------------------------------------------------------------------------------------------
-- Get local variables
------------------------------------------------------------------------------------------------------
local collision_mask_util = require("__core__/lualib/collision-mask-util")

local layer = collision_mask_util.get_first_unused_layer()

--local types_to_update = {"accumulator", "solar-panel", "lab", "radar", "rocket-silo", "boiler", "generator", "reactor",
--                         "train-stop", "beacon", "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret"}
local types_to_update = {"accumulator", "solar-panel", "lab", "radar", "rocket-silo", "boiler", "generator", "reactor",
                         "train-stop", "beacon", "roboport", "electric-energy-interface"}
local types_to_update_nonburner = {"inserter", "furnace", "assembling-machine"}

------------------------------------------------------------------------------------------------------
-- Define functions
------------------------------------------------------------------------------------------------------
function array_has_value(array, value)
    for _, arr in pairs(array) do
        if arr == value then
            return true
        end
    end
    return false
end

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
    -- Update only non-stone based tiles
    if not string.find(tile.name, "stone")
        and not string.find(tile.name, "concrete")
        and not string.find(tile.name, "plate")
    then
        update_collision_mask(tile)
    end
end

-- Regular entities by group
for _, prop in pairs(types_to_update) do
    for _, entity in pairs(data.raw[prop]) do
        if not (string.find(entity.name, "fluidic") and string.find(entity.name, "pole")) then
            update_collision_mask(entity)
        end
    end
end

-- Regular non-burner entities by group
for _, prop in pairs(types_to_update_nonburner) do
    for _, entity in pairs(data.raw[prop]) do
        if not (string.find(entity.name, "fluidic") and string.find(entity.name, "pole")) then
            if entity.energy_source.type ~= "burner" then
                update_collision_mask(entity)
            end
        end
    end
end

-- Electric poles
for _, entity in pairs(data.raw["electric-pole"]) do
    local box = entity.selection_box
    -- Only entities bigger than 1.5x1.5 tile
    if (-box[1][1] + box[2][1]) > 1.5 and (-box[1][2] + box[2][2]) > 1.5 then
        update_collision_mask(entity)
    end
end

-- fluid storage tanks and Fluidic Power accumulators
for _, entity in pairs(data.raw["storage-tank"]) do
    if (string.find(entity.name, "fluidic")
        or string.find(entity.name, "storage%-tank")
        or string.find(entity.name, "kr%-fluid%-storage"))
    then
        update_collision_mask(entity)
    end
end

-- Fluidic Power switch
for _, entity in pairs(data.raw["pump"]) do
    if string.find(entity.name, "fluidic") then
        update_collision_mask(entity)
    end
end
