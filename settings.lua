require("constants")

local order_counter = 0

local function get_next_order()
    order_counter = order_counter + 1
    return string.format("a-%03d", order_counter)
end

local function get_default_layer(tile_color)
    for _, color in ipairs(COLORS) do
        if color.name == tile_color then
            return color.default - 27
        end
    end
    return 1
end

local hidden = not (mods["electric-tiles"] and mods["space-platform-for-ground"])

data.extend({
    {
        type = "bool-setting",
        name = "Foundations-halt-construction",
        setting_type = "startup",
        default_value = false,
        order = get_next_order()
    },
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
    {
        type = "bool-setting",
        name = "Foundations-space-platform-foundation",
        setting_type = "startup",
        default_value = false,
        order = get_next_order(),
        hidden = hidden
    },
    {
        type = "bool-setting",
        name = "Foundations-concrete-variants",
        setting_type = "startup",
        default_value = true,
        order = get_next_order(),
    },
    {
        type = "int-setting",
        name = "Foundations-acid-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("acid"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-black-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("black"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-blue-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("blue"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-brown-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("brown"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-cyan-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("cyan"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-green-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("green"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-orange-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("orange"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-pink-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("pink"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-purple-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("purple"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-red-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("red"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    },
    {
        type = "int-setting",
        name = "Foundations-yellow-refined-concrete-layer",
        setting_type = "startup",
        default_value = get_default_layer("yellow"),
        allowed_values = LAYER_SLOTS,
        order = get_next_order()
    }
})
