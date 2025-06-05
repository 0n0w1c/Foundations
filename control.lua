require("constants")
require("utilities")

local mod_gui = require("mod-gui")

local halt_construction = false
if settings.startup["Foundations-halt-construction"] then
    halt_construction = settings.startup["Foundations-halt-construction"].value == true
end

local dectorio_hazard = true
if settings.startup["dectorio-vanilla-hazard-concrete-style"] then
    dectorio_hazard = settings.startup["dectorio-vanilla-hazard-concrete-style"].value == true
end

local function is_player_in_remote_view(player)
    return player.controller_type == defines.controllers.remote
end

local function is_compatible_surface(event)
    local surface_name = nil

    if event.surface_index then
        local surface = game.surfaces[event.surface_index]
        surface_name = surface and surface.name
    elseif event.player_index then
        local player = game.get_player(event.player_index)
        if player and is_player_in_remote_view(player) then
            return false
        end
        surface_name = player and player.surface.name
    elseif event.entity and event.entity.surface then
        surface_name = event.entity.surface.name
    end

    local is_compatible = surface_name and COMPATIBLE_SURFACES[surface_name] == true
    return is_compatible
end

local function place_foundation_under_entity(event)
    if not event then return end
    if not is_compatible_surface(event) then return end

    local entity = event.created_entity or event.moved_entity or event.entity
    if not entity or not entity.valid then return end

    local player = nil
    if event.player_index then
        player = game.get_player(event.player_index)
    elseif entity.last_user and entity.last_user.is_player() then
        player = entity.last_user
    end
    if not player then return end

    local pdata = get_player_data(player.index)
    if pdata.foundation == DISABLED or entity_excluded(entity, pdata) then
        return
    end

    local surface = entity.surface
    if not surface then return end

    local area = get_area_under_entity(entity)
    if not area then return end

    local tiles_to_place, tiles_to_return = load_tiles(entity, area, player)

    local robot_built = event.robot

    if tiles_to_place then
        local count = table_size(tiles_to_place)
        if not player_has_sufficient_tiles(player, pdata.foundation, count) then
            if halt_construction then
                return_entity_to_player(player, entity, robot_built)
            end
            return
        end

        if tiles_to_return then
            for _, tile in pairs(tiles_to_return) do
                local tile_to_mine = surface.get_tile(tile.position.x, tile.position.y)
                if tile_to_mine then
                    player.mine_tile(tile_to_mine)
                end
            end
        end

        if count > 0 then
            surface.set_tiles(tiles_to_place, true, false, true, true)

            local item_name = storage.tile_to_item[pdata.foundation]
            if item_name then
                player.remove_item { name = item_name, count = count }
            end
        end
    end
end

local function update_button(player)
    if not player then return end

    local pdata = get_player_data(player.index)
    local button_flow = mod_gui.get_button_flow(player)
    local sprite_path = "tile/" .. pdata.foundation
    local tool_tip = { "", { "tile-name." .. pdata.foundation }, "\n", { "tool-tip.Foundations-tool-tip" } }

    if pdata.foundation == DISABLED or not helpers.is_valid_sprite_path(sprite_path) then
        sprite_path = "Foundations-disabled"
        pdata.foundation = DISABLED
    end

    if pdata.button_on then
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

    player.set_shortcut_toggled("Foundations-toggle-button", pdata.button_on)
end

local function add_switch_to_flow(flow, icon_path, switch_name, tooltip, excludes)
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
        switch_state = excludes[switch_name] and "left" or "right",
        left_label_caption = { "gui.Foundations-toggle-off" },
        right_label_caption = { "gui.Foundations-toggle-on" },
    }
    switch.style.horizontal_align = "right"
end

local function show_tile_selector_gui(player)
    if player.gui.screen.tile_selector_frame then
        player.gui.screen.tile_selector_frame.destroy()
    end

    local pdata = get_player_data(player.index)
    local items = storage.tile_names
    local selected = pdata.foundation

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

    add_switch_to_flow(switch_flow, "item/inserter", "inserters", { "tool-tip.Foundations-inserters" }, pdata.excludes)
    add_switch_to_flow(switch_flow, "item/transport-belt", "belts", { "tool-tip.Foundations-belts" }, pdata.excludes)
    add_switch_to_flow(switch_flow, "item/small-electric-pole", "poles", { "tool-tip.Foundations-poles" },
        pdata.excludes)

    player.opened = frame
    return frame
