require("constants")
require("utilities")

local mod_gui = require("mod-gui")

local save = nil
local halt_construction = settings.startup["Foundations-halt-construction"].value or false

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
            if halt_construction then
                return_entity_to_cursor(player, entity)
            end

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
    local tool_tip = { "", { "tile-name." .. storage.foundation }, "\n", { "tool-tip.Foundations-tool-tip" } }

    if storage.foundation == DISABLED or not helpers.is_valid_sprite_path(sprite_path) then
        sprite_path = "Foundations-disabled"
        storage.foundation = DISABLED
    end

    if storage.button_on then
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
    else
        if button_flow[THIS_MOD] then
            button_flow[THIS_MOD].destroy()
        end
    end

    player.set_shortcut_toggled("Foundations-toggle-button", storage.button_on)
end

local function add_switch_to_flow(flow, icon_path, switch_name, tooltip)
    local sprite = flow.add {
        type = "sprite",
        sprite = icon_path,
        tooltip = tooltip,
    }
    sprite.style.width = 24
    sprite.style.height = 24
    sprite.style.horizontal_align = "right"

    local switch = flow.add {
        type = "switch",
        name = switch_name,
        switch_state = storage.excludes[switch_name] and "left" or "right",
        left_label_caption = { "gui.Foundations-toggle-off" },
        right_label_caption = { "gui.Foundations-toggle-on" },
    }
    switch.style.horizontal_align = "right"
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

    titlebar_flow.add {
        type = "label",
        caption = { "gui.Foundations-tile-selector" },
        ignored_by_interaction = true,
        style = "frame_title",
    }

    local draggable_space = titlebar_flow.add {
        type = "empty-widget",
        name = "tile_selector_draggable_space",
        style = "draggable_space_header",
        ignored_by_interaction = false,
    }
    draggable_space.style.height = 24
    draggable_space.style.horizontally_stretchable = true
    draggable_space.drag_target = frame

    local close_button = titlebar_flow.add {
        type = "sprite-button",
        name = "tile_selector_close_button",
        sprite = "utility/close",
        style = "close_button",
        mouse_button_filter = { "left" }
    }

    close_button.style.height = 24
    close_button.style.width = 24

    local inner_frame = frame.add {
        type = "frame",
        name = "inner_frame",
        direction = "vertical",
        style = "inside_shallow_frame",
    }

    local scroll_pane = inner_frame.add {
        type = "scroll-pane",
        name = "tile_scroll_pane",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto",
    }
    scroll_pane.style.maximal_height = 300
    scroll_pane.style.minimal_width = 400
    scroll_pane.style.padding = 4

    local grid = scroll_pane.add {
        type = "table",
        name = "tile_selector_grid",
        column_count = 10,
        style = "table",
    }

    for _, item_name in pairs(items) do
        if item_name ~= DISABLED then
            local style = "slot_sized_button"
            if item_name == selected then
                style = "slot_sized_button_pressed"
            end

            local button = grid.add {
                type = "choose-elem-button",
                name = "tile_selector_button_" .. item_name,
                elem_type = "tile",
                tile = item_name,
                style = style,
            }
            button.locked = true
        end
    end

    local switch_flow = frame.add {
        type = "flow",
        name = "switch_flow",
        direction = "horizontal",
    }
    switch_flow.style.horizontal_spacing = 32
    switch_flow.style.top_padding = 12
    switch_flow.style.bottom_padding = 10

    add_switch_to_flow(switch_flow, "item/inserter", "inserters", { "tool-tip.Foundations-inserters" })
    add_switch_to_flow(switch_flow, "item/transport-belt", "belts", { "tool-tip.Foundations-belts" })
    add_switch_to_flow(switch_flow, "item/small-electric-pole", "poles", { "tool-tip.Foundations-poles" })

    player.opened = frame
    return frame
end

