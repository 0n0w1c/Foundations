mod_gui = require("mod-gui")
compatibility = require("compatibility")

require("utilities")

local THIS_MOD = "Foundations"
local PLAYER_INDEX = 1

-- function to place tiles under the entity
local function place_foundation_under_entity(event)
    local entity = event.created_entity
    local surface = entity.surface
    local player = game.players[PLAYER_INDEX]

    -- if disabled, early exit
    if global.foundation == "disabled" then
        return
    end
    -- if the entity excluded, early exit
    if entity_excluded(entity) then
        return
    end

    -- calculate the tiles
    local area = get_area_under_entity(entity)
    local tiles_to_place, tiles_to_return = load_tiles(entity, area)

    if tiles_to_place then
        -- if not enough tiles, destroy the entity and return to player inventory
        if not player_has_sufficient_tiles(player, global.foundation, #tiles_to_place) then
            player.insert{name = entity.name, count = 1}
            entity.destroy()
            return
        end

        -- place the tiles
        if #tiles_to_place > 0 then
            surface.set_tiles(tiles_to_place)
        end

        -- if tiles placed, remove tiles from player inventory
        if #tiles_to_place > 0 then
            local item_name = global.tile_to_item[global.foundation]
            player.remove_item{name = item_name, count = #tiles_to_place}
        end

        -- return replaced tiles to player inventory
        for _, tile in pairs(tiles_to_return) do
            if tile.name then
                player.insert{name = tile.name, count = 1}
            end
        end
    end
end

local function update_button()
    local player = game.players[PLAYER_INDEX]
    local button_flow = mod_gui.get_button_flow(player)
    local sprite_path
    local tool_tip

    if global.tile_names_index == 1 then
        sprite_path = "Foundations-disabled"
        tool_tip = {"sprite-button.Foundations-tooltip-" .. "disabled"}
    else
        sprite_path = "tile/" .. global.tile_names[global.tile_names_index]
        tool_tip = {"sprite-button.Foundations-tooltip-" .. global.tile_names[global.tile_names_index]}
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
    if event.element.name == THIS_MOD then
        if event.button == defines.mouse_button_type.left then
            if global.tile_names_index < #global.tile_names then
                global.tile_names_index = global.tile_names_index + 1
            else
                global.tile_names_index = 1
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

local function configuration_changed()
    load_global_data()
    update_button()
end

local function on_player_mined_entity(event)
    local entity = event.entity
    local surface = entity.surface
    local player = game.players[event.player_index]
    local area = get_area_under_entity(entity)

    if settings.global["Foundations-player-mine-foundation"].value then
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
end

local function on_init()
    global = global or {}
    global.tile_to_item = global.tile_to_item or {["disabled"] = "disabled"}
    global.tile_names = global.tile_names or {"disabled"}
    global.tile_names_index = global.tile_names_index or 1
    global.foundation = global.foundation or global.tile_names[global.tile_names_index]
    global.exclusion_name_list = global.exclusion_name_list or {}
    global.exclusion_type_list = global.exclusion_type_list or {}

    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)

    script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)
--    script.on_event(defines.events.on_robot_mined_entity, on_robot_mined_entity)

--    script.on_event(defines.events.script_raised_built, place_foundation_under_entity)
--    script.on_event(defines.events.script_raised_revive, place_foundation_under_entity)
end

local function on_load()
    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)

    script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)
--    script.on_event(defines.events.on_robot_mined_entity, on_robot_mined_entity)

--    script.on_event(defines.events.script_raised_built, place_foundation_under_entity)
--    script.on_event(defines.events.script_raised_revive, place_foundation_under_entity)
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(configuration_changed)
