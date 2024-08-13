THIS_MOD = "Foundations"
DISABLED = "disabled"
STACKING_SLOTS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
TARMAC_SLOT = 12
TARMAC_LAYER = TARMAC_SLOT * 3 + 200
WOOD_SLOT = 13 -- highest stacking slot
WOOD_LAYER = WOOD_SLOT * 3 + 200

GRAVELS = {
    "coal",
    "copper-ore",
    "iron-ore",
    "stone"
}

PAINTED_CONCRETE = {
    "caution",
    "danger",
    "defect",
    "emergency",
    "operations",
    "radiation",
    "safety"
}

COLORS = {
    { name = "acid"  , rgb_color = { r = 0.559, g = 0.761, b = 0.157, a = 0.5 }},
    { name = "black" , rgb_color = { r = 0.5  , g = 0.5  , b = 0.5  , a = 0.5 }},
    { name = "blue"  , rgb_color = { r = 0.155, g = 0.540, b = 0.898, a = 0.5 }},
    { name = "brown" , rgb_color = { r = 0.700, g = 0.517, b = 0.4  , a = 0.5 }},
    { name = "cyan"  , rgb_color = { r = 0.275, g = 0.755, b = 0.712, a = 0.5 }},
    { name = "green" , rgb_color = { r = 0.093, g = 0.768, b = 0.172, a = 0.5 }},
    { name = "orange", rgb_color = { r = 0.869, g = 0.5  , b = 0.130, a = 0.5 }},
    { name = "pink"  , rgb_color = { r = 0.929, g = 0.386, b = 0.514, a = 0.5 }},
    { name = "purple", rgb_color = { r = 0.485, g = 0.111, b = 0.659, a = 0.5 }},
    { name = "red"   , rgb_color = { r = 0.815, g = 0.024, b = 0.0  , a = 0.5 }},
    { name = "yellow", rgb_color = { r = 0.835, g = 0.666, b = 0.077, a = 0.5 }}
}

EXCLUDED_NAME_LIST = {
    ["curved-rail"] = true,
    ["entity-ghost"] = true,
    ["straight-rail"] = true,
    ["tile-ghost"] = true
}

EXCLUDED_TYPE_LIST = {
    ["car"] = true,
    ["cargo-wagon"] = true,
    ["entity-ghost"] = true,
    ["fluid-wagon"] = true,
    ["locomotive"] = true,
    ["mining-drill"] = true,
    ["offshore-pump"] = true,
    ["rail-chain-signal"] = true,
    ["rail-planner"] = true,
    ["rail-signal"] = true,
    ["spider-vehicle"] = true,
    ["straight-rail"] = true,
    ["tile-ghost"] = true
}

TILES_TO_EXCLUDE = {
    ["deepwater"] = true,
    ["deepwater-green"] = true,
    ["landfill"] = true,
    ["out-of-map"] = true,
    ["water"] = true,
    ["water-green"] = true,
    ["water-mud"] = true,
    ["water-shallow"] = true
}
