require("constants")
if script.active_mods and script.active_mods["VoidBlock"] then
    FOUNDATION_TILE_CONDITIONS["F077ET-esp-foundation"]["s6x-voidocean"] = true
end

require("utilities")


local halt_construction = false
if settings.startup["Foundations-halt-construction"] then
    halt_construction = settings.startup["Foundations-halt-construction"].value == true
end

local dectorio_hazard = true
if settings.startup["dectorio-vanilla-hazard-concrete-style"] then
    dectorio_hazard = settings.startup["dectorio-vanilla-hazard-concrete-style"].value == true
end

local function is_compatible_surface(event)
    return true
end

local function get_responsible_player(event, entity)
    if event.player_index then
        local player = game.get_player(event.player_index)
        if player and player.valid then return player end
    end

    if entity.last_user and entity.last_user.valid and entity.last_user.is_player() then
        return entity.last_user
    end

    local candidates = entity.surface.find_entities_filtered
        {
            type = "character",
            position = entity.position,
            radius = 64
        }

    local closest_character = nil
    local closest_distance = math.huge
    for _, candidate in ipairs(candidates) do
        if candidate.valid then
            local dist = ((candidate.position.x - entity.position.x) ^ 2 + (candidate.position.y - entity.position.y) ^ 2) ^
                0.5
            if dist < closest_distance then
                closest_character = candidate
                closest_distance = dist
            end
        end
    end

    if closest_character then
        for _, player in pairs(game.connected_players) do
            if player.valid and player.character == closest_character then
                return player
            end
        end
    end

    return nil
end

local function place_foundation_under_entity(event)
    if not event then return end
    if not is_compatible_surface(event) then return end

    local entity = event.created_entity or event.moved_entity or event.entity
    if not entity or not entity.valid then return end

    if entity.type == "electric-pole" and string.sub(entity.name, 1, 7) == "F077ET-" then
        return
    end

    local player = nil
    if event.player_index then
        player = game.get_player(event.player_index)
    elseif entity.last_user and entity.last_user.is_player() then
        player = entity.last_user
    end

    if not player then
        player = get_responsible_player(event, entity)
    end
    if not (player and player.index) then return end

    local player_data = get_player_data(player.index)
    if not player_data or player_data.foundation == DISABLED or entity_excluded(entity, player_data) then
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

        if not player_has_sufficient_tiles(player, player_data.foundation, count) then
            if halt_construction then
                local item_name = storage.tile_to_item[player_data.foundation]
                if item_name then
                    player.create_local_flying_text {
                        position = entity.position,
                        text = {
                            "gui.Foundations-missing-tiles",
                            count,
                            { "item-name." .. item_name }
                        }
                    }
                end

                return_entity_to_player(player, entity, robot_built)
            end
            return
        end

        if tiles_to_return then
            for _, tile in pairs(tiles_to_return) do
                local tile_to_mine = surface.get_tile(tile.position.x, tile.position.y)
                if not prototypes.tile[tile_to_mine.name].is_foundation then
                    if tile_to_mine then
                        player.mine_tile(tile_to_mine)
                    end
                end
            end
        end

        if count > 0 then
            surface.set_tiles(tiles_to_place, true, false, true, true, player)

            local item_name = storage.tile_to_item[player_data.foundation]
            if item_name then
                player.remove_item { name = item_name, count = count }
            end
        end
    end
end

local function refresh_player_ui(player)
    if not player then return end

    local player_data = get_player_data(player.index)
    local sprite_path = "tile/" .. player_data.foundation

    if player_data.foundation == DISABLED or not helpers.is_valid_sprite_path(sprite_path) then
        player_data.foundation = DISABLED
    end
end

local function give_player_tool(player, tool_name)
    if not player or not tool_name then return end

    local player_data = get_player_data(player.index)
    if player_data.foundation == DISABLED then return end

    if player.clear_cursor() then
        player.cursor_stack.set_stack({ name = tool_name })
    end
end


local tile_selector_frame_name = "tile_selector_frame"
local tile_selector_button_prefix = "tile_selector_button_"

local function get_tile_selector_frame(player)
    if not (player and player.valid) then return nil end

    local frame = player.gui.screen[tile_selector_frame_name]
    if frame and frame.valid then
        return frame
    end

    return nil
end

local function set_tile_selector_open_state(player, is_open)
    if not (player and player.valid) then return end

    local player_data = get_player_data(player.index)
    player_data.tile_selector_open = is_open == true
end

