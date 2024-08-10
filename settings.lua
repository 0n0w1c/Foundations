require("constants")

local order_counter = 0

local function get_next_order()
    order_counter = order_counter + 1
    return string.format("a-%03d", order_counter)
end

-- startup
if mods["Dectorio"] and not mods["alien-biomes"] then
    data:extend({
        {
            type = "bool-setting",
            name = "Foundations-stack-concrete",
            setting_type = "startup",
            default_value = true,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-refined-concrete-layer",
            setting_type = "startup",
            default_value = 11,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-acid-refined-concrete-layer",
            setting_type = "startup",
            default_value = 10,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-black-refined-concrete-layer",
            setting_type = "startup",
            default_value = 0,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-blue-refined-concrete-layer",
            setting_type = "startup",
            default_value = 4,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-brown-refined-concrete-layer",
            setting_type = "startup",
            default_value = 1,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-cyan-refined-concrete-layer",
            setting_type = "startup",
            default_value = 9,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-green-refined-concrete-layer",
            setting_type = "startup",
            default_value = 3,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-orange-refined-concrete-layer",
            setting_type = "startup",
            default_value = 5,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-pink-refined-concrete-layer",
            setting_type = "startup",
            default_value = 7,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-purple-refined-concrete-layer",
            setting_type = "startup",
            default_value = 8,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-red-refined-concrete-layer",
            setting_type = "startup",
            default_value = 2,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        },
        {
            type = "int-setting",
            name = "Foundations-yellow-refined-concrete-layer",
            setting_type = "startup",
            default_value = 6,
            allowed_values = STACKING_SLOTS,
            order = get_next_order()
        }
    })
end

-- runtime-global
data:extend({
    {
        type = "bool-setting",
        name = "Foundations-clean-sweep",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order()
    },
        {
        type = "bool-setting",
        name = "Foundations-mine-foundation",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
    },
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

if mods["aai-industry"] then
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

if mods["Dectorio"] then
    data:extend({
        {
            type = "bool-setting",
            name = "Foundations-dect-wood-floor",
            setting_type = "runtime-global",
            default_value = true,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-concrete-grid",
            setting_type = "runtime-global",
            default_value = true,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-coal-gravel",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-copper-ore-gravel",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-iron-ore-gravel",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-stone-gravel",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-caution",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-danger",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-defect",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-emergency",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-operations",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-radiation",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-safety",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-caution",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-danger",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-defect",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-emergency",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-operations",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-radiation",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-dect-paint-refined-safety",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-acid-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-black-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-blue-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-brown-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-cyan-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-green-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-orange-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-pink-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-purple-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-red-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-yellow-refined-concrete",
            setting_type = "runtime-global",
            default_value = false,
            order = get_next_order(),
        }
    })
end

if mods["Krastorio2"] then
    data:extend({
        {
            type = "bool-setting",
            name = "Foundations-kr-black-reinforced-plate",
            setting_type = "runtime-global",
            default_value = true,
            order = get_next_order(),
        },
        {
            type = "bool-setting",
            name = "Foundations-kr-white-reinforced-plate",
            setting_type = "runtime-global",
            default_value = true,
            order = get_next_order(),
        }
    })
end