end

local function on_gui_click(event)
    if not (event and event.element and event.element.valid) then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local pdata = get_player_data(player.index)

    if event.element.name == THIS_MOD then
        if player.controller_type == defines.controllers.remote then return end
        if not is_compatible_surface(player) then return end

        if event.button == defines.mouse_button_type.left then
            if event.control then
                if pdata.foundation ~= DISABLED and player.clear_cursor() then
                    player.cursor_stack.set_stack({ name = "Foundations-fill-tool" })
                end
            elseif event.shift then
                if pdata.foundation ~= DISABLED and player.clear_cursor() then
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
                if pdata.foundation ~= DISABLED and player.clear_cursor() then
                    player.cursor_stack.set_stack({ name = "Foundations-place-tool" })
                end
            elseif event.shift then
                if pdata.foundation ~= DISABLED and player.clear_cursor() then
                    player.cursor_stack.set_stack({ name = "Foundations-unplace-tool" })
                end
            elseif event.alt then
                -- do nothing
            else
                pdata.foundation = DISABLED
            end
        end
        update_button(player)
    elseif event.element.name == "tile_selector_close_button" then
        if player.gui.screen.tile_selector_frame then
            player.gui.screen.tile_selector_frame.destroy()
            player.opened = nil
        end
    elseif string.find(event.element.name, "tile_selector_button_") == 1 then
        local selected_tile_name = string.sub(event.element.name, string.len("tile_selector_button_") + 1)
        pdata.foundation = selected_tile_name

        if player.gui.screen.tile_selector_frame then
            player.gui.screen.tile_selector_frame.destroy()
            player.opened = nil
        end

        update_button(player)
    end
end

local function entity_mined(event)
    if not event then return end
    if not is_compatible_surface(event) then return end

    local entity = event.entity
    if not entity or not entity.valid then return end

    local surface = entity.surface
    if not surface then return end

    local player = nil
    if event.player_index then
        player = game.get_player(event.player_index)
    elseif entity.last_user and entity.last_user.is_player() then
        player = entity.last_user
    end
    if not player then return end

    local pdata = get_player_data(player.index)
    if pdata.foundation == DISABLED or entity_excluded(entity, pdata) then return end

    local area = get_area_under_entity(entity)
    if not area then return end

    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local tile = surface.get_tile(x, y)
            if tile and (tile.name == pdata.foundation or tile.name == "frozen-" .. pdata.foundation) then
                player.mine_tile(tile)
            end
        end
    end
end

