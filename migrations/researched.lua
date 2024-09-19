require("constants")

for _, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes
    local researched = false

    if technologies then
        if game.active_mods["IndustrialRevolution3"] then
            researched = technologies["ir-concrete-2"].researched
        else
            researched = technologies["concrete"].researched
        end
    end

    if recipes then
        for _, color in pairs(COLORS) do
            if recipes[color.name .. "-refined-concrete"] then
                recipes[color.name .. "-refined-concrete"].enabled = researched
            end
        end
    end
end