local function destroy_tile_selector_gui(player)
    local frame = get_tile_selector_frame(player)
    if not frame then
        set_tile_selector_open_state(player, false)
        return
    end

    if player.opened == frame then
        player.opened = nil
    end

    frame.destroy()
    set_tile_selector_open_state(player, false)
end

local function get_tile_selector_state(player)
    local player_data = get_player_data(player.index)
    local selected = player_data.foundation
    local selected_sprite = "tile/" .. selected
    local disabled = selected == DISABLED

    if disabled or not helpers.is_valid_sprite_path(selected_sprite) then
        selected_sprite = "Foundations"
    end

    return {
        player_data = player_data,
        tiles = storage.tile_names,
        selected = selected,
        selected_sprite = selected_sprite,
        foundations_disabled = disabled,
    }
end

local function get_tile_selector_layout(state)
    local tile_count = 0
    for _, item_name in pairs(state.tiles) do
        if item_name ~= DISABLED then
            tile_count = tile_count + 1
        end
    end

    local expanded = tile_count > 21

    return {
        frame_width = expanded and 396 or 378,
        grid_columns = 7,
        grid_spacing = 8,
        scroll_right_buffer = expanded and 12 or 8,
        selection_spacing = expanded and 6 or 4,
        selection_title_right_margin = expanded and 6 or 4,
        tool_button_width = expanded and 166 or 160,
        tool_table_horizontal_spacing = expanded and 18 or 14,
        tool_table_vertical_spacing = 10,
        exclusions_horizontal_spacing = expanded and 10 or 8,
        exclusions_vertical_spacing = 6,
        bottom_button_width = expanded and 124 or 120,
        bottom_button_spacing = expanded and 10 or 8,
    }
end

local function add_section_header(parent, caption)
    local header = parent.add {
        type = "label",
        caption = caption,
        style = "caption_label",
    }
    header.style.bottom_margin = 4
    return header
end

local function add_exclusion_checkbox(parent, checkbox_name, caption, tooltip, excludes)
    local row = parent.add {
        type = "flow",
        name = "Foundations-exclusion-row-" .. checkbox_name,
        direction = "horizontal",
    }
    row.style.vertical_align = "center"
    row.style.horizontal_spacing = 8
    row.style.horizontally_stretchable = true

    local checkbox = row.add {
        type = "checkbox",
        name = checkbox_name,
        state = excludes[checkbox_name] == true,
        tooltip = tooltip,
    }

    local label = row.add {
        type = "label",
        caption = caption,
        tooltip = tooltip,
    }
    label.style.single_line = true
    label.style.horizontally_stretchable = true

    return checkbox
end

local function create_tile_selector_frame(player, layout)
    local frame = player.gui.screen.add {
        type = "frame",
        name = tile_selector_frame_name,
        direction = "vertical",
    }
    frame.auto_center = true
    frame.style.minimal_width = layout.frame_width
    frame.style.maximal_width = layout.frame_width
    return frame
end

local function build_tile_selector_titlebar(frame)
    local titlebar_flow = frame.add {
        type = "flow",
        direction = "horizontal",
    }
    titlebar_flow.style.horizontal_spacing = 6
    titlebar_flow.drag_target = frame

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
    close_button.style.width = 24
    close_button.style.height = 24
end

local function create_tile_selector_body(frame)
    local inner_frame = frame.add {
        type = "frame",
        name = "inner_frame",
        direction = "vertical",
        style = "inside_shallow_frame",
    }
    inner_frame.style.left_padding = 8
    inner_frame.style.right_padding = 8
    inner_frame.style.top_padding = 8
    inner_frame.style.bottom_padding = 8
    return inner_frame
end

local function build_tile_grid(parent, state, layout)
    local scroll_pane = parent.add {
        type = "scroll-pane",
        name = "tile_scroll_pane",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto",
    }
    scroll_pane.style.maximal_height = 150
    scroll_pane.style.horizontally_stretchable = true
    scroll_pane.style.padding = 4

    local holder = scroll_pane.add {
        type = "flow",
        name = "tile_selector_grid_holder",
        direction = "horizontal",
    }

    local grid = holder.add {
        type = "table",
        name = "tile_selector_grid",
        column_count = layout.grid_columns,
        style = "table",
    }
    grid.style.horizontal_spacing = layout.grid_spacing
    grid.style.vertical_spacing = layout.grid_spacing

    for _, item_name in pairs(state.tiles) do
        if item_name ~= DISABLED then
            local sprite = "tile/" .. item_name
            if not helpers.is_valid_sprite_path(sprite) then
                sprite = "utility/questionmark"
            end

            local button = grid.add {
                type = "sprite-button",
                name = tile_selector_button_prefix .. item_name,
                sprite = sprite,
                style = item_name == state.selected and "slot_sized_button_pressed" or "slot_sized_button",
                tooltip = { "tile-name." .. item_name },
                mouse_button_filter = { "left" }
            }
            button.style.width = 40
            button.style.height = 40
        end
    end

    local spacer = holder.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }
    spacer.style.width = layout.scroll_right_buffer
