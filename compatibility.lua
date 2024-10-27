require("constants")

local compatibility = {}

function compatibility.rough_stone_path()
    if settings.global["Foundations-rough-stone-path"].value and settings.startup["aai-stone-path"].value then
        add_to_global_tile_names("rough-stone-path", "stone")
    end
    add_to_global_tile_to_item("rough-stone-path", "stone")
end

function compatibility.vanilla()
    for _, color in pairs(COLORS) do
        if settings.global["Foundations-" .. color.name .. "-refined-concrete"].value then
            add_to_global_tile_names(color.name .. "-refined-concrete", color.name .. "-refined-concrete")
        end
        add_to_global_tile_to_item(color.name .. "-refined-concrete", color.name .. "-refined-concrete")
    end
end

return compatibility
