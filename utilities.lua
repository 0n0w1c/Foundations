function get_player_data(player_index)
    storage.player_data[player_index] = storage.player_data[player_index] or
        {
            foundation = DISABLED,
            last_selected = nil,
            tile_selector_open = false,
            reopen_tile_selector_on_controller_change = false,
            excludes =
            {
                inserters = true,
                belts = true,
                poles = true
            }
        }

    local player_data = storage.player_data[player_index]
    player_data.tile_selector_open = player_data.tile_selector_open == true
    player_data.reopen_tile_selector_on_controller_change = player_data.reopen_tile_selector_on_controller_change == true
    load_excluded_name_list(player_data)
    load_excluded_type_list(player_data)

    return player_data
end

function load_excluded_name_list(player_data)
    player_data.excluded_name_list = {}

    for key, value in pairs(EXCLUDED_NAME_LIST) do
        player_data.excluded_name_list[key] = value
    end

    if player_data.excludes["poles"] == true then
        player_data.excluded_name_list["small-electric-pole"] = true
        player_data.excluded_name_list["medium-electric-pole"] = true

        if script.active_mods["aai-industry"] then
            player_data.excluded_name_list["small-iron-electric-pole"] = true
        end
    end
end

function load_excluded_type_list(player_data)
    player_data.excluded_type_list = {}

    for key, value in pairs(EXCLUDED_TYPE_LIST) do
        player_data.excluded_type_list[key] = value
    end

    if player_data.excludes["inserters"] == true then
        player_data.excluded_type_list["inserter"] = true
    end

    if player_data.excludes["belts"] == true then
        player_data.excluded_type_list["transport-belt"] = true
        player_data.excluded_type_list["underground-belt"] = true
        player_data.excluded_type_list["splitter"] = true
        player_data.excluded_type_list["loader"] = true
    end
end

function entity_excluded(entity, player_data)
    if not entity or not entity.valid then return true end
    if not player_data.excluded_name_list or not player_data.excluded_type_list then return end

    return player_data.excluded_name_list[entity.name]
        or player_data.excluded_type_list[entity.type] or false
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

    entity.destroy { raise_destroy = true }
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

function get_agricultural_tower_planting_positions(entity)
    if not entity or entity.type ~= "agricultural-tower" then return nil end

    local grid_size = entity.prototype.growth_grid_tile_size or 3
    local sector_radius = math.floor((entity.prototype.agricultural_tower_radius or 3) + 0.5)
    local positions = {}

    for gx = -sector_radius, sector_radius do
        for gy = -sector_radius, sector_radius do
            table.insert(positions, {
                x = math.floor(entity.position.x + gx * grid_size),
                y = math.floor(entity.position.y + gy * grid_size)
            })
        end
    end

    return positions
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

function get_mineable_tiles()
    local mineable_tiles = {}
    local tiles = prototypes.get_tile_filtered({ { filter = "minable" } })

    for name, tile in pairs(tiles) do
        mineable_tiles[name] = true
    end

    return mineable_tiles
end

local cached_mineable_tiles = nil

local function get_cached_mineable_tiles()
    cached_mineable_tiles = cached_mineable_tiles or get_mineable_tiles()
    return cached_mineable_tiles
end

local ESP_FOUNDATION_TILES =
{
    ["esp-foundation"] = true,
    ["F077ET-esp-foundation"] = true,
}

local function tile_prototype_field(prototype, field)
    local ok, value = pcall(function() return prototype[field] end)
    if ok then return value end
end

function natural_ground_tile_for_esp_foundation(target_tile)
    local target_prototype = prototypes.tile[target_tile]
    if not target_prototype then return false end

    if tile_prototype_field(target_prototype, "default_cover_tile") then return false end
    if tile_prototype_field(target_prototype, "is_foundation") then return false end
    if tile_prototype_field(target_prototype, "placeable_by") then return false end

    local mineable_tiles = get_cached_mineable_tiles()
    if mineable_tiles and mineable_tiles[target_tile] then return false end

    return true
end

function selected_tile_allowed_on_target(selected_tile, target_tile)
    if not selected_tile or not target_tile then return false end

    local condition = FOUNDATION_TILE_CONDITIONS[selected_tile]
    if condition then
        if condition[target_tile] == true then
            return true
        end

        if not (ESP_FOUNDATION_TILES[selected_tile] and natural_ground_tile_for_esp_foundation(target_tile)) then
            return false
        end
    end

    if selected_tile == "foundation" then
        local target_prototype = prototypes.tile[target_tile]
        if target_prototype and target_prototype.default_cover_tile and target_prototype.default_cover_tile ~= selected_tile then
            return false
        end
    end

    return true
