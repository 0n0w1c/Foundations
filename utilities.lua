function load_excluded_name_list()
    storage.excluded_name_list = {}

    for key, value in pairs(EXCLUDED_NAME_LIST) do
        storage.excluded_name_list[key] = value
    end

    if settings.global["Foundations-exclude-small-medium-electric-poles"].value then
        storage.excluded_name_list["small-electric-pole"] = true
        storage.excluded_name_list["medium-electric-pole"] = true

        if script.active_mods["aai-industry"] then
            storage.excluded_name_list["small-iron-electric-pole"] = true
        end
    end
end

function load_excluded_type_list()
    storage.excluded_type_list = {}

    for key, value in pairs(EXCLUDED_TYPE_LIST) do
        storage.excluded_type_list[key] = value
    end

    if settings.global["Foundations-exclude-inserters"].value then
        storage.excluded_type_list["inserter"] = true
    end

    if settings.global["Foundations-exclude-belts"].value then
        storage.excluded_type_list["transport-belt"] = true
        storage.excluded_type_list["underground-belt"] = true
        storage.excluded_type_list["splitter"] = true
        storage.excluded_type_list["loader"] = true
    end
end

-- check if an entity is excluded based on name or type
function entity_excluded(entity)
    if entity and (storage.excluded_name_list[entity.name] or storage.excluded_type_list[entity.type]) then
        return true
    end

    return false
end

-- check if the tile is in storage.tile_names
function tile_in_global_tile_names(tile)
    if tile then
        for _, tile_name in ipairs(storage.tile_names) do
            if tile_name == tile then
                return true
            end
        end
    end

    return false
end

-- check if the recipe has been enabled
function recipe_enabled(force, recipe_name)
    if not force or not recipe_name then
        return false
    end

    local recipe = force.recipes[recipe_name]
    if recipe then
        return recipe.enabled
    end

    -- no recipe (ex. stone to rough-stone-path has no recipe)
    return true
end

-- add to storage.tile_names, if not already present and recipe enabled
function add_to_global_tile_names(tile_name, item_name)
    local force = game.forces["player"]

    if force and tile_name and item_name then
        if not tile_in_global_tile_names(tile_name) and recipe_enabled(force, item_name) then
            table.insert(storage.tile_names, tile_name)
        end
    end
end

-- add to storage.tile_to_item, if not already present and recipe enabled
function add_to_global_tile_to_item(tile_name, item_name)
    local force = game.forces["player"]

    if force and tile_name and item_name then
        if not storage.tile_to_item[tile_name] and recipe_enabled(force, item_name) then
            storage.tile_to_item[tile_name] = item_name
        end
    end
end

-- check if the player has sufficient tiles in their inventory
function player_has_sufficient_tiles(player, tile_name, count)
    if not player or not tile_name or count == nil then
        return false
    end

    local item_name = storage.tile_to_item[tile_name]
    return item_name and player.get_item_count(item_name) >= count
end

-- when player does not have sufficent tiles in their inventory
function return_entity_to_cursor(player, entity)
    if not player or not entity or not entity.valid or not entity.prototype then return end

    if not player.cursor_stack.valid_for_read then
        player.cursor_stack.set_stack({ name = entity.name, count = 1 })
    else
        player.cursor_stack.count = player.cursor_stack.count + 1
    end

    -- build halted
    entity.destroy()
end

-- check if a position is within an area
function within_area(position, area)
    if not position or not area then
        return false
    end

    return position.x >= area.left_top.x and position.x < area.right_bottom.x and
        position.y >= area.left_top.y and position.y < area.right_bottom.y
end

function get_area_under_entity(entity)
    if not entity then
        return
    end

    local position = entity.position
    local collision_box = entity.prototype.collision_box
    if not position or not collision_box then
        return
    end

    local area = {}

    -- adjust collision_box based on entity direction
    if entity.direction == defines.direction.east or entity.direction == defines.direction.west then
        area.left_top = {
            x = math.floor(position.x + collision_box.left_top.y),
            y = math.floor(position.y + collision_box.left_top.x)
        }
        area.right_bottom = {
            x = math.ceil(position.x + collision_box.right_bottom.y),
            y = math.ceil(position.y + collision_box.right_bottom.x)
        }
    else
        area.left_top = {
            x = math.floor(position.x + collision_box.left_top.x),
            y = math.floor(position.y + collision_box.left_top.y)
        }
        area.right_bottom = {
            x = math.ceil(position.x + collision_box.right_bottom.x),
            y = math.ceil(position.y + collision_box.right_bottom.y)
        }
    end

    return area
