function load_exclusion_name_list()

    global.exclusion_name_list = {
        ["entity-ghost"] = true,
        ["tile-ghost"] = true,
        ["straight-rail"] = true,
        ["curved-rail"] = true
    }

    if settings.global["Foundations-exclude-small-medium-electric-poles"].value then
        global.exclusion_name_list["small-electric-pole"] = true
        global.exclusion_name_list["medium-electric-pole"] = true
    end
end

function load_exclusion_type_list()

    global.exclusion_type_list = {
        ["entity-ghost"] = true,
        ["tile-ghost"] = true,
        ["offshore-pump"] = true,
        ["mining-drill"] = true,
        ["car"] = true,
        ["cargo-wagon"] = true,
        ["fluid-wagon"] = true,
        ["locomotive"] = true,
        ["rail-planner"] = true,
        ["straight-rail"] = true,
        ["rail-signal"] = true,
        ["rail-chain-signal"] = true,
        ["spider-vehicle"] = true
    }

    if settings.global["Foundations-exclude-inserters"].value then
        global.exclusion_type_list["inserter"] = true
    end

    if settings.global["Foundations-exclude-belts"].value then
        global.exclusion_type_list["transport-belt"] = true
        global.exclusion_type_list["underground-belt"] = true
        global.exclusion_type_list["splitter"] = true
        global.exclusion_type_list["loader"] = true
    end
end

-- check if an entity is excluded based on name or type
function entity_excluded(entity)
    if global.exclusion_name_list[entity.name] then
        return true
    end
    if global.exclusion_type_list[entity.type] then
        return true
    end
    return false
end

-- check if the tile is in global.tile_names 
function tile_in_global_tile_names(tile)
    for _, tile_name in ipairs(global.tile_names) do
        if tile_name == tile then
            return true
        end
    end
    return false
end

-- check if the recipe has been enabled
function recipe_enabled(force, recipe_name)
    local recipe = force.recipes[recipe_name]
    if recipe then
        return recipe.enabled
    else
        -- if no recipe, add it (ex. stone to rough-stone-path has no recipe)
        return true
    end
end

-- insert into global.tile_names and global.tile_to_item, if not already present and recipe enabled
function add_to_tables(tile, item)
    local force = game.forces["player"]
    if force and item then
        if not tile_in_global_tile_names(tile) and recipe_enabled(force, item) then
            table.insert(global.tile_names, tile)
            global.tile_to_item[tile] = item
        end
    end
end

function has_collision_mask(collision_mask, mask)
    for _, layer in pairs(collision_mask) do
        if layer == mask then
            return true
        end
    end
    return false
end

-- check if the player has sufficient tiles in their inventory
function player_has_sufficient_tiles(player, tile_name, count)
    local item_name = global.tile_to_item[tile_name]
    return item_name and player.get_item_count(item_name) >= count
end

-- get the collision_box of the entity
function get_entity_collision_box(entity)
    local prototype
    if entity.type == "entity-ghost" then
        prototype = game.entity_prototypes[entity.ghost_prototype.name]
    else
        prototype = entity.prototype
    end
    local collision_box = prototype.collision_box
    return collision_box
end

function get_area_under_entity(entity)
    local position = entity.position
    local collision_box = get_entity_collision_box(entity)
    local area = {}

    -- adjust collision_box based on entity direction
    if entity.direction == defines.direction.east or entity.direction == defines.direction.west then
        area.left_top = {x = position.x + collision_box.left_top.y, y = position.y + collision_box.left_top.x}
        area.right_bottom = {x = position.x + collision_box.right_bottom.y, y = position.y + collision_box.right_bottom.x}
    else
        area.left_top = {x = position.x + collision_box.left_top.x, y = position.y + collision_box.left_top.y}
        area.right_bottom = {x = position.x + collision_box.right_bottom.x, y = position.y + collision_box.right_bottom.y}
    end

    return area
end

function load_tiles(entity, area, tile_name)
    local surface = entity.surface
    local tiles_to_place = {}
    local tiles_to_return = {}

    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local current_tile = surface.get_tile(x, y)
            local search_area = {{x, y}, {x + 1, y + 1}}
            local resources = surface.find_entities_filtered({area = search_area, type = "resource"})

            -- no tiles to be placed on resources
            if #resources > 0 then
                return
            end

            -- check if the tile is a water tile
            -- what about shallow or muddy water?
            if has_collision_mask(current_tile.prototype.collision_mask, "water-tile") then
                return
            end

            -- ground tiles, grass-1, water
--            if not current_tile.prototype.mineable_properties.mineable then
--                return
--            end

            -- track the current tile to return it to the player
            if current_tile.name ~= tile_name then
                local return_item = {name = current_tile.name, count = 1}
                local item_name = global.tile_to_item[current_tile.name]
                return_item.name = item_name
                table.insert(tiles_to_return, return_item)
                table.insert(tiles_to_place, {name = tile_name, position = {x = x, y = y}})
            end
        end
    end

    return tiles_to_place, tiles_to_return
end

function set_current_foundation()
    local found = false

    -- try to find the index for global.foundation
    for index, tile in ipairs(global.tile_names) do
        if tile == global.foundation then
            global.tile_names_index = index
            found = true
            break
        end
    end

    -- global.foundation not found in global.tile_names, reset
    if not found then
        global.tile_names_index = 1
        global.foundation = "disabled"
    end
end

function load_global_data()
    global.foundation = global.foundation or "disabled"

    local AAI_INDUSTRY = game.active_mods["aai-industry"] ~= nil or false
    local DECTORIO = game.active_mods["Dectorio"] ~= nil or false
    local KRASTORIO2 = game.active_mods["Krastorio2"] ~= nil or false
    local LUNARLANDINGS = game.active_mods["LunarLandings"] ~= nil or false
    local SPACE_EXPLORATION = game.active_mods["space-exploration"] ~= nil or false

    load_exclusion_name_list()
    load_exclusion_type_list()

    -- start fresh, tiles could have been added or removed
    global.tile_names = {}

    -- add disabled, at positon 1
    add_to_tables("disabled", "disabled")

    if settings.global["Foundations-stone-path"].value then
        add_to_tables("stone-path", "stone-brick")
    end
    if settings.global["Foundations-concrete"].value then
        add_to_tables("concrete", "concrete")
    end
    if settings.global["Foundations-refined-concrete"].value then
        add_to_tables("refined-concrete", "refined-concrete")
    end
    if settings.global["Foundations-hazard-concrete"].value then
        add_to_tables("hazard-concrete-left", "hazard-concrete")
        add_to_tables("hazard-concrete-right", "hazard-concrete")
    end
    if settings.global["Foundations-refined-hazard-concrete"].value then
        add_to_tables("refined-hazard-concrete-left", "refined-hazard-concrete")
        add_to_tables("refined-hazard-concrete-right", "refined-hazard-concrete")
    end

    if AAI_INDUSTRY then
        compatibility.aai_industry()
    end
    if DECTORIO then
        compatibility.dectorio()
    end
    if KRASTORIO2 then
        compatibility.krastorio2()
    end
    if LUNARLANDINGS then
        compatibility.lunarlandings()
    end
    if SPACE_EXPLORATION then
        compatibility.space_exploration()
    end

    set_current_foundation ()
end
