if not FOUNDATION then return end

if mods["VoidBlock"] then
    FOUNDATION_TILE_CONDITIONS["F077ET-esp-foundation"]["s6x-voidocean"] = true
end

local function copy_field(source, target, field)
    if source[field] ~= nil then
        target[field] = table.deepcopy(source[field])
    end
end

local NON_GROUND_TILE_CONDITIONS =
{
    ["water"] = true,
    ["deepwater"] = true,
    ["water-green"] = true,
    ["deepwater-green"] = true,
    ["water-mud"] = true,
    ["water-shallow"] = true,
    ["wetland-light-green-slime"] = true,
    ["wetland-green-slime"] = true,
    ["wetland-light-dead-skin"] = true,
    ["wetland-dead-skin"] = true,
    ["wetland-pink-tentacle"] = true,
    ["wetland-red-tentacle"] = true,
    ["wetland-yumako"] = true,
    ["wetland-jellynut"] = true,
    ["oil-ocean-shallow"] = true,
    ["oil-ocean-deep"] = true,
    ["lava"] = true,
    ["lava-hot"] = true,
    ["wetland-blue-slime"] = true,
    ["gleba-deep-lake"] = true,
    ["ammoniacal-ocean"] = true,
    ["ammoniacal-ocean-2"] = true,
    ["brash-ice"] = true,
}

local function is_non_ground_tile(tile_name, tile)
    if NON_GROUND_TILE_CONDITIONS[tile_name] then return true end
    if tile and tile.default_cover_tile then return true end
    return false
end

local function is_natural_ground_tile(tile_name, tile)
    if is_non_ground_tile(tile_name, tile) then return false end
    if tile.is_foundation then return false end
    if tile.minable then return false end
    if tile.placeable_by then return false end
    return true
end

local function get_natural_ground_tile_condition_list()
    local list = {}

    for name, tile in pairs(data.raw.tile or {}) do
        if is_natural_ground_tile(name, tile) then
            table.insert(list, name)
        end
    end

    return list
end

local function get_natural_ground_and_foundation_tile_condition_list()
    local list = {}

    for name, tile in pairs(data.raw.tile or {}) do
        if is_natural_ground_tile(name, tile) or tile.is_foundation then
            table.insert(list, name)
        end
    end

    return list
end

local function get_tile_condition_list(tile_name, ground_only)
    local conditions = FOUNDATION_TILE_CONDITIONS[tile_name]
    local included = {}
    local list = {}

    local function add(name)
        if not included[name] and data.raw.tile[name] then
            included[name] = true
            table.insert(list, name)
        end
    end

    if ground_only then
        for _, name in pairs(get_natural_ground_tile_condition_list()) do
            add(name)
        end
    elseif conditions then
        for name, allowed in pairs(conditions) do
            if allowed then
                add(name)
            end
        end

        for _, name in pairs(get_natural_ground_tile_condition_list()) do
            add(name)
        end
    end

    return list
end

local function configure_tile_item(item, result, tile_condition)
    if item then
        item.place_as_tile = item.place_as_tile or {}
        item.place_as_tile.result = result
        item.place_as_tile.condition_size = item.place_as_tile.condition_size or 1
        item.place_as_tile.condition = { layers = {} }
        item.place_as_tile.tile_condition = table.deepcopy(tile_condition)
    end
end

local FOUNDATION_TILE = "foundation"
local VISUAL_TILE     = "space-platform-for-ground"
local NAME            = "esp-foundation"

local tiles           = data.raw["tile"]
local items           = data.raw["item"]
local recipes         = data.raw["recipe"]

local foundation_tile = tiles[FOUNDATION_TILE]
local foundation_item = items[FOUNDATION_TILE]
local visual_tile     = tiles[VISUAL_TILE]
local visual_item     = items[VISUAL_TILE]
local visual_recipe   = recipes[VISUAL_TILE]

if not foundation_tile or not foundation_item or not visual_tile or not visual_item then return end

visual_tile.is_foundation = false
visual_tile.allows_being_covered = true
visual_tile.placeable_by = { item = VISUAL_TILE, count = 1 }
if visual_tile.minable then
    visual_tile.minable.result = VISUAL_TILE
