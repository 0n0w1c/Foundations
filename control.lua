local mod_gui = require("mod-gui")
local this_mod = "Foundations"
local player_index = 1

-- exclude specific names
local function load_exclusion_name_list()
    global.exclusion_name_list = {
        ["entity-ghost"] = true,
        ["tile-ghost"] = true
    }

    if settings.global["Foundations-exclude-small-medium-electric-poles"].value then
        global.exclusion_name_list["small-electric-pole"] = true
        global.exclusion_name_list["medium-electric-pole"] = true
        -- aai industry
        global.exclusion_name_list["small-iron-electric-pole"] = true
    end
end

-- exclude specific types
local function load_exclusion_type_list()

    global.exclusion_type_list = {
        ["entity-ghost"] = true,
        ["tile-ghost"] = true,
        ["car"] = true,
        ["cargo-wagon"] = true,
        ["fluid-wagon"] = true,
        ["locomotive"] = true,
        ["rail-planner"] = true,
        ["rail-signal"] = true,
        ["rail-chain-signal"] = true,
        ["spider-vehicle"] = true
    }

    if settings.global["Foundations-exclude-inserters"].value then
        global.exclusion_type_list["inserter"] = true
    end

    if settings.global["Foundations-exclude-belts"].value then
        global.exclusion_type_list["transport-belt"] = true
        global.exclusion_type_list["underground-belt"] = true
        global.exclusion_type_list["splitter"] = true
        global.exclusion_type_list["loader"] = true
    end
end

-- check if an entity is excluded based on name or type
local function entity_excluded(entity)
    if global.exclusion_name_list[entity.name] then
        return true
    end
    if global.exclusion_type_list[entity.type] then
        return true
    end
    return false
end

-- check if the tile is in global.tile_names 
local function tile_in_global_tile_names(tile)
    for _, tile_name in ipairs(global.tile_names) do
        if tile_name == tile then
            return true
        end
    end
    return false
end

-- check if the recipe has been enabled
local function recipe_enabled(force, recipe_name)
    local recipe = force.recipes[recipe_name]
    if recipe then
        return recipe.enabled
    else
        -- if no recipe, add it (ex. stone to rough-stone-path has no recipe)
        return true
    end
end

-- insert into global.tile_names and global.tile_to_item, if not already present and recipe enabled
local function add_to_tables(tile, item)
    local force = game.forces["player"]
    if force and item then
        if not tile_in_global_tile_names(tile) and recipe_enabled(force, item) then
            table.insert(global.tile_names, tile)
            global.tile_to_item[tile] = item
        end
    end
end

