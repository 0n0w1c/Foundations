require("constants")

local compatibility = {}

function compatibility.base()
    -- add disabled, at positon 1
    add_to_global_tile_names(DISABLED, DISABLED)
    add_to_global_tile_to_item(DISABLED, DISABLED)

    if settings.global["Foundations-stone-path"].value then
        add_to_global_tile_names("stone-path", "stone-brick")
    end
    add_to_global_tile_to_item("stone-path", "stone-brick")

    if settings.global["Foundations-concrete"].value then
        add_to_global_tile_names("concrete", "concrete")
    end
    add_to_global_tile_to_item("concrete", "concrete")

    if settings.global["Foundations-refined-concrete"].value then
        add_to_global_tile_names("refined-concrete", "refined-concrete")
    end
    add_to_global_tile_to_item("refined-concrete", "refined-concrete")

    if settings.global["Foundations-hazard-concrete"].value then
        add_to_global_tile_names("hazard-concrete-left", "hazard-concrete")
        add_to_global_tile_names("hazard-concrete-right", "hazard-concrete")
    end
    add_to_global_tile_to_item("hazard-concrete-left", "hazard-concrete")
    add_to_global_tile_to_item("hazard-concrete-right", "hazard-concrete")

    if settings.global["Foundations-refined-hazard-concrete"].value then
        add_to_global_tile_names("refined-hazard-concrete-left", "refined-hazard-concrete")
        add_to_global_tile_names("refined-hazard-concrete-right", "refined-hazard-concrete")
    end
    add_to_global_tile_to_item("refined-hazard-concrete-left", "refined-hazard-concrete")
    add_to_global_tile_to_item("refined-hazard-concrete-right", "refined-hazard-concrete")
end

function compatibility.rough_stone_path()
    if script.active_mods["stone-path"] or (script.active_mods["aai-industry"] and settings.startup["aai-stone-path"].value) then
        if settings.global["Foundations-rough-stone-path"].value then
            add_to_global_tile_names("rough-stone-path", "stone")
        end
        add_to_global_tile_to_item("rough-stone-path", "stone")
    end
end

function compatibility.concrete_variants()
    for _, color in pairs(COLORS) do
        if settings.global["Foundations-" .. color.name .. "-refined-concrete"].value then
            add_to_global_tile_names(color.name .. "-refined-concrete", color.name .. "-refined-concrete")
        end
        add_to_global_tile_to_item(color.name .. "-refined-concrete", color.name .. "-refined-concrete")
    end
end

return compatibility