local function player_selected_area(event)
    if not event or not event.item then return end
    if not is_compatible_surface(event) then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local pdata = get_player_data(player.index)

    if not is_within_reach(player, event.area) then return end

    local surface = player.surface
    if not surface then return end

    local placeable_tiles = storage.tile_to_item

    -- [ctrl][left]
    if event.item == "Foundations-fill-tool" then
        if pdata.foundation ~= DISABLED then
            local tiles_to_exclude = TILES_TO_EXCLUDE
            local tiles_to_place = {}

            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                local search_area = { { position.position.x, position.position.y }, { position.position.x + 1, position.position.y + 1 } }
                local entities = surface.find_entities_filtered({ area = search_area })

                local place_tile = true

                for _, entity in pairs(entities) do
                    if entity.valid then
                        if entity_excluded(entity, pdata) or entity.name == "character" then
                            break
                        else
                            place_tile = false
                        end
                    end
                end

                if tile and tile.name and tiles_to_exclude[tile.name] then
                    place_tile = false
                end

                if tile and tile.name and placeable_tiles[tile.name] then
                    place_tile = false
                end

                if place_tile then
                    table.insert(tiles_to_place, { name = pdata.foundation, position = position.position })
                end
            end

            local count = table_size(tiles_to_place)
            if count > 0 and player_has_sufficient_tiles(player, pdata.foundation, count) then
                surface.set_tiles(tiles_to_place, true, false, true, true)
                local item_name = placeable_tiles[pdata.foundation]
                if item_name then
                    player.remove_item { name = item_name, count = count }
                end
            end
        end

        player.clear_cursor()
    end

    -- [shift][left]
    if event.item == "Foundations-unfill-tool" then
        if pdata.foundation ~= DISABLED then
            local entities = surface.find_entities_filtered({ area = event.area })
            if not entities then return end

            local tiles_to_exclude = TILES_TO_EXCLUDE
            local tiles_to_unfill = {}
            local tiles_under_entities = {}

            for _, entity in pairs(entities) do
                if entity.valid then
                    local entity_area = get_area_under_entity(entity)
                    if entity_area then
                        for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                            for y = math.floor(entity_area.right_bottom.y), math.ceil(entity_area.right_bottom.y) - 1 do
                                local tile = surface.get_tile(x, y)
                                if not tile then return end

                                if entity.name == "character" or entity_excluded(entity, pdata) then
                                    if tile.name == pdata.foundation or tile.name == "frozen-" .. pdata.foundation then
                                        table.insert(tiles_to_unfill, tile)
                                    end
                                end
                                tiles_under_entities[x .. "," .. y] = true
                            end
                        end
                    end
                end
            end

            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                local tile_key = position.position.x .. "," .. position.position.y

                if tile and not tiles_under_entities[tile_key]
                    and (tile.name == pdata.foundation or tile.name == "frozen-" .. pdata.foundation)
                    and placeable_tiles[tile.name]
                    and not tiles_to_exclude[tile.name]
                then
                    table.insert(tiles_to_unfill, tile)
                end
            end

            for _, tile in pairs(tiles_to_unfill) do
                player.mine_tile(tile)
            end
        end
    end

    -- [ctrl][right]
    if event.item == "Foundations-place-tool" then
        if pdata.foundation ~= DISABLED then
            local entities = surface.find_entities_filtered({ area = event.area })
            if not entities then return end

            local tiles_to_place = {}

            for _, entity in pairs(entities) do
                if entity.valid then
                    if not entity_excluded(entity, pdata) and entity.name ~= "character" then
                        local entity_area = get_area_under_entity(entity)
                        if entity_area then
                            for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                                for y = math.floor(entity_area.left_top.y), math.ceil(entity_area.right_bottom.y) - 1 do
                                    local tile = surface.get_tile(x, y)
                                    if not tile then return end

                                    if tile.name ~= pdata.foundation then
                                        table.insert(tiles_to_place,
                                            { name = pdata.foundation, position = { x = x, y = y } })
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local count = table_size(tiles_to_place)
            if count > 0 and player_has_sufficient_tiles(player, pdata.foundation, count) then
                surface.set_tiles(tiles_to_place, true, false, true, true)
                local item_name = placeable_tiles[pdata.foundation]
                player.remove_item { name = item_name, count = count }
            end
        end
    end

    -- [shift][right]
    if event.item == "Foundations-unplace-tool" then
        if pdata.foundation ~= DISABLED then
            local tiles_to_unplace = {}

            local entities = surface.find_entities_filtered({ area = event.area })
            for _, entity in pairs(entities) do
                if entity.valid then
                    local entity_area = get_area_under_entity(entity)
                    if entity_area then
                        for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                            for y = math.floor(entity_area.left_top.y), math.ceil(entity_area.right_bottom.y) - 1 do
                                local tile = surface.get_tile(x, y)
                                if not tile then return end

                                if (tile.name == pdata.foundation or tile.name == "frozen-" .. pdata.foundation)
                                    and placeable_tiles[tile.name]
                                    and not entity_excluded(entity, pdata)
                                    and entity.name ~= "character"
                                then
                                    table.insert(tiles_to_unplace, tile)
                                end
                            end
                        end
                    end
                end
            end

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

    local player = nil
    if event.player_index then
        player = game.get_player(event.player_index)
    elseif entity.last_user and entity.last_user.is_player() then
        player = entity.last_user
    end
    if not player then return end

    local placeable_tiles = storage.tile_to_item
    if not placeable_tiles then return end

    local previous_area = get_area_under_entity_at_position(entity, event.start_pos)
    local current_area = get_area_under_entity(entity)

    if previous_area and current_area then
        local tiles_to_place = {}
        local tile_name
        local tile_names = {}

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

        local count = table_size(tile_names)
        if count > 0 then
            for i = 1, count do
                local tile = tile_names[i]
                local item_name = storage.tile_to_item[tile]
                local tile_position = tiles_to_place[i] and tiles_to_place[i].position

                if item_name and tile_position then
                    surface.set_tiles({ { name = tile, position = tile_position } }, true, false, true, false)
                    player.remove_item { name = item_name, count = 1 }
                end
            end
        end
    end
