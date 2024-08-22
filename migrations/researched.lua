require("constants")

for _, force in pairs(game.forces) do
    local recipes = force.recipes

    if recipes then
        for _, color in pairs(COLORS) do
            if recipes[color.name.."-refined-concrete"] and recipes["refined-concrete"] then
                recipes[color.name.."-refined-concrete"].enabled = recipes["refined-concrete"].enabled
            end
        end
    end
end