end

local function build_selection_row(parent, state, layout)
    local selected_row = parent.add {
        type = "flow",
        name = "tile_selector_selected_row",
        direction = "horizontal",
    }
    selected_row.style.top_margin = 10
    selected_row.style.vertical_align = "center"
    selected_row.style.horizontal_spacing = layout.selection_spacing
    selected_row.style.horizontally_stretchable = true

    local selected_title = selected_row.add {
        type = "label",
        caption = { "gui.Foundations-current-selection" },
        style = "caption_label",
    }
    selected_title.style.right_margin = layout.selection_title_right_margin

    local selected_caption = selected_row.add {
        type = "label",
        name = "Foundations-selected-caption",
        caption = state.foundations_disabled
            and { "gui.Foundations-disabled-state" }
            or { "tile-name." .. state.selected },
    }
    selected_caption.style.single_line = true
    selected_caption.style.horizontally_stretchable = true
end

local function build_tools_section(parent, state, layout)
    local tools_flow = parent.add {
        type = "flow",
        name = "tile_selector_tools_flow",
        direction = "vertical",
    }
    tools_flow.style.top_margin = 12
    tools_flow.style.horizontally_stretchable = true

    add_section_header(tools_flow, { "gui.Foundations-tools" })

    local action_table = tools_flow.add {
        type = "table",
        name = "tile_selector_action_table",
        column_count = 2,
    }
    action_table.style.horizontal_spacing = layout.tool_table_horizontal_spacing
    action_table.style.vertical_spacing = layout.tool_table_vertical_spacing

    local button_specs = {
        { name = "Foundations-action-fill",    caption = { "gui.Foundations-fill-short" },    tooltip = { "tool-tip.Foundations-fill" } },
        { name = "Foundations-action-unfill",  caption = { "gui.Foundations-unfill-short" },  tooltip = { "tool-tip.Foundations-unfill" } },
        { name = "Foundations-action-place",   caption = { "gui.Foundations-place-short" },   tooltip = { "tool-tip.Foundations-place" } },
        { name = "Foundations-action-unplace", caption = { "gui.Foundations-unplace-short" }, tooltip = { "tool-tip.Foundations-unplace" } },
    }

    for _, spec in ipairs(button_specs) do
        local button = action_table.add {
            type = "button",
            name = spec.name,
            caption = spec.caption,
            tooltip = spec.tooltip,
            style = "rounded_button",
            enabled = not state.foundations_disabled,
        }
        button.style.width = layout.tool_button_width
        button.style.height = 40
    end
end

local function build_exclusions_section(parent, state, layout)
    local options_flow = parent.add {
        type = "flow",
        name = "tile_selector_options_flow",
        direction = "vertical",
    }
    options_flow.style.top_margin = 12
    options_flow.style.horizontally_stretchable = true

    add_section_header(options_flow, { "gui.Foundations-exclusions" })

    local exclusions_table = options_flow.add {
        type = "table",
        name = "tile_selector_exclusions_table",
        column_count = 3,
    }
    exclusions_table.style.horizontal_spacing = layout.exclusions_horizontal_spacing
    exclusions_table.style.vertical_spacing = layout.exclusions_vertical_spacing
    exclusions_table.style.horizontally_stretchable = true

    add_exclusion_checkbox(
        exclusions_table,
        "inserters",
        { "gui.Foundations-exclude-inserters" },
        { "tool-tip.Foundations-inserters" },
        state.player_data.excludes
    )

    add_exclusion_checkbox(
        exclusions_table,
        "belts",
        { "gui.Foundations-exclude-belts" },
        { "tool-tip.Foundations-belts" },
        state.player_data.excludes
    )

    add_exclusion_checkbox(
        exclusions_table,
        "poles",
        { "gui.Foundations-exclude-1x1-poles" },
        { "tool-tip.Foundations-poles" },
        state.player_data.excludes
    )
