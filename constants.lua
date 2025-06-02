THIS_MOD = "Foundations"
MOD_PATH = "__" .. THIS_MOD .. "__"
DISABLED = "Disabled"
INVENTORY_ROWS = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
MINING_TIMES = { 0, 0.1, 0.2, 0.3, 0.4, 0.5 }
LAYER_SLOTS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }

COMPATIBLE_SURFACES = {
    ["nauvis"] = true,
    ["vulcanus"] = true,
    ["fulgora"] = true,
    ["gleba"] = true,
    ["aquilo"] = true
}

BASE_TILES = {
    { name = "stone-path",                     default = 11 },
    { name = "frozen-stone-path",              default = 12 },
    { name = "concrete",                       default = 13 },
    { name = "frozen-concrete",                default = 14 },
    { name = "hazard-concrete",                default = 15 },
    { name = "frozen-hazard-concrete-left",    default = 15 },
    { name = "frozen-hazard-concrete-right",   default = 15 },
    { name = "refined-concrete",               default = 17 },
    { name = "frozen-refined-concrete",        default = 18 },
    { name = "refined-hazard-concrete-left",   default = 19 },
    { name = "refined-hazard-concrete-right",  default = 19 },
    { name = "frozen-refined-hazard-concrete", default = 20 }
}

COLORS = {
    { name = "acid",   default = 38 },
    { name = "black",  default = 35 },
    { name = "blue",   default = 30 },
    { name = "brown",  default = 36 },
    { name = "cyan",   default = 37 },
    { name = "green",  default = 29 },
    { name = "orange", default = 31 },
    { name = "pink",   default = 33 },
    { name = "purple", default = 34 },
    { name = "red",    default = 28 },
    { name = "yellow", default = 32 }
}

EXCLUDED_NAME_LIST = {
    ["entity-ghost"] = true,
    ["tile-ghost"] = true
}

EXCLUDED_TYPE_LIST = {
    ["artillery-wagon"] = true,
    ["car"] = true,
    ["cargo-wagon"] = true,
    ["cliff"] = true,
    ["curved-rail-a"] = true,
    ["curved-rail-b"] = true,
    ["elevated-curved-rail-a"] = true,
    ["elevated-curved-rail-b"] = true,
    ["elevated-half-diagonal-rail"] = true,
    ["elevated-straight-rail"] = true,
    ["entity-ghost"] = true,
    ["fish"] = true,
    ["fluid-wagon"] = true,
    ["half-diagonal-rail"] = true,
    ["land-mine"] = true,
    ["legacy-curved-rail"] = true,
    ["legacy-straight-rail"] = true,
    ["locomotive"] = true,
    ["mining-drill"] = true,
    ["offshore-pump"] = true,
    ["rail-chain-signal"] = true,
    ["rail-planner"] = true,
    ["rail-ramp"] = true,
    ["rail-signal"] = true,
    ["rail-support"] = true,
    ["simple-entity"] = true,
    ["spider-vehicle"] = true,
    ["straight-rail"] = true,
    ["tile-ghost"] = true,
    ["tree"] = true,
    ["wall"] = true
}

TILES_TO_EXCLUDE = {
    ["ammoniacal-ocean"] = true,
    ["ammoniacal-ocean-2"] = true,
    ["brash-ice"] = true,
    ["deepwater"] = true,
    ["deepwater-green"] = true,
    ["gleba-deep-lake"] = true,
    ["lava"] = true,
    ["lava-hot"] = true,
    ["oil-ocean-deep"] = true,
    ["oil-ocean-shallow"] = true,
    ["water"] = true,
    ["water-green"] = true,
    ["water-mud"] = true,
    ["water-shallow"] = true,
    ["water-wube"] = true,
    ["wetland-blue-slime"] = true,
    ["wetland-dead-skin"] = true,
    ["wetland-green-slime"] = true,
    ["wetland-jellynut"] = true,
    ["wetland-light-dead-skin"] = true,
    ["wetland-light-green-slime"] = true,
    ["wetland-pink-tentacle"] = true,
    ["wetland-red-tentacle"] = true,
    ["wetland-yumako"] = true
}

--[[
FOUNDATION_TILES = {
    ["landfill"] = true,
    ["space-platform-foundation"] = true,
    ["foundation"] = true,
    ["artificial-yumako-soil"] = true,
    ["overgrowth-yumako-soil"] = true,
    ["artificial-jellynut-soil"] = true,
    ["overgrowth-jellynut-soil"] = true,
    ["ice-platform"] = true
}
]]
