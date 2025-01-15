require("constants")
require("utilities")

--log(serpent.block(data))
--player.print(serpent.block(data))

local mod_gui = require("mod-gui")

local function is_player_in_remote_view(player)
    return player.controller_type == defines.controllers.remote
end

local function is_compatible_surface(event)
    local surface_name = nil

    -- 1. If the event has a `surface_index`, check the surface directly
    if event.surface_index then
        local surface = game.surfaces[event.surface_index]
        surface_name = surface and surface.name

        -- 2. If it’s a player-based event, check if the player is on a compatible surface and not in remote view
    elseif event.player_index then
        local player = game.get_player(event.player_index)
        if player and is_player_in_remote_view(player) then
            return false -- Ignore if player is in remote view
        end
        surface_name = player and player.surface.name

        -- 3. For entity-related events, check the entity's surface
    elseif event.entity and event.entity.surface then
        surface_name = event.entity.surface.name
    end

    -- Check compatibility with defined surfaces
    local is_compatible = surface_name and COMPATIBLE_SURFACES[surface_name] == true
    return is_compatible
end

-- place tiles under the entity
local function place_foundation_under_entity(event)
    if not event then return end
    if not is_compatible_surface(event) then return end

    local entity

    if event.created_entity then
        entity = event.created_entity
    end

    if not entity and event.moved_entity then
        entity = event.moved_entity
    end

    if not entity and event.entity then
        entity = event.entity
    end

    if not entity then return end

    if storage.foundation == DISABLED or entity_excluded(entity) then
        return
    end

    local surface = entity.surface
    if not surface then return end

    local player = game.players[storage.player_index]
    if not player then return end

    local area = get_area_under_entity(entity)
    if not area then return end

    local tiles_to_place, tiles_to_return = load_tiles(entity, area)

    if tiles_to_place then
        -- if not enough storage.foundation, put entity back on cursor and destroy the placed entity, then exit
        if not player_has_sufficient_tiles(player, storage.foundation, #tiles_to_place) then
            --return_entity_to_cursor(player, entity)
            return
        end

        -- mine tiles that are not storage.foundation
        if tiles_to_return then
            for _, tile in pairs(tiles_to_return) do
                local tile_to_mine = surface.get_tile(tile.position.x, tile.position.y)
                if tile_to_mine then
                    player.mine_tile(tile_to_mine)
                end
            end
        end

        -- place tiles and remove items from player inventory
        if #tiles_to_place > 0 then
            surface.set_tiles(tiles_to_place, true, false, true, true)

            local item_name = storage.tile_to_item[storage.foundation]
            if item_name then
                player.remove_item { name = item_name, count = #tiles_to_place }
            end
        end
    end
end

local function update_button()
    local player = game.players[storage.player_index]
    if not player then return end

    local button_flow = mod_gui.get_button_flow(player)
    local sprite_path = "tile/" .. storage.foundation
    local tool_tip = { "tile-name." .. storage.foundation }

    if storage.foundation == DISABLED or not helpers.is_valid_sprite_path(sprite_path) then
        sprite_path = "Foundations-disabled"
    end

    if not button_flow[THIS_MOD] then
        button_flow.add {
            type = "sprite-button",
            name = THIS_MOD,
            sprite = sprite_path,
            tooltip = tool_tip,
            style = mod_gui.button_style
        }
    else
        button_flow[THIS_MOD].sprite = sprite_path
        button_flow[THIS_MOD].tooltip = tool_tip
    end
end

local function show_tile_selector_gui(player)
    if player.gui.screen.tile_selector_frame then
        player.gui.screen.tile_selector_frame.destroy()
    end

    local items = storage.tile_names
    local selected = storage.foundation

    local frame = player.gui.screen.add {
        type = "frame",
        name = "tile_selector_frame",
        direction = "vertical",
    }

    frame.auto_center = true

    local titlebar_flow = frame.add {
        type = "flow",
        direction = "horizontal",
    }
    titlebar_flow.style.horizontal_spacing = 6

    titlebar_flow.drag_target = frame
    titlebar_flow.add {
        type = "label",
        caption = { "dialog-name.Foundations-tile-selector" },
        ignored_by_interaction = true,
        style = "frame_title",
    }
    local spacer = titlebar_flow.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }
    spacer.style.height = 24
    spacer.style.horizontally_stretchable = true
    spacer.style.left_margin = 4
    spacer.style.right_margin = 4

    local close_button = titlebar_flow.add {
        type = "sprite-button",
        name = "tile_selector_close_button",
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = { "tile-selector-gui.close-button-tooltip" },
    }
    close_button.style.height = 24
    close_button.style.width = 24

    local inner_frame = frame.add {
        type = "frame",
        name = "inner_frame",
        direction = "vertical",
        style = "inside_shallow_frame",
    }

    local flow = inner_frame.add {
        type = "flow",
        direction = "horizontal",
        name = "tile_selector",
    }

    for _, item_name in pairs(items) do
        if item_name ~= DISABLED and not (string.find(item_name, "left") or string.find(item_name, "right")) then
            --if item_name ~= DISABLED then
            local style = "slot_sized_button"
            if item_name == selected then
                style = "slot_sized_button_pressed"
            end

            local button = flow.add {
                type = "choose-elem-button",
                name = "tile_selector_button_" .. item_name,
                elem_type = "tile",
                tile = item_name,
                style = style,
            }
            button.locked = true
        end
    end
end

local function button_clicked(event)
    if event and event.element and event.element.valid then
        local player = game.players[storage.player_index]
        if not player then return end

        if event.element.name == THIS_MOD then
            if not is_compatible_surface(player) then return end

            if event.button == defines.mouse_button_type.left then
                if event.control then
                    if storage.foundation ~= DISABLED and player.clear_cursor() then
                        player.cursor_stack.set_stack({ name = "Foundations-fill-tool" })
                    end
                elseif event.shift then
                    if storage.foundation ~= DISABLED and player.clear_cursor() then
                        player.cursor_stack.set_stack({ name = "Foundations-unfill-tool" })
                    end
                elseif event.alt then
                    -- do nothing
                else
                    if player.gui.screen.tile_selector_frame then
                        player.gui.screen.tile_selector_frame.destroy()
                    else
                        show_tile_selector_gui(player)
                    end
                end
            elseif event.button == defines.mouse_button_type.right then
                if event.control then
                    if storage.foundation ~= DISABLED and player.clear_cursor() then
                        player.cursor_stack.set_stack({ name = "Foundations-place-tool" })
                    end
                elseif event.shift then
                    if storage.foundation ~= DISABLED and player.clear_cursor() then
                        player.cursor_stack.set_stack({ name = "Foundations-unplace-tool" })
                    end
                elseif event.alt then
                    -- do nothing
                else
                    storage.foundation = DISABLED
                end
            end

            update_button()
        elseif event.element.name == "tile_selector_close_button" then
            if player.gui.screen.tile_selector_frame then
                player.gui.screen.tile_selector_frame.destroy()
            end
        elseif string.find(event.element.name, "tile_selector_button_") == 1 then
            local selected_tile_name = string.sub(event.element.name, string.len("tile_selector_button_") + 1)
            storage.foundation = selected_tile_name -- Store the selected tile

            if player.gui.screen.tile_selector_frame then
                player.gui.screen.tile_selector_frame.destroy()
            end

            update_button()
        end
    end
end

local function entity_mined(event)
    if not event then return end
    if not is_compatible_surface(event) then return end

    local entity = event.entity
    if not entity then return end

    local surface = entity.surface
    if not surface then return end

    local player = game.players[storage.player_index]
    if not player then return end

    if storage.foundation == DISABLED or entity_excluded(entity) then return end

    local area = get_area_under_entity(entity)
    if not area then return end

    -- mine the storage.foundation tiles
    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local tile = surface.get_tile(x, y)
            if tile and tile.name == storage.foundation then
                player.mine_tile(tile)
            end
        end
    end
end

local function player_selected_area(event)
    if not event or not event.item then return end
    if not is_compatible_surface(event) then return end

    local player = game.players[event.player_index] or {}
    if not player then return end

    -- abort if the player is out of reach
    if not is_within_reach(player, event.area) then return end

    -- [ctrl][left]
    if event.item == "Foundations-fill-tool" then
        if storage.foundation ~= DISABLED then
            local surface = player.surface
            if not surface then return end

            local mineable_tiles = get_mineable_tiles()
            if not mineable_tiles then return end

            local tiles_to_exclude = TILES_TO_EXCLUDE
            local tiles_to_place = {}

            -- scan the area, find valid empty positions that need a tile
            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                local search_area = { { position.position.x, position.position.y }, { position.position.x + 1, position.position.y + 1 } }
                local entities = surface.find_entities_filtered({ area = search_area })

                local place_tile = true

                -- if character or excluded entity, don't stop placement
                -- anything else, stop placement
                for _, entity in pairs(entities) do
                    if entity.name == "character" or entity_excluded(entity) then
                        -- do nothing here so the tile will be placed
                    else
                        place_tile = false
                        break
                    end
                end

                -- if no other entities found or only the player or excluded entity is present, place the tile
                if place_tile and not mineable_tiles[tile.name] and (not tiles_to_exclude[tile.name] or tile.name == "landfill") then
                    table.insert(tiles_to_place,
                        { name = storage.foundation, position = { x = position.position.x, y = position.position.y } })
                end
            end

            if #tiles_to_place > 0 and player_has_sufficient_tiles(player, storage.foundation, #tiles_to_place) then
                surface.set_tiles(tiles_to_place, true, false, true, true)

                local item_name = storage.tile_to_item[storage.foundation]
                if item_name then
                    player.remove_item { name = item_name, count = #tiles_to_place }
                end
            end
        end

        player.clear_cursor()

        -- remove all copies of the Foundations-fill-tool from player inventory
        while player.get_item_count("Foundations-fill-tool") > 0 do
            player.remove_item({ name = "Foundations-fill-tool", count = 1 })
        end
    end

    -- [shift][left]
    if event.item == "Foundations-unfill-tool" then
        if storage.foundation ~= DISABLED then
            local surface = player.surface
            if not surface then return end

            local mineable_tiles = get_mineable_tiles()
            if not surface or not mineable_tiles then return end

            -- scan the area for entities and find tiles under excluded entities
            local entities = surface.find_entities_filtered({ area = event.area })
            if not entities then return end

            local tiles_to_exclude = TILES_TO_EXCLUDE
            local tiles_to_unfill = {}
            local tiles_under_entities = {}

            for _, entity in pairs(entities) do
                local entity_area = get_area_under_entity(entity)
                if entity_area then
                    for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                        for y = math.floor(entity_area.left_top.y), math.ceil(entity_area.right_bottom.y) - 1 do
                            local tile = surface.get_tile(x, y)
                            if not tile then return end

                            if entity.name == "character" or entity_excluded(entity) then
                                -- include tiles under excluded entities or the player for unfill
                                if tile.name == storage.foundation then
                                    table.insert(tiles_to_unfill, tile)
                                end
                            end
                            tiles_under_entities[x .. "," .. y] = true
                        end
                    end
                end
            end

            -- scan the area again to find tiles that are not under any entity
            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                if tile then
                    local tile_key = position.position.x .. "," .. position.position.y
                    -- check if the tile is mineable, not under any entity, and matches the foundation
                    if not tiles_under_entities[tile_key] and mineable_tiles[tile.name] and not tiles_to_exclude[tile.name] and tile.name == storage.foundation then
                        table.insert(tiles_to_unfill, tile)
                    end
                end
            end

            -- mine the tiles that need to be unfilling
            for _, tile in pairs(tiles_to_unfill) do
                player.mine_tile(tile)
            end

            -- remove all copies of the Foundations-unfill-tool from player inventory
            while player.get_item_count("Foundations-unfill-tool") > 0 do
                player.remove_item({ name = "Foundations-unfill-tool", count = 1 })
            end
        end
    end

    -- [ctrl][right]
    if event.item == "Foundations-place-tool" then
        if storage.foundation ~= DISABLED then
            local surface = player.surface
            if not surface then return end

            -- scan the area for entities and place foundation tiles under them
            local entities = surface.find_entities_filtered({ area = event.area })
            if not entities then return end

            local tiles_to_place = {}

            for _, entity in pairs(entities) do
                -- skip excluded entities and the player
                if not entity_excluded(entity) and entity.name ~= "character" then
                    local entity_area = get_area_under_entity(entity)
                    if entity_area then
                        for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                            for y = math.floor(entity_area.left_top.y), math.ceil(entity_area.right_bottom.y) - 1 do
                                local tile = surface.get_tile(x, y)
                                if not tile then return end

                                -- place storage.foundation tile if it's not already the same tile
                                if tile.name ~= storage.foundation then
                                    table.insert(tiles_to_place,
                                        { name = storage.foundation, position = { x = x, y = y } })
                                end
                            end
                        end
                    end
                end
            end

            -- place the foundation tiles
            if #tiles_to_place > 0 and player_has_sufficient_tiles(player, storage.foundation, #tiles_to_place) then
                surface.set_tiles(tiles_to_place, true, false, true, true)

                local item_name = storage.tile_to_item[storage.foundation]
                player.remove_item { name = item_name, count = #tiles_to_place }
            end

            -- remove all copies of the Foundations-place-tool from player inventory
            while player.get_item_count("Foundations-place-tool") > 0 do
                player.remove_item({ name = "Foundations-place-tool", count = 1 })
            end
        end
    end

    -- [shift][right]
    if event.item == "Foundations-unplace-tool" then
        if storage.foundation ~= DISABLED then
            local surface = player.surface
            if not surface then return end

            local mineable_tiles = get_mineable_tiles()
            if not mineable_tiles then return end

            local tiles_to_unplace = {}

            -- scan the area for entities and mine the tiles under them if they match storage.foundation
            local entities = surface.find_entities_filtered({ area = event.area })
            for _, entity in pairs(entities) do
                local entity_area = get_area_under_entity(entity)
                if entity_area then
                    for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                        for y = math.floor(entity_area.left_top.y), math.ceil(entity_area.right_bottom.y) - 1 do
                            local tile = surface.get_tile(x, y)
                            if not tile then return end

                            if tile.name == storage.foundation and mineable_tiles[tile.name] and not entity_excluded(entity) and entity.name ~= "character" then
                                player.mine_tile(tile)
                                table.insert(tiles_to_unplace, tile)
                            end
                        end
                    end
                end
            end

            -- mine the tiles that need to be unplaced
            for _, tile in pairs(tiles_to_unplace) do
                player.mine_tile(tile)
            end

            -- remove all copies of the Foundations-unplace-tool from player inventory
            while player.get_item_count("Foundations-unplace-tool") > 0 do
                player.remove_item({ name = "Foundations-unplace-tool", count = 1 })
            end
        end
    end
end

local function entity_moved(event)
    if not event then return end

    local entity = event.moved_entity
    if not entity then return end

    local surface = entity.surface
    if not surface then return end

    local player = game.players[storage.player_index]
    if not player then return end

    local mineable_tiles = get_mineable_tiles()
    if not mineable_tiles then return end

    local tiles_to_exclude = TILES_TO_EXCLUDE

    local previous_area = get_area_under_entity_at_position(entity, event.start_pos)
    local current_area = get_area_under_entity(entity)

    if previous_area and current_area then
        local tiles_to_place = {}
        local tile_name
        local tile_names = {}

        -- find the names of the tiles to be moved
        for x = current_area.left_top.x, current_area.right_bottom.x - 1 do
            for y = current_area.left_top.y, current_area.right_bottom.y - 1 do
                local position = { x = x, y = y }
                local tile = surface.get_tile(position.x, position.y)

                if tile and not within_area(position, previous_area) then
                    if tile.name and mineable_tiles[tile.name] and (not tiles_to_exclude[tile.name] or tile.name == "landfill") then
                        tile_name = tile.name
                        table.insert(tile_names, tile_name)
                    end
                end
            end
        end

        -- mine foundation tiles from vacated positions
        for x = previous_area.left_top.x, previous_area.right_bottom.x - 1 do
            for y = previous_area.left_top.y, previous_area.right_bottom.y - 1 do
                local position = { x = x, y = y }
                local tile = surface.get_tile(position.x, position.y)

                if not within_area(position, current_area) then
                    player.mine_tile(surface.get_tile(tile.position.x, tile.position.y))
                    table.insert(tiles_to_place, { name = tile_name, position = position })
                end
            end
        end

        -- fill vacated positions
        if #tile_names > 0 then
            for _, tile in ipairs(tile_names) do
                local item_name = storage.tile_to_item[tile]
                local tile_to_place = { { name = tile, position = tiles_to_place[_].position } }

                if item_name then
                    -- better to not raise an event if just moving tiles
                    surface.set_tiles(tile_to_place, true, false, true, false)
                    player.remove_item { name = item_name, count = 1 }
                end
            end
        end
    end
end

local function on_entity_moved(event)
    if not event or storage.foundation == DISABLED then return end

    if not event.moved_entity or entity_excluded(event.moved_entity) then return end

    entity_moved(event)
    place_foundation_under_entity(event)
end

local function init_storage()
    storage = storage or {}
    storage.tile_to_item = storage.tile_to_item or { [DISABLED] = DISABLED }
    storage.tile_names = storage.tile_names or { DISABLED }
    storage.foundation = storage.foundation or DISABLED
    storage.excluded_name_list = storage.excluded_name_list or {}
    storage.excluded_type_list = storage.excluded_type_list or {}
    storage.player_index = storage.player_index or 1
end

local function configuration_changed()
    init_storage()
    load_global_data()
    update_button()
end

local function register_event_handlers()
    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)
    script.on_event(defines.events.script_raised_built, place_foundation_under_entity)
    script.on_event(defines.events.on_player_mined_entity, entity_mined)
    script.on_event(defines.events.on_robot_mined_entity, entity_mined)
    script.on_event(defines.events.on_player_selected_area, player_selected_area)

    if remote.interfaces["selectorDollies"] and remote.interfaces["selectorDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("selectorDollies", "dolly_moved_entity_id"), on_entity_moved)
    end
end

local function on_init()
    init_storage()
    register_event_handlers()
end

local function on_load()
    register_event_handlers()
end

script.on_configuration_changed(configuration_changed)
script.on_init(on_init)
script.on_load(on_load)
