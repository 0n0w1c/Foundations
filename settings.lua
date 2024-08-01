local order_counter = 0

local function get_next_order()
    order_counter = order_counter + 1
    return string.format("a-%03d", order_counter)
end

data:extend({
    {
        type = "bool-setting",
        name = "Foundations-player-mine-foundation",
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
    },
    {
        type = "bool-setting",
        name = "Foundations-rough-stone-path",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["aai-industry"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-wood-floor",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-concrete-grid",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-coal-gravel",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-copper-ore-gravel",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-iron-ore-gravel",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-stone-gravel",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-danger",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-emergency",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-caution",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-radiation",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-defect",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-operations",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-safety",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-danger",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-emergency",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-caution",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-radiation",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-defect",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-operations",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-dect-paint-refined-safety",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-acid-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-black-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-blue-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-brown-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-cyan-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-green-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-orange-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-pink-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-purple-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-red-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-yellow-refined-concrete",
        setting_type = "runtime-global",
        default_value = false,
        order = get_next_order(),
        hidden = not mods["Dectorio"]
    },
    {
        type = "bool-setting",
        name = "Foundations-kr-black-reinforced-plate",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["Krastorio2"]
    },
    {
        type = "bool-setting",
        name = "Foundations-kr-white-reinforced-plate",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["Krastorio2"]
    },
    {
        type = "bool-setting",
        name = "Foundations-ll-lunar-foundation",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["LunarLandings"]
    },
    {
        type = "bool-setting",
        name = "Foundations-se-space-platform-scaffold",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["space-exploration"]
    },
    {
        type = "bool-setting",
        name = "Foundations-se-spaceship-floor",
        setting_type = "runtime-global",
        default_value = true,
        order = get_next_order(),
        hidden = not mods["space-exploration"]
    }
})