end

function get_area_under_entity_at_position(entity, position)
    if not entity or not position then
        return
    end

    local collision_box = entity.prototype.collision_box
    if not collision_box then
        return
    end

    local area = {}

    -- adjust collision_box based on entity direction
    if entity.direction == defines.direction.east or entity.direction == defines.direction.west then
        area.left_top = {
            x = math.floor(position.x + collision_box.left_top.y),
            y = math.floor(position.y + collision_box.left_top.x)
        }
        area.right_bottom = {
            x = math.ceil(position.x + collision_box.right_bottom.y),
            y = math.ceil(position.y + collision_box.right_bottom.x)
        }
    else
        area.left_top = {
            x = math.floor(position.x + collision_box.left_top.x),
            y = math.floor(position.y + collision_box.left_top.y)
        }
        area.right_bottom = {
            x = math.ceil(position.x + collision_box.right_bottom.x),
            y = math.ceil(position.y + collision_box.right_bottom.y)
        }
    end

    return area
end

function is_within_reach(player, area)
    -- no reach limit for players without characters (e.g., god mode)
    if not player.character or not player.character.valid then
        return true
    end

    if not area then
        return false
    end

    local player_position = player.position
    local reach = player.character.reach_distance or 0

    -- find the closest corner of the area
    local closest_x = math.max(area.left_top.x, math.min(player_position.x, area.right_bottom.x))
    local closest_y = math.max(area.left_top.y, math.min(player_position.y, area.right_bottom.y))

    -- calculate the distance between the player and the closest point
    local distance = math.sqrt((closest_x - player_position.x) ^ 2 + (closest_y - player_position.y) ^ 2)

    -- check if the distance is within the player's reach
    return distance <= reach
end

function get_mineable_tiles()
    local tiles_to_exclude = TILES_TO_EXCLUDE
    local mineable_tiles = {}

    -- Fetch mineable tiles directly using prototypes.get_tile_filtered
    local blueprintable_tiles = prototypes.get_tile_filtered({ { filter = "minable" } })

    -- Filter out excluded tiles
    for name, tile in pairs(blueprintable_tiles) do
        if not tiles_to_exclude[name] then
            mineable_tiles[name] = true
        end
    end

    return mineable_tiles
end

function load_tiles(entity, area)
    if not entity or not area then
        return
    end

    local surface = entity.surface
    local mineable_tiles = get_mineable_tiles()
    if not surface or not mineable_tiles then
        return
    end

    local tiles_to_place = {}
    local tiles_to_return = {}

    -- check each tile under the entity
    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local current_tile = surface.get_tile(x, y)
            local search_area = { { x, y }, { x + 1, y + 1 } }
            local resources = surface.find_entities_filtered({ area = search_area, type = "resource" })
            local tiles_to_exclude = TILES_TO_EXCLUDE

            -- check to make sure the tile is not a resource tile or an excluded tile
            if #resources == 0 and not tiles_to_exclude["current_tile.name"] then
                -- prepare to return the current tile and to place a foundation tile
                if current_tile.name ~= storage.foundation then
                    if mineable_tiles[current_tile.name] then
                        table.insert(tiles_to_return, { name = current_tile.name, position = { x = x, y = y } })
                    end
                    table.insert(tiles_to_place, { name = storage.foundation, position = { x = x, y = y } })
                end
            end
        end
    end

    return tiles_to_place, tiles_to_return
end

function get_placeable_items()
    local items = {}
    local prototypes = prototypes.get_tile_filtered { { filter = "minable" } }

    for _, prototype in pairs(prototypes) do
        if not prototype.is_foundation then
            if prototype.items_to_place_this then
                for _, item in ipairs(prototype.items_to_place_this) do
                    if not items[prototype.name] and string.sub(prototype.name, 1, 7) ~= "frozen-" then
                        items[prototype.name] = item.name
                    end
                end
            end
        end
    end

    return items
end

function load_tile_lists()
    add_to_global_tile_names(DISABLED, DISABLED)
    add_to_global_tile_to_item(DISABLED, DISABLED)

    local tiles = get_placeable_items()
    for tile, item in pairs(tiles) do
        add_to_global_tile_names(tile, item)
        add_to_global_tile_to_item(tile, item)
    end

    table.sort(storage.tile_names)
end

function load_global_data()
    storage.foundation = storage.foundation or DISABLED
    storage.player_index = storage.player_index or 1

    load_excluded_name_list()
    load_excluded_type_list()

    storage.tile_names = {}

    load_tile_lists()
end
