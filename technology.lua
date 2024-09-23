require("constants")

local technology = data.raw.technology
if not technology then
    return
end

if not mods["Dectorio"] and settings.startup["Foundations-supply-concrete"].value then
    for _, color in pairs(COLORS) do
        if mods["IndustrialRevolution3"] then
            table.insert(technology["ir-concrete-2"].effects,
                { type = "unlock-recipe", recipe = color.name .. "-refined-concrete" })
        else
            table.insert(technology["concrete"].effects,
                { type = "unlock-recipe", recipe = color.name .. "-refined-concrete" })
        end
    end
end
