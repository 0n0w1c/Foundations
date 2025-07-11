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
    { name = "stone-path",                           default = 11 },
    { name = "frozen-stone-path",                    default = 12 },
    { name = "concrete",                             default = 13 },
    { name = "frozen-concrete",                      default = 14 },
    { name = "hazard-concrete-left",                 default = 15 },
    { name = "hazard-concrete-right",                default = 15 },
    { name = "frozen-hazard-concrete-left",          default = 16 },
    { name = "frozen-hazard-concrete-right",         default = 16 },
    { name = "refined-concrete",                     default = 17 },
    { name = "frozen-refined-concrete",              default = 18 },
    { name = "refined-hazard-concrete-left",         default = 19 },
    { name = "refined-hazard-concrete-right",        default = 19 },
    { name = "frozen-refined-hazard-concrete-left",  default = 20 },
    { name = "frozen-refined-hazard-concrete-right", default = 20 }
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

FOUNDATION_TILE_CONDITIONS =
{
    ["foundation"] = {
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
        ["lava-hot"] = true
    },

    ["landfill"] = {
        ["water"] = true,
        ["deepwater"] = true,
        ["water-green"] = true,
        ["deepwater-green"] = true,
        ["water-shallow"] = true,
        ["water-mud"] = true,
        ["wetland-light-green-slime"] = true,
        ["wetland-green-slime"] = true,
        ["wetland-light-dead-skin"] = true,
        ["wetland-dead-skin"] = true,
        ["wetland-pink-tentacle"] = true,
        ["wetland-red-tentacle"] = true,
        ["wetland-yumako"] = true,
        ["wetland-jellynut"] = true,
        ["wetland-blue-slime"] = true,
        ["gleba-deep-lake"] = true
    },

    ["ice-platform"] =
    {
        ["ammoniacal-ocean"] = true,
        ["ammoniacal-ocean-2"] = true,
        ["brash-ice"] = true
    },

    ["artificial-yumako-soil"] =
    {
        ["wetland-yumako"] = true
    },

    ["overgrowth-yumako-soil"] =
    {
        ["wetland-light-green-slime"] = true,
        ["wetland-green-slime"] = true,
        ["wetland-yumako"] = true,
        ["lowland-olive-blubber"] = true,
        ["lowland-olive-blubber-2"] = true,
        ["lowland-olive-blubber-3"] = true,
        ["lowland-brown-blubber"] = true,
        ["lowland-pale-green"] = true
    },

    ["artificial-jellynut-soil"] =
    {
        ["wetland-jellynut"] = true
    },

    ["overgrowth-jellynut-soil"] =
    {
        ["wetland-pink-tentacle"] = true,
        ["wetland-red-tentacle"] = true,
        ["wetland-jellynut"] = true,
        ["lowland-red-vein"] = true,
        ["lowland-red-vein-2"] = true,
        ["lowland-red-vein-3"] = true,
        ["lowland-red-vein-4"] = true,
        ["lowland-red-vein-dead"] = true,
        ["lowland-red-infection"] = true,
        ["lowland-cream-red"] = true
    },

    ["F077ET-space-platform-for-ground"] =
    {
        ["grass-1"] = true,
        ["grass-2"] = true,
        ["grass-3"] = true,
        ["grass-4"] = true,
        ["dry-dirt"] = true,
        ["dirt-1"] = true,
        ["dirt-2"] = true,
        ["dirt-3"] = true,
        ["dirt-4"] = true,
        ["dirt-5"] = true,
        ["dirt-6"] = true,
        ["dirt-7"] = true,
        ["sand-1"] = true,
        ["sand-2"] = true,
        ["sand-3"] = true,
        ["red-desert-0"] = true,
        ["red-desert-1"] = true,
        ["red-desert-2"] = true,
        ["red-desert-3"] = true,
        ["volcanic-soil-dark"] = true,
        ["volcanic-soil-light"] = true,
        ["volcanic-ash-soil"] = true,
        ["volcanic-ash-flats"] = true,
        ["volcanic-ash-light"] = true,
        ["volcanic-ash-dark"] = true,
        ["volcanic-cracks"] = true,
        ["volcanic-cracks-warm"] = true,
        ["volcanic-folds"] = true,
        ["volcanic-folds-flat"] = true,
        ["volcanic-folds-warm"] = true,
        ["volcanic-pumice-stones"] = true,
        ["volcanic-cracks-hot"] = true,
        ["volcanic-jagged-ground"] = true,
        ["volcanic-smooth-stone"] = true,
        ["volcanic-smooth-stone-warm"] = true,
        ["volcanic-ash-cracks"] = true,
        ["natural-yumako-soil"] = true,
        ["natural-jellynut-soil"] = true,
        ["lowland-brown-blubber"] = true,
        ["lowland-olive-blubber"] = true,
        ["lowland-olive-blubber-2"] = true,
        ["lowland-olive-blubber-3"] = true,
        ["lowland-pale-green"] = true,
        ["lowland-cream-cauliflower"] = true,
        ["lowland-cream-cauliflower-2"] = true,
        ["lowland-dead-skin"] = true,
        ["lowland-dead-skin-2"] = true,
        ["lowland-cream-red"] = true,
        ["lowland-red-vein"] = true,
        ["lowland-red-vein-2"] = true,
        ["lowland-red-vein-3"] = true,
        ["lowland-red-vein-4"] = true,
        ["lowland-red-vein-dead"] = true,
        ["lowland-red-infection"] = true,
        ["midland-turquoise-bark"] = true,
        ["midland-turquoise-bark-2"] = true,
        ["midland-cracked-lichen"] = true,
        ["midland-cracked-lichen-dull"] = true,
        ["midland-cracked-lichen-dark"] = true,
        ["midland-yellow-crust"] = true,
        ["midland-yellow-crust-2"] = true,
        ["midland-yellow-crust-3"] = true,
        ["midland-yellow-crust-4"] = true,
        ["highland-dark-rock"] = true,
        ["highland-dark-rock-2"] = true,
        ["highland-yellow-rock"] = true,
        ["pit-rock"] = true,
        ["snow-flat"] = true,
        ["snow-crests"] = true,
        ["snow-lumpy"] = true,
        ["snow-patchy"] = true,
        ["ice-rough"] = true,
        ["ice-smooth"] = true,
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
        ["brash-ice"] = true
    }
}