end
configure_tile_item(visual_item, VISUAL_TILE, get_natural_ground_and_foundation_tile_condition_list())
visual_item.order                         = "c[landfill]-y[space-platform-for-ground]"
visual_item.subgroup                      = items["stone-brick"].subgroup

local espf_tile                           = table.deepcopy(foundation_tile)

espf_tile.name                            = NAME
espf_tile.layer                           = 8
espf_tile.order                           = (foundation_tile.order or "") .. "-z[esp-foundation]"
espf_tile.is_foundation                   = true
espf_tile.transition_overlay_layer_offset = 0
espf_tile.can_be_part_of_blueprint        = true
espf_tile.allows_being_covered            = true
espf_tile.decorative_removal_probability  = 1.0
espf_tile.walking_speed_modifier          = 1.0
espf_tile.vehicle_friction_modifier       = 1.2
espf_tile.placeable_by                    = { item = NAME, count = 1 }
espf_tile.minable                         = table.deepcopy(foundation_tile.minable)
if espf_tile.minable then
    espf_tile.minable.result = NAME
end

copy_field(visual_tile, espf_tile, "variants")
copy_field(visual_tile, espf_tile, "transitions")
copy_field(visual_tile, espf_tile, "transitions_between_transitions")
copy_field(visual_tile, espf_tile, "walking_sound")
copy_field(visual_tile, espf_tile, "build_sound")
copy_field(visual_tile, espf_tile, "mined_sound")
copy_field(visual_tile, espf_tile, "map_color")
copy_field(visual_tile, espf_tile, "scorch_mark_color")
copy_field(visual_tile, espf_tile, "sprite_usage_surface")
copy_field(visual_tile, espf_tile, "bound_decoratives")

if not settings.startup["Foundations-espf-include-decorations"] or settings.startup["Foundations-espf-include-decorations"].value == false then
    espf_tile.bound_decoratives = nil
end

data:extend({ espf_tile })

local espf_item         = table.deepcopy(foundation_item)

espf_item.name          = NAME
espf_item.icon          = visual_item.icon
espf_item.icons         = table.deepcopy(visual_item.icons)
espf_item.subgroup      = items["stone-brick"].subgroup
espf_item.order         = "c[landfill]-z[esp-foundation]"
espf_item.stack_size    = 100
espf_item.weight        = 10000
espf_item.place_as_tile = table.deepcopy(foundation_item.place_as_tile)
configure_tile_item(espf_item, NAME, get_tile_condition_list(NAME))

if visual_item.random_tint_color then
    espf_item.random_tint_color = table.deepcopy(visual_item.random_tint_color)
end

data:extend({ espf_item })

local espf_recipe = table.deepcopy(visual_recipe)

espf_recipe.name = NAME
espf_recipe.show_amount_in_title = true
espf_recipe.results = { { type = "item", name = NAME, amount = 10 } }


espf_recipe.ingredients =
{
    { type = "item", name = "space-platform-for-ground", amount = 10 },
    { type = "item", name = "landfill",                  amount = 10 },
}

data:extend({ espf_recipe })

local landfill_technology = data.raw.technology["landfill"]
if landfill_technology then
    landfill_technology.effects = landfill_technology.effects or {}

    table.insert(landfill_technology.effects, {
        type = "unlock-recipe",
        recipe = "esp-foundation"
    })
end

local electric_recipe = table.deepcopy(recipes[espf_recipe.name])
electric_recipe.ingredients =
{
    { type = "item", name = "esp-foundation", amount = 10 },
    { type = "item", name = "copper-cable",   amount = 20 },
}

ElectricTilesDataInterface.modTilePrototypes({
    {
        tile = data.raw.tile[NAME],
        item = data.raw.item[NAME],
        recipe = electric_recipe,
        others = { add_copper_wire_icon = true, result_amount = 10, technologies = { "F077ET-technology" } }
    }
})

configure_tile_item(data.raw.item["F077ET-" .. NAME], "F077ET-" .. NAME, get_tile_condition_list(NAME))
