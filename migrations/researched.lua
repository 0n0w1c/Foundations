require("constants")

for index, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes

    for _, color in pairs(COLORS) do
        if recipes[color.name.."-refined-concrete"] and technologies["concrete"] then
            recipes[color.name.."-refined-concrete"].enabled = technologies["concrete"].researched
        end
    end

end