local function load_global_data()
    global.foundation = global.foundation or "disabled"

    load_exclusion_name_list()
    load_exclusion_type_list()

    -- start fresh, tiles could be added or removed
    global.tile_names = {}

    -- add disabled, at positon 1
    add_to_tables("disabled", "disabled")

    if settings.global["Foundations-stone-path"].value then
        add_to_tables("stone-path", "stone-brick")
    end
    if settings.global["Foundations-concrete"].value then
        add_to_tables("concrete", "concrete")
    end
    if settings.global["Foundations-refined-concrete"].value then
        add_to_tables("refined-concrete", "refined-concrete")
    end
    if settings.global["Foundations-hazard-concrete"].value then
        add_to_tables("hazard-concrete-left", "hazard-concrete")
        add_to_tables("hazard-concrete-right", "hazard-concrete")
    end
    if settings.global["Foundations-refined-hazard-concrete"].value then
        add_to_tables("refined-hazard-concrete-left", "refined-hazard-concrete")
        add_to_tables("refined-hazard-concrete-right", "refined-hazard-concrete")
    end

    -- survey the active mods, add support for specific mods
    for mod_name, version in pairs(game.active_mods) do
        if mod_name == "aai-industry" then
            if settings.startup["aai-stone-path"].value and settings.global["Foundations-rough-stone-path"].value then
                add_to_tables("rough-stone-path", "stone")
            end
        end
        if mod_name == "Dectorio" then
            if settings.startup["dectorio-wood"].value and settings.global["Foundations-dect-wood-floor"].value then
                add_to_tables("dect-wood-floor", "dect-wood-floor")
            end
            if settings.startup["dectorio-concrete"].value and settings.global["Foundations-dect-concrete-grid"].value then
                add_to_tables("dect-concrete-grid", "dect-concrete-grid")
            end
            if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-coal-gravel"].value then
                add_to_tables("dect-coal-gravel", "dect-coal-gravel")
            end
            if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-copper-ore-gravel"].value then
                add_to_tables("dect-copper-ore-gravel", "dect-copper-ore-gravel")
            end
            if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-iron-ore-gravel"].value then
                add_to_tables("dect-iron-ore-gravel", "dect-iron-ore-gravel")
            end
            if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-stone-gravel"].value then
                add_to_tables("dect-stone-gravel", "dect-stone-gravel")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-danger"].value then
                add_to_tables("dect-paint-danger-left", "dect-paint-danger")
                add_to_tables("dect-paint-danger-right", "dect-paint-danger")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-emergency"].value then
                add_to_tables("dect-paint-emergency-left", "dect-paint-emergency")
                add_to_tables("dect-paint-emergency-right", "dect-paint-emergency")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-caution"].value then
                add_to_tables("dect-paint-caution-left", "dect-paint-caution")
                add_to_tables("dect-paint-caution-right", "dect-paint-caution")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-radiation"].value then
                add_to_tables("dect-paint-radiation-left", "dect-paint-radiation")
                add_to_tables("dect-paint-radiation-right", "dect-paint-radiation")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-defect"].value then
                add_to_tables("dect-paint-defect-left", "dect-paint-defect")
                add_to_tables("dect-paint-defect-right", "dect-paint-defect")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-operations"].value then
                add_to_tables("dect-paint-operations-left", "dect-paint-operations")
                add_to_tables("dect-paint-operations-right", "dect-paint-operations")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-safety"].value then
                add_to_tables("dect-paint-safety-left", "dect-paint-safety")
                add_to_tables("dect-paint-safety-right", "dect-paint-safety")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-danger"].value then
                add_to_tables("dect-paint-refined-danger-left", "dect-paint-refined-danger")
                add_to_tables("dect-paint-refined-danger-right", "dect-paint-refined-danger")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-emergency"].value then
                add_to_tables("dect-paint-refined-emergency-left", "dect-paint-refined-emergency")
                add_to_tables("dect-paint-refined-emergency-right", "dect-paint-refined-emergency")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-caution"].value then
                add_to_tables("dect-paint-refined-caution-left", "dect-paint-refined-caution")
                add_to_tables("dect-paint-refined-caution-right", "dect-paint-refined-caution")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-radiation"].value then
                add_to_tables("dect-paint-refined-radiation-left", "dect-paint-refined-radiation")
                add_to_tables("dect-paint-refined-radiation-right", "dect-paint-refined-radiation")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-defect"].value then
                add_to_tables("dect-paint-refined-defect-left", "dect-paint-refined-defect")
                add_to_tables("dect-paint-refined-defect-right", "dect-paint-refined-defect")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-operations"].value then
                add_to_tables("dect-paint-refined-operations-left", "dect-paint-refined-operations")
                add_to_tables("dect-paint-refined-operations-right", "dect-paint-refined-operations")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-safety"].value then
                add_to_tables("dect-paint-refined-safety-left", "dect-paint-refined-safety")
                add_to_tables("dect-paint-refined-safety-right", "dect-paint-refined-safety")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-acid-refined-concrete"].value then
                add_to_tables("acid-refined-concrete", "dect-acid-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-black-refined-concrete"].value then
                add_to_tables("black-refined-concrete", "dect-black-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-blue-refined-concrete"].value then
                add_to_tables("blue-refined-concrete", "dect-blue-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-brown-refined-concrete"].value then
                add_to_tables("brown-refined-concrete", "dect-brown-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-cyan-refined-concrete"].value then
                add_to_tables("cyan-refined-concrete", "dect-cyan-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-green-refined-concrete"].value then
                add_to_tables("green-refined-concrete", "dect-green-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-orange-refined-concrete"].value then
                add_to_tables("orange-refined-concrete", "dect-orange-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-pink-refined-concrete"].value then
                add_to_tables("pink-refined-concrete", "dect-pink-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-purple-refined-concrete"].value then
                add_to_tables("purple-refined-concrete", "dect-purple-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-red-refined-concrete"].value then
                add_to_tables("red-refined-concrete", "dect-red-refined-concrete")
            end
            if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-yellow-refined-concrete"].value then
                add_to_tables("yellow-refined-concrete", "dect-yellow-refined-concrete")
            end
        end
        if mod_name == "Krastorio2" then
            if settings.global["Foundations-kr-black-reinforced-plate"].value then
                add_to_tables("kr-black-reinforced-plate", "kr-black-reinforced-plate")
            end
            if settings.global["Foundations-kr-white-reinforced-plate"].value then
                add_to_tables("kr-white-reinforced-plate", "kr-white-reinforced-plate")
            end
        end
        if mod_name == "LunarLandings" and settings.global["Foundations-ll-lunar-foundation"].value then
            add_to_tables("ll-lunar-foundation", "ll-lunar-foundation")
        end
        if mod_name == "space-exploration" then
            if settings.global["Foundations-se-space-platform-scaffold"].value then
                add_to_tables("se-space-platform-scaffold", "se-space-platform-scaffold")
            end
            if settings.global["Foundations-se-spaceship-floor"].value then
                add_to_tables("se-spaceship-floor", "se-spaceship-floor")
            end
        end
    end

    if global.foundation then
        -- try to find the foundation in fresh global.tile_names
        local found = false
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
            global.foundation = "disabled"
        end
    else
        global.tile_names_index = 1
        global.foundation = "disabled"
    end