end

local function build_bottom_buttons(parent, layout)
    local bottom_row = parent.add {
        type = "flow",
        name = "tile_selector_bottom_row",
        direction = "horizontal",
    }
    bottom_row.style.top_margin = 14
    bottom_row.style.horizontal_spacing = layout.bottom_button_spacing
    bottom_row.style.horizontally_stretchable = true

    local disable_button = bottom_row.add {
        type = "button",
        name = "Foundations-action-disable",
        caption = { "gui.Foundations-disable-short" },
        tooltip = { "tool-tip.Foundations-disable" },
        style = "red_back_button"
    }
    disable_button.style.width = layout.bottom_button_width
    disable_button.style.height = 40

    local spacer = bottom_row.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }
    spacer.style.horizontally_stretchable = true

    local continue_button = bottom_row.add {
        type = "button",
        name = "Foundations-action-continue",
        caption = "Continue",
        tooltip = "Close this window and keep the selected foundation.",
        style = "confirm_button",
    }
    continue_button.style.width = layout.bottom_button_width
    continue_button.style.height = 40
end

local function show_tile_selector_gui(player)
    destroy_tile_selector_gui(player)

    local state = get_tile_selector_state(player)
    local layout = get_tile_selector_layout(state)
    local frame = create_tile_selector_frame(player, layout)

    build_tile_selector_titlebar(frame)

    local body = create_tile_selector_body(frame)
    build_tile_grid(body, state, layout)
    build_selection_row(body, state, layout)
    build_exclusions_section(body, state, layout)
    build_tools_section(body, state, layout)
    build_bottom_buttons(body, layout)

    player.opened = frame
    set_tile_selector_open_state(player, true)
    return frame
end

local function select_tile_from_gui(player, player_data, selected_tile_name)
    player_data.foundation = selected_tile_name
    show_tile_selector_gui(player)
    refresh_player_ui(player)
end

local function close_tile_selector_from_gui(player)
    destroy_tile_selector_gui(player)
    refresh_player_ui(player)
end

local function disable_foundations_from_gui(player, player_data)
    player_data.foundation = DISABLED
    close_tile_selector_from_gui(player)
end

local function give_player_tool_from_gui(player, tool_name)
    close_tile_selector_from_gui(player)
    give_player_tool(player, tool_name)
end

local function on_gui_click(event)
    if not (event and event.element and event.element.valid) then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local player_data = get_player_data(player.index)
    local name = event.element.name

    if name == "tile_selector_close_button" or name == "Foundations-action-continue" then
        close_tile_selector_from_gui(player)
        return
    end

    if string.find(name, tile_selector_button_prefix, 1, true) == 1 then
        local selected_tile_name = string.sub(name, string.len(tile_selector_button_prefix) + 1)
        select_tile_from_gui(player, player_data, selected_tile_name)
        return
    end

    if name == "Foundations-action-fill" then
        give_player_tool_from_gui(player, "Foundations-fill-tool")
        return
    elseif name == "Foundations-action-unfill" then
        give_player_tool_from_gui(player, "Foundations-unfill-tool")
        return
    elseif name == "Foundations-action-place" then
        give_player_tool_from_gui(player, "Foundations-place-tool")
        return
    elseif name == "Foundations-action-unplace" then
        give_player_tool_from_gui(player, "Foundations-unplace-tool")
        return
    elseif name == "Foundations-action-disable" then
        disable_foundations_from_gui(player, player_data)
        return
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

    local player_data = get_player_data(player.index)
    if player_data.foundation == DISABLED or entity_excluded(entity, player_data) then return end

    local area = get_area_under_entity(entity)
    if not area then return end

    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local tile = surface.get_tile(x, y)
            if tile and (tile.name == player_data.foundation or tile.name == "frozen-" .. player_data.foundation) then
                player.mine_tile(tile)
            end
        end
    end
end

local function can_place_foundation_tile_on(foundation_tile, target_tile)
    local condition = FOUNDATION_TILE_CONDITIONS[foundation_tile]
    return condition and condition[target_tile] == true
end

local function is_water_tile(tile)
    local proto = prototypes.tile[tile.name]
    if not proto or not proto.collision_mask then return false end

    for layer_name, _ in pairs(proto.collision_mask.layers) do
        if layer_name == "water_tile" then
            return true
        end
    end
    return false
end

