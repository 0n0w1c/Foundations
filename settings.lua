require("constants")

local order_counter = 0

local function get_next_order()
    order_counter = order_counter + 1
    return string.format("a-%03d", order_counter)
end

-- startup
data:extend({
    {
        type = "int-setting",
        name = "Foundations-added-inventory-rows",
        setting_type = "startup",
        default_value = 0,
        allowed_values = INVENTORY_ROWS,
        order = get_next_order(),
    },
    {
        type = "double-setting",
        name = "Foundations-mining-time",
        setting_type = "startup",
        default_value = 0.1,
        allowed_values = MINING_TIMES,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-clean-sweep",
        setting_type = "startup",
        default_value = false,
        order = get_next_order()
    },
})

-- runtime-global
data:extend({
    {
        type = "bool-setting",
        name = "Foundations-exclude-small-medium-electric-poles",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-exclude-inserters",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-exclude-belts",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-stone-path",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-concrete",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-refined-concrete",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-hazard-concrete",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
    },
    {
        type = "bool-setting",
        name = "Foundations-refined-hazard-concrete",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
    }
})

if mods["aai-industry"] or mods["stone-path"] then
    data:extend({
        {
            type = "bool-setting",
            name = "Foundations-rough-stone-path",
            setting_type = "runtime-global",
            default_value = true,
            order = get_next_order(),
        }
    })
end