end

-- check if the player has sufficient tiles in their inventory
local function player_has_sufficient_tiles(player, tile_name, count)
    local item_name = global.tile_to_item[tile_name]
    return item_name and player.get_item_count(item_name) >= count
end

-- get the bounds of the entity
local function get_entity_bounds(entity)
    local prototype
    if entity.type == "entity-ghost" then
        prototype = game.entity_prototypes[entity.ghost_prototype.name]
    else
        prototype = entity.prototype
    end
    local collision_box = prototype.collision_box
    return collision_box
end

-- function to place tiles under the entity
local function place_foundation_under_entity(event)
    local entity = event.created_entity
    local surface = entity.surface
    local position = entity.position
    local player = game.players[player_index]
    local tile_name = global.tile_names and global.tile_names[global.tile_names_index]
    -- if no tile_name is available, early exit
    if not tile_name then
        return
    end
    -- if disabled, early exit
    if global.tile_names_index == 1 then
        return
    end
    -- if the entity excluded, early exit
    if entity_excluded(entity) then
        return
    end
    -- get entity bounds
    local bounds = get_entity_bounds(entity)
    local area = {}

    -- adjust bounds based on entity direction
    if entity.direction == defines.direction.east or entity.direction == defines.direction.west then
        area.left_top = {x = position.x + bounds.left_top.y, y = position.y + bounds.left_top.x}
        area.right_bottom = {x = position.x + bounds.right_bottom.y, y = position.y + bounds.right_bottom.x}
    else
        area.left_top = {x = position.x + bounds.left_top.x, y = position.y + bounds.left_top.y}
        area.right_bottom = {x = position.x + bounds.right_bottom.x, y = position.y + bounds.right_bottom.y}
    end

    -- calculate the required tile positions
    local tiles_to_place = {}
    local tiles_to_return = {}

    for x = math.floor(area.left_top.x), math.ceil(area.right_bottom.x) - 1 do
        for y = math.floor(area.left_top.y), math.ceil(area.right_bottom.y) - 1 do
            local current_tile = surface.get_tile(x, y)
            -- check if the tile is a water tile or a resource tile
            if current_tile.prototype.collision_mask["water-tile"] or current_tile.prototype.collision_mask["resource"] then
                return
            end
            -- track the current tile to return it to the player
            if current_tile.name ~= tile_name then
                local return_item = {name = current_tile.name, count = 1}
                local item_name = global.tile_to_item[current_tile.name]
                return_item.name = item_name
                if tile_in_global_tile_names(current_tile.name) then
                    table.insert(tiles_to_return, return_item)
                end
            end
            -- prepare to place the tile
            table.insert(tiles_to_place, {name = tile_name, position = {x = x, y = y}})
        end
    end

    -- check if the player has sufficient tiles
    if not player_has_sufficient_tiles(player, tile_name, #tiles_to_place) then
        -- if insufficient tiles, prevent placement and return entity to player inventory
        if entity.type == "entity-ghost" or entity.type == "tile-ghost" then
            -- do not return these to player inventory
        else
            -- hot fix: needs better
            -- rails change item name when placed
            local new_entity = entity.name
            if entity.name == "curved-rail" or entity.name == "straight-rail" then
                new_entity = "rail"
            end
            player.insert{name = new_entity, count = 1}
        end

        -- entity is not to be placed
        entity.destroy()
        return
    end

    -- place the tiles
    surface.set_tiles(tiles_to_place)

    -- remove tiles from player inventory
    local item_name = global.tile_to_item[tile_name]
    player.remove_item{name = item_name, count = #tiles_to_place}

    -- return replaced tiles to player inventory
    for _, tile in pairs(tiles_to_return) do
        if tile.name then
            player.insert{name = tile.name, count = 1}
        end
    end
end

local function update_button()
    local player = game.players[player_index]
    local button_flow = mod_gui.get_button_flow(player)
    local sprite_path
    local tool_tip

    if global.tile_names_index == 1 then
        sprite_path = "item/" .. "deconstruction-planner"
        tool_tip = {"sprite-button.Foundations-tooltip-" .. "disabled"}
    else
        sprite_path = "tile/" .. global.tile_names[global.tile_names_index]
        tool_tip = {"sprite-button.Foundations-tooltip-" .. global.tile_names[global.tile_names_index]}
    end
    if not button_flow[this_mod] then
        button_flow.add {
            type = "sprite-button",
            name = this_mod,
            sprite = sprite_path,
            tooltip = tool_tip,
            style = mod_gui.button_style
        }
    else
        button_flow[this_mod].sprite = sprite_path
        button_flow[this_mod].tooltip = tool_tip
    end
end

local function button_clicked(event)
    if event.element.name == this_mod then
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

local function on_init()
    global = global or {}
    global.tile_to_item = global.tile_to_item or {["disabled"] = "disabled"}
    global.tile_names = global.tile_names or {"disabled"}
    global.tile_names_index = global.tile_names_index or 1
    global.foundation = global.foundation or global.tile_names[global.tile_names_index]
    global.exclusion_name_list = {}
    global.exclusion_type_list = {}

    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)
end

local function on_load()
    script.on_event(defines.events.on_gui_click, button_clicked)
    script.on_event(defines.events.on_runtime_mod_setting_changed, configuration_changed)
    script.on_event(defines.events.on_research_finished, configuration_changed)
    script.on_event(defines.events.on_player_created, configuration_changed)
    script.on_event(defines.events.on_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_robot_built_entity, place_foundation_under_entity)
    script.on_event(defines.events.on_entity_cloned, place_foundation_under_entity)
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(configuration_changed)