local function player_selected_area(event)
    if not event or not event.item then return end
    if not is_compatible_surface(event) then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local player_data = get_player_data(player.index)

    local surface = player.surface
    if not surface then return end

    local placeable_tiles = storage.tile_to_item

    if event.item == "Foundations-fill-tool" then
        if player_data.foundation ~= DISABLED then
            local tiles_to_place = {}

            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                local search_area = { { position.position.x - 0.5, position.position.y - 0.5 }, { position.position.x + 0.5, position.position.y + 0.5 } }
                local entities = surface.find_entities_filtered({ area = search_area })

                local place_tile = true

                for _, entity in pairs(entities) do
                    if entity.valid then
                        if entity_excluded(entity, player_data) or entity.name == "character" then
                            break
                        else
                            if not prototypes.entity[entity.name].mineable_properties then
                                place_tile = false
                            end
                        end
                    end
                end

                if is_water_tile(tile) and not prototypes.tile[player_data.foundation].is_foundation then
                    place_tile = false
                end

                if tile.name == player_data.foundation then
                    place_tile = false
                elseif prototypes.tile[player_data.foundation].is_foundation then
                    if not can_place_foundation_tile_on(player_data.foundation, tile.name) then
                        place_tile = false
                    end
                end

                if tile and tile.name and placeable_tiles[tile.name] then
                    if not prototypes.tile[tile.name].is_foundation then
                        place_tile = false
                    end
                end

                if place_tile then
                    table.insert(tiles_to_place, { name = player_data.foundation, position = position.position })
                end
            end

            local count = table_size(tiles_to_place)
            if count > 0 and player_has_sufficient_tiles(player, player_data.foundation, count) then
                if surface.name == "nauvis" and prototypes.tile[player_data.foundation].is_foundation then
                    for _, tile in ipairs(tiles_to_place) do
                        local fishes = surface.find_entities_filtered {
                            position = tile.position,
                            name = "fish"
                        }
                        for _, fish in ipairs(fishes) do
                            if fish.valid then fish.destroy() end
                        end
                    end
                end

                surface.set_tiles(tiles_to_place, true, false, true, true, player)
                local item_name = placeable_tiles[player_data.foundation]
                if item_name then
                    player.remove_item { name = item_name, count = count }
                end
            end
        end
    end

    if event.item == "Foundations-unfill-tool" then
        if player_data.foundation ~= DISABLED then
            local entities = surface.find_entities_filtered({ area = event.area })
            if not entities then return end

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

                                if entity.name == "character" or entity_excluded(entity, player_data) then
                                    if tile.name == player_data.foundation or tile.name == "frozen-" .. player_data.foundation then
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
                    and (tile.name == player_data.foundation or tile.name == "frozen-" .. player_data.foundation)
                    and placeable_tiles[tile.name]
                then
                    table.insert(tiles_to_unfill, tile)
                end
            end

            for _, tile in pairs(tiles_to_unfill) do
                player.mine_tile(tile)
            end
        end
    end

    if event.item == "Foundations-place-tool" then
        if player_data.foundation ~= DISABLED then
            local entities = surface.find_entities_filtered({ area = event.area })
            if not entities then return end

            local tiles_to_place = {}

            for _, entity in pairs(entities) do
                if entity.valid then
                    if not entity_excluded(entity, player_data) and entity.name ~= "character" then
                        local entity_area = get_area_under_entity(entity)
                        if entity_area then
                            for x = math.floor(entity_area.left_top.x), math.ceil(entity_area.right_bottom.x) - 1 do
                                for y = math.floor(entity_area.left_top.y), math.ceil(entity_area.right_bottom.y) - 1 do
                                    local tile = surface.get_tile(x, y)
                                    if not tile then return end

                                    if tile.name ~= player_data.foundation then
                                        table.insert(tiles_to_place,
                                            { name = player_data.foundation, position = { x = x, y = y } })
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local count = table_size(tiles_to_place)
            if count > 0 and player_has_sufficient_tiles(player, player_data.foundation, count) then
                surface.set_tiles(tiles_to_place, true, false, true, true, player)
                local item_name = placeable_tiles[player_data.foundation]
                player.remove_item { name = item_name, count = count }
            end
        end
    end

    if event.item == "Foundations-unplace-tool" then
        if player_data.foundation ~= DISABLED then
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

                                if (tile.name == player_data.foundation or tile.name == "frozen-" .. player_data.foundation)
                                    and placeable_tiles[tile.name]
                                    and not entity_excluded(entity, player_data)
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
                    tile_name = tile.name
                    table.insert(tile_names, tile_name)
                end
            end
        end

        for x = previous_area.left_top.x, previous_area.right_bottom.x - 1 do
            for y = previous_area.left_top.y, previous_area.right_bottom.y - 1 do
                local position = { x = x, y = y }
                local tile = surface.get_tile(position.x, position.y)
                if not prototypes.tile[tile.name].is_foundation then
                    if not within_area(position, current_area) then
                        player.mine_tile(tile)
                        table.insert(tiles_to_place, { name = tile_name, position = position })
                    end
                end
            end
        end

        local count = table_size(tile_names)
        if count > 0 then
            for i = 1, count do
                local tile = tile_names[i]
                local item_name = storage.tile_to_item[tile]
                local tile_position = tiles_to_place[i] and tiles_to_place[i].position

                if not prototypes.tile[tile_name].is_foundation then
                    if item_name and tile_position then
                        surface.set_tiles({ { name = tile, position = tile_position } }, true, false, true, false, player)
                        player.remove_item { name = item_name, count = 1 }
                    end
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

    local player_data = get_player_data(player.index)
    if player_data.foundation == DISABLED then return end
    if prototypes.tile[player_data.foundation].is_foundation then return end

    if entity_excluded(event.moved_entity, player_data) then return end

    local surface = event.moved_entity.surface
    if not surface then return end

    local start_area = get_area_under_entity_at_position(event.moved_entity, event.start_pos)
    if not start_area then return end

    local move_tile = false
    local frozen_name = "frozen-" .. player_data.foundation
    for x = math.floor(start_area.left_top.x), math.ceil(start_area.right_bottom.x) - 1 do
        for y = math.floor(start_area.left_top.y), math.ceil(start_area.right_bottom.y) - 1 do
            local tile = surface.get_tile(x, y)
            if tile.name == player_data.foundation or tile.name == frozen_name then
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

