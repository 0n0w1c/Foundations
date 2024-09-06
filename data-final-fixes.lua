for _, tile in pairs(data.raw["tile"]) do
    if tile.minable then
        tile.minable.mining_time = settings.startup["Foundations-mining-time"].value
        tile.minable.hardness = nil

        if settings.startup["Foundations-clean-sweep"].value then
            tile.decorative_removal_probability = 1
        end
    end

end
