local compatibility = require("compatibility")

function load_excluded_name_list()
    global.excluded_name_list = EXCLUDED_NAME_LIST
    if settings.global["Foundations-exclude-small-medium-electric-poles"].value then
        global.excluded_name_list["small-electric-pole"] = true
        global.excluded_name_list["medium-electric-pole"] = true
    end
end

function load_excluded_type_list()
    global.excluded_type_list = EXCLUDED_TYPE_LIST
    if settings.global["Foundations-exclude-inserters"].value then
        global.excluded_type_list["inserter"] = true
    end
    if settings.global["Foundations-exclude-belts"].value then
        global.excluded_type_list["transport-belt"] = true
        global.excluded_type_list["underground-belt"] = true
        global.excluded_type_list["splitter"] = true
        global.excluded_type_list["loader"] = true
    end
end

-- check if an entity is excluded based on name or type
function entity_excluded(entity)
    if global.excluded_name_list[entity.name] then
        return true
    end
    if global.excluded_type_list[entity.type] then
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

-- add to global.tile_names and global.tile_to_item, if not already present and recipe enabled
function add_to_global_tables(tile_name, item_name)
    local force = game.forces["player"]

    if force and tile_name and item_name then
        if not tile_in_global_tile_names(tile_name) and recipe_enabled(force, item_name) then
            table.insert(global.tile_names, tile_name)
            global.tile_to_item[tile_name] = item_name
        end
    end
end

-- check if the player has sufficient tiles in their inventory
function player_has_sufficient_tiles(player, tile_name, count)
    local item_name = global.tile_to_item[tile_name]

    return item_name and player.get_item_count(item_name) >= count
end

-- when player does not have sufficent tiles in their inventory
function return_entity_to_cursor(player, entity)
    if not player.cursor_stack.valid_for_read then
        player.cursor_stack.set_stack({name = entity.name, count = 1})
    else
        player.cursor_stack.count = player.cursor_stack.count + 1
    end

    -- build halted
    entity.destroy()
end

-- get the collision_box of the entity
function get_entity_collision_box(entity)
    local prototype

    if entity.type == "entity-ghost" then
        prototype = game.entity_prototypes[entity.ghost_prototype.name]
    else
        prototype = entity.prototype
    end

    return prototype.collision_box
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

function get_mineable_tiles()
    local tiles_to_exclude = TILES_TO_EXCLUDE
    local blueprintable_tiles = game.get_filtered_tile_prototypes{{filter="blueprintable"}}
    local mineable_tiles = {}

    -- filter the blueprintable (minable) tiles to remove excluded tiles
    for name, _ in pairs(blueprintable_tiles) do
        if not tiles_to_exclude[name] then
            mineable_tiles[name] = true
        end
    end

    return mineable_tiles
end

function load_tiles(entity, area)
    local mineable_tiles = get_mineable_tiles()
    local surface = entity.surface
    local tiles_to_place = {}
    local tiles_to_return = {}

    -- check each tile under the entity
    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local current_tile = surface.get_tile(x, y)
            local search_area = {{x, y}, {x + 1, y + 1}}
            local resources = surface.find_entities_filtered({area = search_area, type = "resource"})
            local tiles_to_exclude = TILES_TO_EXCLUDE

            -- check to make sure the tile is not a resource tile or an excluded tile
            if #resources == 0 and not tiles_to_exclude["current_tile.name"] then
                -- prepare to return the current tile and to place a foundation tile
                if current_tile.name ~= global.foundation then
                    if mineable_tiles[current_tile.name] then
                        table.insert(tiles_to_return, {name = current_tile.name, position = {x = x, y = y}})
                    end
                    table.insert(tiles_to_place, {name = global.foundation, position = {x = x, y = y}})
                end
            end
        end
    end

    return tiles_to_place, tiles_to_return
end

function set_global_tile_names_index()
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
        global.foundation = DISABLED
    end
end

function load_global_data()
    global.foundation = global.foundation or DISABLED
    global.player_index = global.player_index or 1

    load_excluded_name_list()
    load_excluded_type_list()

    -- start fresh, tiles could have been added or removed
    global.tile_names = {}

    -- add disabled, at positon 1
    add_to_global_tables(DISABLED, DISABLED)

    if settings.global["Foundations-stone-path"].value then
        add_to_global_tables("stone-path", "stone-brick")
    end
    if settings.global["Foundations-concrete"].value then
        add_to_global_tables("concrete", "concrete")
    end
    if settings.global["Foundations-refined-concrete"].value then
        add_to_global_tables("refined-concrete", "refined-concrete")
    end
    if settings.global["Foundations-hazard-concrete"].value then
        add_to_global_tables("hazard-concrete-left", "hazard-concrete")
        add_to_global_tables("hazard-concrete-right", "hazard-concrete")
    end
    if settings.global["Foundations-refined-hazard-concrete"].value then
        add_to_global_tables("refined-hazard-concrete-left", "refined-hazard-concrete")
        add_to_global_tables("refined-hazard-concrete-right", "refined-hazard-concrete")
    end

    if game.active_mods["aai-industry"] then
        compatibility.aai_industry()
    end
    if game.active_mods["Dectorio"] then
        compatibility.dectorio()
    end
    if game.active_mods["Krastorio2"] then
        compatibility.krastorio2()
    end
    if game.active_mods["LunarLandings"] then
        compatibility.lunarlandings()
    end
    if game.active_mods["space-exploration"] then
        compatibility.space_exploration()
    end

    set_global_tile_names_index ()
end