local function on_gui_checked_state_changed(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    if not event.element or not event.element.valid then return end
    if not player.gui.screen.tile_selector_frame then return end

    local storage_key = event.element.name
    if not storage_key then return end

    local player_data = get_player_data(player.index)
    player_data.excludes[storage_key] = event.element.state == true

    load_excluded_name_list(player_data)
    load_excluded_type_list(player_data)
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
        refresh_player_ui(player)
    end
    if not dectorio_hazard then
        game.print(
            "Foundations warning: Dectorio startup setting 'Use default Factorio Hazard concrete style' should be enabled")
    end
end

local function close_tile_selector(player)
    destroy_tile_selector_gui(player)
end

local function on_gui_closed(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    local frame = get_tile_selector_frame(player)
    if not frame then
        set_tile_selector_open_state(player, false)
        return
    end

    local player_data = get_player_data(player.index)
    local closed_tile_selector = false

    if event.element and event.element.valid then
        closed_tile_selector = event.element == frame
    elseif player_data.tile_selector_open and player.opened ~= frame then
        closed_tile_selector = true
    end

    if closed_tile_selector then
        close_tile_selector(player)
        refresh_player_ui(player)
    end
end

local function on_lua_shortcut(event)
    if not event or event.prototype_name ~= "Foundations-toggle-button" then return end

    local player = game.get_player(event.player_index)
    if not player then return end
    if player.controller_type == defines.controllers.remote then return end
    if not is_compatible_surface(player) then return end

    if player.gui.screen.tile_selector_frame then
        close_tile_selector(player)
    else
        show_tile_selector_gui(player)
    end

    refresh_player_ui(player)
end

local function controller_changed(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    local player_data = get_player_data(player.index)

    if player.controller_type == defines.controllers.remote then
        player_data.reopen_tile_selector_on_controller_change = player_data.tile_selector_open == true

        if player_data.tile_selector_open then
            close_tile_selector(player)
        end

        player_data.last_selected = player_data.foundation
        player_data.foundation = DISABLED
        refresh_player_ui(player)
    else
        if player_data.last_selected then
            player_data.foundation = player_data.last_selected
            player_data.last_selected = nil
            refresh_player_ui(player)
        end

        if player_data.reopen_tile_selector_on_controller_change then
            player_data.reopen_tile_selector_on_controller_change = false
            show_tile_selector_gui(player)
            refresh_player_ui(player)
        end
    end
end

local function register_event_handlers()
    script.on_event(defines.events.on_player_controller_changed, controller_changed)
    script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
    script.on_event(defines.events.on_gui_click, on_gui_click)
    script.on_event(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)
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
