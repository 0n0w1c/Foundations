function get_player_data(player_index)
    storage.player_data[player_index] = storage.player_data[player_index] or
        {
            foundation = DISABLED,
            button_on = true,
            last_selected = nil,
            excludes =
            {
                inserters = true,
                belts = true,
                poles = true
            }
        }

    local pdata = storage.player_data[player_index]
    load_excluded_name_list(pdata)
    load_excluded_type_list(pdata)

    return pdata
end

function load_excluded_name_list(pdata)
    pdata.excluded_name_list = {}

    for key, value in pairs(EXCLUDED_NAME_LIST) do
        pdata.excluded_name_list[key] = value
    end

    if pdata.excludes["poles"] == true then
        pdata.excluded_name_list["small-electric-pole"] = true
        pdata.excluded_name_list["medium-electric-pole"] = true

        if script.active_mods["aai-industry"] then
            pdata.excluded_name_list["small-iron-electric-pole"] = true
        end
    end
end

function load_excluded_type_list(pdata)
    pdata.excluded_type_list = {}

    for key, value in pairs(EXCLUDED_TYPE_LIST) do
        pdata.excluded_type_list[key] = value
    end

    if pdata.excludes["inserters"] == true then
        pdata.excluded_type_list["inserter"] = true
    end

    if pdata.excludes["belts"] == true then
        pdata.excluded_type_list["transport-belt"] = true
        pdata.excluded_type_list["underground-belt"] = true
        pdata.excluded_type_list["splitter"] = true
        pdata.excluded_type_list["loader"] = true
    end
end

function entity_excluded(entity, pdata)
    if not entity or not entity.valid then return true end
    if not pdata.excluded_name_list or not pdata.excluded_type_list then return end

    return pdata.excluded_name_list[entity.name]
        or pdata.excluded_type_list[entity.type] or false
end

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

function recipe_enabled(force, recipe_name)
    if not force or not recipe_name then
        return false
    end

    local recipe = force.recipes[recipe_name]
    if recipe then
        return recipe.enabled
    end

    return true
end

function add_to_global_tile_names(tile_name, item_name)
    local force = game.forces["player"]

    if force and tile_name and item_name then
        if not tile_in_global_tile_names(tile_name) and recipe_enabled(force, item_name) then
            table.insert(storage.tile_names, tile_name)
        end
    end
end

function add_to_global_tile_to_item(tile_name, item_name)
    local force = game.forces["player"]

    if force and tile_name and item_name then
        if not storage.tile_to_item[tile_name] and recipe_enabled(force, item_name) then
            storage.tile_to_item[tile_name] = item_name
        end
    end
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

function player_has_sufficient_tiles(player, tile_name, count)
    if not player or not tile_name or count == nil then
        return false
    end

    local item_name = storage.tile_to_item[tile_name]
    return item_name and player.get_item_count(item_name) >= count
end

function return_entity_to_player(player, entity, robot_built)
    if not player or not entity or not entity.valid or not entity.prototype then return end

    local item_to_return = entity.prototype.items_to_place_this and entity.prototype.items_to_place_this[1]
    if not item_to_return then return end

    if robot_built then
        player.insert({ name = item_to_return.name, count = 1 })
    else
        if not player.cursor_stack.valid_for_read then
            player.cursor_stack.set_stack({ name = item_to_return.name, count = 1 })
        else
            if player.cursor_stack.name == item_to_return.name then
                player.cursor_stack.count = player.cursor_stack.count + 1
            else
                player.insert({ name = item_to_return.name, count = 1 })
            end
        end
    end

    entity.destroy()
end

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
    if not player.character or not player.character.valid then
        return true
    end

    if not area then
        return false
    end

    local player_position = player.position
    local reach = player.character.reach_distance or 0

    local closest_x = math.max(area.left_top.x, math.min(player_position.x, area.right_bottom.x))
    local closest_y = math.max(area.left_top.y, math.min(player_position.y, area.right_bottom.y))

    local distance = math.sqrt((closest_x - player_position.x) ^ 2 + (closest_y - player_position.y) ^ 2)

    return distance <= reach
end

function get_mineable_tiles()
    local mineable_tiles = {}
    local tiles = prototypes.get_tile_filtered({ { filter = "minable" } })

    for name, tile in pairs(tiles) do
        mineable_tiles[name] = true
    end

    return mineable_tiles
end

function load_tiles(entity, area, player)
    if not entity or not area then return end

    local surface = entity.surface
    local mineable_tiles = get_mineable_tiles()
    if not surface or not mineable_tiles then return end

    if not player then return end

    local pdata = get_player_data(player.index)
    local foundation = pdata.foundation
    if foundation == DISABLED then return end

    local tiles_to_place = {}
    local tiles_to_return = {}

    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local current_tile = surface.get_tile(x, y)
            local search_area = { { x, y }, { x + 1, y + 1 } }
            local resources = surface.find_entities_filtered({ area = search_area, type = "resource" })
            local tiles_to_exclude = TILES_TO_EXCLUDE

            if table_size(resources) == 0 and not tiles_to_exclude[current_tile.name] then
                if current_tile.name ~= foundation then
                    if mineable_tiles[current_tile.name] then
                        table.insert(tiles_to_return, { name = current_tile.name, position = { x = x, y = y } })
                    end
                    table.insert(tiles_to_place, { name = foundation, position = { x = x, y = y } })
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
                    if not items[prototype.name] and string.sub(prototype.name, 1, 7) ~= "frozen-" and not prototype.hidden then
                        items[prototype.name] = item.name
                    end
                end
            else
                items[prototype.name] = prototype.items_to_place_this
            end
        end
    end

    return items
end
