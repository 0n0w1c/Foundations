require("constants")

local compatibility = {}

function compatibility.vanilla()
    for _, color in pairs(COLORS) do
        if settings.global["Foundations-"..color.name.."-refined-concrete"].value then
            add_to_global_tables(color.name.."-refined-concrete", color.name.."-refined-concrete")
        end
    end
end

function compatibility.aai_industry()
    if settings.startup["aai-stone-path"].value and settings.global["Foundations-rough-stone-path"].value then
        add_to_global_tables("rough-stone-path", "stone")
    end
    if settings.global["Foundations-exclude-small-medium-electric-poles"].value then
        global.excluded_name_list["small-iron-electric-pole"] = true
    end
end

function compatibility.dectorio()
    if settings.startup["dectorio-wood"].value and settings.global["Foundations-dect-wood-floor"].value then
        add_to_global_tables("dect-wood-floor", "dect-wood-floor")
    end
    if settings.startup["dectorio-concrete"].value and settings.global["Foundations-dect-concrete-grid"].value then
        add_to_global_tables("dect-concrete-grid", "dect-concrete-grid")
    end
    if settings.startup["dectorio-gravel"].value then
        for _, gravel in pairs(GRAVELS) do
            if settings.global["Foundations-dect-"..gravel.."-gravel"].value then
                add_to_global_tables("dect-"..gravel.."-gravel", "dect-"..gravel.."-gravel")
            end
        end
    end
    if settings.startup["dectorio-painted-concrete"].value then
        for _, variant in pairs(PAINTED_CONCRETE) do
            if settings.global["Foundations-dect-paint-"..variant].value then
                add_to_global_tables("dect-paint-"..variant.."-left", "dect-paint-"..variant)
                add_to_global_tables("dect-paint-"..variant.."-right", "dect-paint-"..variant)
            end
            if settings.global["Foundations-dect-paint-refined-"..variant].value then
                add_to_global_tables("dect-paint-refined-"..variant.."-left", "dect-paint-refined-"..variant)
                add_to_global_tables("dect-paint-refined-"..variant.."-right", "dect-paint-refined-"..variant)
            end
        end
        for _, color in pairs(COLORS) do
            if settings.global["Foundations-"..color.name.."-refined-concrete"].value then
                add_to_global_tables(color.name.."-refined-concrete", "dect-"..color.name.."-refined-concrete")
            end
        end
    end
end

function compatibility.krastorio2()
    if settings.global["Foundations-kr-black-reinforced-plate"].value then
        add_to_global_tables("kr-black-reinforced-plate", "kr-black-reinforced-plate")
    end
    if settings.global["Foundations-kr-white-reinforced-plate"].value then
        add_to_global_tables("kr-white-reinforced-plate", "kr-white-reinforced-plate")
    end
end

return compatibility