end

function selected_tile_uses_agricultural_planting_area(selected_tile)
    return selected_tile == "artificial-yumako-soil"
        or selected_tile == "overgrowth-yumako-soil"
        or selected_tile == "artificial-jellynut-soil"
        or selected_tile == "overgrowth-jellynut-soil"
end

function agricultural_soil_matches_selected_tile(selected_tile, target_tile)
    if selected_tile == "artificial-yumako-soil" or selected_tile == "overgrowth-yumako-soil" then
        return target_tile == "artificial-yumako-soil"
            or target_tile == "overgrowth-yumako-soil"
            or target_tile == "natural-yumako-soil"
    end

    if selected_tile == "artificial-jellynut-soil" or selected_tile == "overgrowth-jellynut-soil" then
        return target_tile == "artificial-jellynut-soil"
            or target_tile == "overgrowth-jellynut-soil"
            or target_tile == "natural-jellynut-soil"
    end

    return target_tile == selected_tile
end

function agricultural_planting_area_can_be_filled(surface, centre, grid_size, selected_tile)
    if not surface or not centre or not grid_size or not selected_tile then return false end

    local half_left = math.floor(grid_size / 2)
    local half_right = grid_size - half_left - 1

    for dx = -half_left, half_right do
        for dy = -half_left, half_right do
            local tile = surface.get_tile(centre.x + dx, centre.y + dy)
            if not tile then return false end

            if not agricultural_soil_matches_selected_tile(selected_tile, tile.name)
                and not selected_tile_allowed_on_target(selected_tile, tile.name) then
                return false
            end
        end
    end

    return true
end

function load_tiles(entity, area, player)
    if not entity or not area then return end

    local surface = entity.surface
    local mineable_tiles = get_mineable_tiles()
    if not surface or not mineable_tiles then return end

    if not player then return end

    local player_data = get_player_data(player.index)
    local foundation = player_data.foundation
    if foundation == DISABLED then return end

    local tiles_to_place = {}
    local tiles_to_return = {}

    local function add_tile(position)
        local current_tile = surface.get_tile(position.x, position.y)
        if not current_tile or current_tile.name == foundation then return end
        if not selected_tile_allowed_on_target(foundation, current_tile.name) then return end

        if mineable_tiles[current_tile.name] then
            table.insert(tiles_to_return, { name = current_tile.name, position = position })
        end

        table.insert(tiles_to_place, { name = foundation, position = position })
    end

    local planting_positions = nil
    if selected_tile_uses_agricultural_planting_area(foundation) then
        planting_positions = get_agricultural_tower_planting_positions(entity)
    end

    if planting_positions then
        local grid_size = entity.prototype.growth_grid_tile_size or 3
        local half_left = math.floor(grid_size / 2)
        local half_right = grid_size - half_left - 1
        local seen_positions = {}

        for _, planting_position in pairs(planting_positions) do
            if agricultural_planting_area_can_be_filled(surface, planting_position, grid_size, foundation) then
                for dx = -half_left, half_right do
                    for dy = -half_left, half_right do
                        local position = {
                            x = planting_position.x + dx,
                            y = planting_position.y + dy
                        }
                        local key = position.x .. ":" .. position.y

                        if not seen_positions[key] then
                            seen_positions[key] = true
                            add_tile(position)
                        end
                    end
                end
            end
        end
    else
        for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
            for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
                add_tile({ x = x, y = y })
            end
        end
    end

    return tiles_to_place, tiles_to_return
end

local function tile_hidden_from_selector(prototype)
    return tile_prototype_field(prototype, "hidden")
        or tile_prototype_field(prototype, "hidden_in_factoriopedia")
        or string.sub(prototype.name, 1, 7) == "frozen-"
        or string.sub(prototype.name, 1, 13) == "F077ET-frozen"
        or prototype.name == "space-platform-foundation"
end

function get_placeable_items()
    local items = {}
    local prototypes = prototypes.get_tile_filtered { { filter = "minable" } }

    for _, prototype in pairs(prototypes) do
        if not tile_hidden_from_selector(prototype) and prototype.items_to_place_this then
            for _, item in ipairs(prototype.items_to_place_this) do
                if not items[prototype.name] then
                    items[prototype.name] = item.name
                end
            end
        end
    end

    return items
end
