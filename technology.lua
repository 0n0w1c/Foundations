require("constants")

local IR3 = mods["IndustrialRevolution3"]
local technology = data.raw.technology
if not technology then
    return
end

if not mods["Dectorio"] and settings.startup["Foundations-supply-concrete"].value then
    for _, color in pairs(COLORS) do
        if IR3 then
            table.insert(technology["ir-concrete-2"].effects, {type = "unlock-recipe", recipe = color.name.."-refined-concrete"})
        else
            table.insert(technology["concrete"].effects, {type = "unlock-recipe", recipe = color.name.."-refined-concrete"})
        end
    end
end
