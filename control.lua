defines = defines or {}
script = script or {}
game = game or {}
global = global or {}
remote = remote or {}

require("constants")
require("utilities")

local mod_gui = require("mod-gui")

-- function to place tiles under the entity
local function place_foundation_under_entity(event)
    local entity = event.created_entity
    if not entity then
        entity = event.moved_entity
    end
    if not entity then
        return
    end

    local surface = entity.surface or {}
    local player = game.players[global.player_index] or {}

    if (not entity) or (not surface) or (not player) then
        return
    end

    if global.foundation == DISABLED or entity_excluded(entity) then
        return
    end

    -- calculate the tiles
    local area = get_area_under_entity(entity)
    local tiles_to_place, tiles_to_return = load_tiles(entity, area)

    if tiles_to_place then
        -- if not enough global.foundation, put entity back on cursor and destroy the placed entity, then exit
        if not player_has_sufficient_tiles(player, global.foundation, #tiles_to_place) then
            return_entity_to_cursor(player, entity)
            return
        end

        -- mine tiles that are not global.foundation
        for _, tile in pairs(tiles_to_return) do
            local tile_to_mine = surface.get_tile(tile.position.x, tile.position.y)
            player.mine_tile(tile_to_mine)
        end

        -- place tiles and remove items from player inventory
        if #tiles_to_place > 0 then
            local clean_sweep = settings.global["Foundations-clean-sweep"].value
            surface.set_tiles(tiles_to_place, true, false, clean_sweep, true)
            local item_name = global.tile_to_item[global.foundation]
            player.remove_item{name = item_name, count = #tiles_to_place}
        end
    end
end

local function update_button()
    local player = game.players[global.player_index]

    if not player then
        return
    end

    local button_flow = mod_gui.get_button_flow(player)
    local sprite_path = "tile/"..global.tile_names[global.tile_names_index]
    local tool_tip = {"sprite-button.Foundations-tooltip-"..global.tile_names[global.tile_names_index]}

    if global.tile_names_index == 1 then
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

local function button_clicked(event)
    if event.element and event.element.valid and event.element.name == THIS_MOD then
        local player = game.players[global.player_index]
        if event.button == defines.mouse_button_type.left then
            if event.control then
                if global.foundation ~= DISABLED and player.clear_cursor() then
                    player.cursor_stack.set_stack({name = "Foundations-fill-tool"})
                end
            else
                if global.tile_names_index < #global.tile_names then
                    global.tile_names_index = global.tile_names_index + 1
                else
                    global.tile_names_index = 1
                end
            end
        elseif event.button == defines.mouse_button_type.right then
            if global.tile_names_index > 1 then
                global.tile_names_index = global.tile_names_index - 1
            else
                global.tile_names_index = #global.tile_names
            end
        end

        global.foundation = global.tile_names[global.tile_names_index]
        update_button()
    end
end

local function entity_mined(event)
    local entity = event.entity or {}
    local surface = entity.surface or {}
    local player = game.players[global.player_index] or {}

    if global.foundation == DISABLED or entity_excluded(entity) then
        return
    end

    if (not entity) or (not surface) or (not player) then
        return
    end

    local area = get_area_under_entity(entity)

    -- mine the global.foundation tiles
    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local tile = surface.get_tile(x, y)
            if tile.name == global.foundation then
                player.mine_tile(tile)
            end
        end
    end
end

local function player_selected_area(event)
    if event.item and event.item == "Foundations-fill-tool" then
        local player = game.players[event.player_index] or {}
        if not player then
            return
        end

        if global.foundation ~= DISABLED then
            local surface = player.surface
            local mineable_tiles = get_mineable_tiles()
            local tiles_to_exclude = TILES_TO_EXCLUDE
            local tiles_to_place = {}

            -- scan the area, find valid empty positions that need a tile
            for _, position in pairs(event.tiles) do
                local tile = surface.get_tile(position.position.x, position.position.y)
                local search_area = {{position.position.x, position.position.y}, {position.position.x + 1, position.position.y + 1}}
                local resources = surface.find_entities_filtered({area = search_area, type = "resource"})

                if #resources == 0 and not mineable_tiles[tile.name] and (not tiles_to_exclude[tile.name] or tile.name == "landfill") then
                    table.insert(tiles_to_place, {name = global.foundation, position = {x = position.position.x, y = position.position.y}})
                end
            end

            if #tiles_to_place > 0 and player_has_sufficient_tiles(player, global.foundation, #tiles_to_place) then
                local clean_sweep = settings.global["Foundations-clean-sweep"].value
                surface.set_tiles(tiles_to_place, true, false, clean_sweep, true)
                local item_name = global.tile_to_item[global.foundation]
                player.remove_item{name = item_name, count = #tiles_to_place}
            end
        end
        player.clear_cursor()

        -- remove all copies of the Foundations-fill-tool from player inventory
        while player.get_item_count("Foundations-fill-tool") > 0 do
            player.remove_item({name = "Foundations-fill-tool", count = 1})
        end
    end
end

local function configuration_changed()
    load_global_data()
    update_button()
end

local function entity_moved(event)
    if not event then return end

    local entity = event.moved_entity
    if not entity then return end

    local surface = entity.surface
    local player = game.players[global.player_index]
    if not surface or not player then return end

    local mineable_tiles = get_mineable_tiles()
    local tiles_to_exclude = TILES_TO_EXCLUDE

    local previous_area = get_area_under_entity_at_position(entity, event.start_pos)
    local current_area = get_area_under_entity(entity)

    if previous_area and current_area then
        local tiles_to_place = {}
        local tile_name

        -- find a tile name of the tiles to be moved
        for x = current_area.left_top.x, current_area.right_bottom.x - 1 do
            for y = current_area.left_top.y, current_area.right_bottom.y - 1 do
                local position= {x = x, y = y}
                local tile = surface.get_tile(position.x, position.y)
                if tile and not within_area(position, previous_area) then
                    if tile.name and mineable_tiles[tile.name] and (not tiles_to_exclude[tile.name] or tile.name == "landfill") then
                        tile_name = tile.name
                        break
                    end
                end
            end
        end

        -- mine foundation tiles from vacated positions
        for x = previous_area.left_top.x, previous_area.right_bottom.x - 1 do
            for y = previous_area.left_top.y, previous_area.right_bottom.y - 1 do
                local position= {x = x, y = y}
                local tile = surface.get_tile(position.x, position.y)
                if not within_area(position, current_area) then
                    player.mine_tile(surface.get_tile(tile.position.x, tile.position.y))
                    table.insert(tiles_to_place, { name = tile_name, position = position})
                end
            end
        end

        -- fill vacated positions
        if #tiles_to_place > 0 then
            local clean_sweep = settings.global["Foundations-clean-sweep"].value
            local item_name = global.tile_to_item[tile_name]

            if item_name and mineable_tiles[tile_name] and (not tiles_to_exclude[tile_name] or tile_name == "landfill") then
                -- better to not raise an event if just moving tiles
                surface.set_tiles(tiles_to_place, true, false, clean_sweep, false)
                player.remove_item{name = item_name, count = #tiles_to_place}
            end
        end
    end
end

local function on_entity_moved(event)
    if global.foundation == DISABLED then
        return
    end

    if not event then
        return
    end

    local moved_entity = event.moved_entity
    if not moved_entity then
        return
    end

    entity_moved(event)
    place_foundation_under_entity(event)
end

local function register_event_handlers()
    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)
    script.on_event(defines.events.on_player_mined_entity, entity_mined)
    script.on_event(defines.events.on_robot_mined_entity, entity_mined)
    script.on_event(defines.events.on_player_selected_area, player_selected_area)

    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_entity_moved)
    end
end

local function on_init()
    global = global or {}
    global.tile_to_item = global.tile_to_item or {[DISABLED] = DISABLED}
    global.tile_names = global.tile_names or {DISABLED}
    global.tile_names_index = global.tile_names_index or 1
    global.foundation = global.foundation or global.tile_names[global.tile_names_index]
    global.excluded_name_list = global.excluded_name_list or {}
    global.excluded_type_list = global.excluded_type_list or {}
    global.player_index = global.player_index or 1

    register_event_handlers()
end

local function on_load()
    register_event_handlers()
end

script.on_configuration_changed(configuration_changed)
script.on_init(on_init)
script.on_load(on_load)
