if not FOUNDATION then return end

local function set_to_list(set)
    local list = {}
    for key, value in pairs(set) do
        if value then
            table.insert(list, key)
        end
    end
    return list
end

local TO_COPY                            = "space-platform-for-ground"
local NAME                               = "esp-foundation"

local tiles                              = data.raw["tile"]
local items                              = data.raw["item"]
local recipes                            = data.raw["recipe"]

local original_tile                      = tiles[TO_COPY]
local original_item                      = items[TO_COPY]
local original_recipe                    = recipes[TO_COPY]

local espf_tile                          = table.deepcopy(original_tile)

espf_tile.name                           = NAME
espf_tile.layer                          = tiles["stone-path"].layer - 1
espf_tile.is_foundation                  = true
espf_tile.can_be_part_of_blueprint       = true
espf_tile.allows_being_covered           = true
espf_tile.decorative_removal_probability = 1
espf_tile.bound_decoratives              = nil
espf_tile.placeable_by                   = { item = NAME, count = 1 }

data:extend({ espf_tile })

local espf_item         = table.deepcopy(original_item)

espf_item.name          = NAME
espf_item.subgroup      = items["stone-brick"].subgroup
espf_item.order         = "00[a-y]"
espf_item.stack_size    = 100
espf_item.weight        = 10000
espf_item.place_as_tile =
{
    result = NAME,
    condition_size = 1,
    condition = { layers = {} },
    tile_condition = set_to_list(FOUNDATION_TILE_CONDITIONS["F077ET-" .. NAME])
}

data:extend({ espf_item })

local espf_recipe = table.deepcopy(original_recipe)

espf_recipe.name = NAME
espf_recipe.results = { { type = "item", name = NAME, amount = 10 } }
espf_recipe.show_amount_in_title = true

table.insert(espf_recipe.ingredients, { type = "item", name = "landfill", amount = 10 })

data:extend({ espf_recipe })

ElectricTilesDataInterface.adaptTilePrototype({
    {
        tile = data.raw.tile["esp-foundation"],
        item = data.raw.item["esp-foundation"],
        recipe = data.raw.recipe["esp-foundation"],
        others = { add_copper_wire_icon = true, result_amount = 10 },
        technology = { "electric-tiles-tech" }
    }
})