end

local function on_entity_moved(event)
    if not event or not event.moved_entity then return end

    local player = nil
    if event.player_index then
        player = game.get_player(event.player_index)
    elseif event.moved_entity.last_user and event.moved_entity.last_user.is_player() then
        player = event.moved_entity.last_user
    end
    if not player then return end

    local pdata = get_player_data(player.index)
    if pdata.foundation == DISABLED then return end

    if entity_excluded(event.moved_entity, pdata) then return end

    local surface = event.moved_entity.surface
    if not surface then return end

    local start_area = get_area_under_entity_at_position(event.moved_entity, event.start_pos)
    if not start_area then return end

    local move_tile = false
    local frozen_name = "frozen-" .. pdata.foundation
    for x = math.floor(start_area.left_top.x), math.ceil(start_area.right_bottom.x) - 1 do
        for y = math.floor(start_area.left_top.y), math.ceil(start_area.right_bottom.y) - 1 do
            local tile = surface.get_tile(x, y)
            if tile.name == pdata.foundation or tile.name == frozen_name then
                move_tile = true
                break
            end
        end
        if move_tile then break end
    end

    if not move_tile then return end

    entity_moved(event)
    place_foundation_under_entity(event)
end

local function on_gui_switch_state_changed(event)
    local player = game.players[event.player_index]
    if not player then return end
    if not event.element then return end

    if player.gui.screen.tile_selector_frame then
        local storage_key = event.element.name
        if storage_key then
            local pdata = get_player_data(event.player_index)
            pdata.excludes[storage_key] = (event.element.switch_state == "left")
        end

        local pdata = get_player_data(player.index)
        load_excluded_name_list(pdata)
        load_excluded_type_list(pdata)
    end
end

local function init_storage()
    storage = storage or {}
    storage.tile_to_item = { [DISABLED] = DISABLED }
    storage.tile_names = { DISABLED }
    storage.player_data = storage.player_data or {}

    load_tile_lists()
end

local function configuration_changed()
    init_storage()

    for _, player in pairs(game.connected_players) do
        get_player_data(player.index)
        update_button(player)
    end
    if not dectorio_hazard then
        game.print(
            "Foundations warning: Dectorio startup setting 'Use default Factorio Hazard concrete style' should be enabled")
    end
end

local function close_tile_selector(player)
    if player.gui.screen.tile_selector_frame then
        player.gui.screen.tile_selector_frame.destroy()
        player.opened = nil
    end
end

local function on_gui_closed(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    if player.gui.screen.tile_selector_frame then
        close_tile_selector(player)
    end
end

local function on_lua_shortcut(event)
    if not event or event.prototype_name ~= "Foundations-toggle-button" then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local pdata = get_player_data(player.index)
    pdata.button_on = not pdata.button_on
    update_button(player)
end

local function controller_changed(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    local pdata = get_player_data(player.index)

    if player.controller_type == defines.controllers.remote then
        pdata.last_selected = pdata.foundation
        pdata.foundation = DISABLED
        update_button(player)
    else
        if pdata.last_selected then
            pdata.foundation = pdata.last_selected
            pdata.last_selected = nil
            update_button(player)
        end
    end
end

local function register_event_handlers()
    script.on_event(defines.events.on_player_controller_changed, controller_changed)
    script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
    script.on_event(defines.events.on_gui_click, on_gui_click)
    script.on_event(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)
    script.on_event(defines.events.on_gui_closed, on_gui_closed)
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
