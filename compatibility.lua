require("constants")

local compatibility = {}

function compatibility.rough_stone_path()
    if settings.global["Foundations-rough-stone-path"].value then
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

function compatibility.aai_industry()
    if settings.startup["aai-stone-path"].value and settings.global["Foundations-rough-stone-path"].value then
        add_to_global_tile_names("rough-stone-path", "stone")
    end
    add_to_global_tile_to_item("rough-stone-path", "stone")
end

function compatibility.dectorio()
    if settings.startup["dectorio-wood"].value and settings.global["Foundations-dect-wood-floor"].value then
        add_to_global_tile_names("dect-wood-floor", "dect-wood-floor")
    end
    add_to_global_tile_to_item("dect-wood-floor", "dect-wood-floor")

    if settings.startup["dectorio-concrete"].value and settings.global["Foundations-dect-concrete-grid"].value then
        add_to_global_tile_names("dect-concrete-grid", "dect-concrete-grid")
    end
    add_to_global_tile_to_item("dect-concrete-grid", "dect-concrete-grid")

    if settings.startup["dectorio-gravel"].value then
        for _, gravel in pairs(GRAVELS) do
            if settings.global["Foundations-dect-" .. gravel .. "-gravel"].value then
                add_to_global_tile_names("dect-" .. gravel .. "-gravel", "dect-" .. gravel .. "-gravel")
            end
            add_to_global_tile_to_item("dect-" .. gravel .. "-gravel", "dect-" .. gravel .. "-gravel")
        end
    end

    if settings.startup["dectorio-painted-concrete"].value then
        for _, variant in pairs(PAINTED_CONCRETE) do
            if settings.global["Foundations-dect-paint-" .. variant].value then
                add_to_global_tile_names("dect-paint-" .. variant .. "-left", "dect-paint-" .. variant)
                add_to_global_tile_names("dect-paint-" .. variant .. "-right", "dect-paint-" .. variant)
            end
            add_to_global_tile_to_item("dect-paint-" .. variant .. "-left", "dect-paint-" .. variant)
            add_to_global_tile_to_item("dect-paint-" .. variant .. "-right", "dect-paint-" .. variant)

            if settings.global["Foundations-dect-paint-refined-" .. variant].value then
                add_to_global_tile_names("dect-paint-refined-" .. variant .. "-left", "dect-paint-refined-" .. variant)
                add_to_global_tile_names("dect-paint-refined-" .. variant .. "-right", "dect-paint-refined-" .. variant)
            end
            add_to_global_tile_to_item("dect-paint-refined-" .. variant .. "-left", "dect-paint-refined-" .. variant)
            add_to_global_tile_to_item("dect-paint-refined-" .. variant .. "-right", "dect-paint-refined-" .. variant)
        end
        for _, color in pairs(COLORS) do
            if settings.global["Foundations-" .. color.name .. "-refined-concrete"].value then
                add_to_global_tile_names(color.name .. "-refined-concrete", "dect-" .. color.name .. "-refined-concrete")
            end
            add_to_global_tile_to_item(color.name .. "-refined-concrete", "dect-" .. color.name .. "-refined-concrete")
        end
    end
end

function compatibility.industrialrevolution3()
    if settings.global["Foundations-tarmac"].value then
        add_to_global_tile_names("tarmac", "tarmac")
    end
    add_to_global_tile_to_item("tarmac", "tarmac")
end

function compatibility.krastorio2()
    if settings.global["Foundations-kr-black-reinforced-plate"].value then
        add_to_global_tile_names("kr-black-reinforced-plate", "kr-black-reinforced-plate")
    end
    add_to_global_tile_to_item("kr-black-reinforced-plate", "kr-black-reinforced-plate")

    if settings.global["Foundations-kr-white-reinforced-plate"].value then
        add_to_global_tile_names("kr-white-reinforced-plate", "kr-white-reinforced-plate")
    end
    add_to_global_tile_to_item("kr-white-reinforced-plate", "kr-white-reinforced-plate")
end

return compatibility