local function button_clicked(event)
    if event and event.element and event.element.valid then
        local player = game.players[storage.player_index]
        if not player then return end

        if event.element.name == THIS_MOD then
            if player.controller_type == defines.controllers.remote then return end
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
                player.opened = nil
            end
        elseif string.find(event.element.name, "tile_selector_button_") == 1 then
            local selected_tile_name = string.sub(event.element.name, string.len("tile_selector_button_") + 1)
            storage.foundation = selected_tile_name

            if player.gui.screen.tile_selector_frame then
                player.gui.screen.tile_selector_frame.destroy()
                player.opened = nil
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
            if tile and (tile.name == storage.foundation or tile.name == "frozen-" .. storage.foundation) then
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

            local tiles_to_exclude = TILES_TO_EXCLUDE
            local tiles_to_place = {}

            --local mineable_tiles = get_mineable_tiles()
            local placeable_tiles = storage.tile_to_item

            -- scan the area, find valid empty positions that need a tile
            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                local search_area = { { position.position.x, position.position.y }, { position.position.x + 1, position.position.y + 1 } }
                local entities = surface.find_entities_filtered({ area = search_area })

                local place_tile = true

                for _, entity in pairs(entities) do
                    if entity_excluded(entity) or entity.name == "character" then
                        break
                    else
                        place_tile = false
                    end
                end

                if tile and tile.name and tiles_to_exclude[tile.name] then
                    place_tile = false
                end

                if tile and tile.name and placeable_tiles[tile.name] then
                    --if tile and tile.name and mineable_tiles[tile.name] then
                    place_tile = false
                end

                if place_tile then
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
    end

    -- [shift][left]
    if event.item == "Foundations-unfill-tool" then
        if storage.foundation ~= DISABLED then
            local surface = player.surface
            if not surface then return end

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
                                if tile.name == storage.foundation or tile.name == "frozen-" .. storage.foundation then
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
                    local placeable_tiles = storage.tile_to_item

                    if not tiles_under_entities[tile_key]
                        and (tile.name == storage.foundation or tile.name == "frozen-" .. storage.foundation)
                        and placeable_tiles[tile.name]
                        and not tiles_to_exclude[tile.name]
                    then
                        table.insert(tiles_to_unfill, tile)
                    end
                end
            end

            -- mine the tiles that need to be unfilling
            for _, tile in pairs(tiles_to_unfill) do
                player.mine_tile(tile)
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
        end
    end

    -- [shift][right]
    if event.item == "Foundations-unplace-tool" then
        if storage.foundation ~= DISABLED then
            local surface = player.surface
            if not surface then return end

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

                            local placeable_tiles = storage.tile_to_item

                            if (tile.name == storage.foundation or tile.name == "frozen-" .. storage.foundation) and placeable_tiles[tile.name] and (not entity_excluded(entity)) and entity.name ~= "character" then
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

    local placeable_tiles = storage.tile_to_item
    if not placeable_tiles then return end

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
                    if tile.name and placeable_tiles[tile.name] then
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

local function on_gui_switch_state_changed(event)
    local player = game.players[event.player_index]
    if not player then return end
    if not event.element then return end

    local storage_key = event.element.name
    if storage_key then
        storage.excludes[storage_key] = (event.element.switch_state == "left")
    end

    load_excluded_name_list()
    load_excluded_type_list()
end

local function init_storage()
    storage = storage or {}
    storage.tile_to_item = storage.tile_to_item or { [DISABLED] = DISABLED }
    storage.tile_names = storage.tile_names or { DISABLED }
    storage.foundation = storage.foundation or DISABLED
    storage.button_on = storage.button_on or true
    storage.excluded_name_list = storage.excluded_name_list or {}
    storage.excluded_type_list = storage.excluded_type_list or {}
    storage.player_index = storage.player_index or 1
    storage.excludes = storage.excludes or {
        inserters = true,
        belts = true,
        poles = true,
    }
end

local function configuration_changed()
    init_storage()
    load_global_data()
    update_button()
end

function close_tile_selector(player)
    if player.gui.screen.tile_selector_frame then
        player.gui.screen.tile_selector_frame.destroy()
        player.opened = nil
    end
end

local function handle_close_tile_selector(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    if player.gui.screen.tile_selector_frame then
        close_tile_selector(player)
    end
end

local function on_shortcut_clicked(event)
    if (not event) or (not event.prototype_name) or (event.prototype_name ~= "Foundations-toggle-button") then return end

    storage.button_on = not storage.button_on
    update_button()
end

local function controller_changed(event)
    local player = game.get_player(event.player_index)

    if player.controller_type == defines.controllers.remote then
        save = storage.foundation
        storage.foundation = DISABLED
        update_button()
    else
        if save then
            storage.foundation = save
            update_button()
            save = nil
        end
    end
end

local function register_event_handlers()
    script.on_event(defines.events.on_player_controller_changed, controller_changed)
    script.on_event(defines.events.on_lua_shortcut, on_shortcut_clicked)
    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)
    script.on_event({ "close-tile-selector-e", "close-tile-selector-esc" }, handle_close_tile_selector)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)
    script.on_event(defines.events.script_raised_built, place_foundation_under_entity)
    script.on_event(defines.events.script_raised_revive, place_foundation_under_entity)
    script.on_event(defines.events.on_player_mined_entity, entity_mined)
    script.on_event(defines.events.on_robot_mined_entity, entity_mined)
    script.on_event(defines.events.script_raised_destroy, entity_mined)
    script.on_event(defines.events.on_player_selected_area, player_selected_area)

    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_entity_moved)
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
