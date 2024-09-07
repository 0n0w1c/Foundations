for _, tile in pairs(data.raw["tile"]) do
    if settings.startup["Foundations-mining-time"].value > 0 then
        if tile.minable then
            tile.minable.mining_time = settings.startup["Foundations-mining-time"].value
            tile.minable.hardness = nil
        end
    end

    if settings.startup["Foundations-clean-sweep"].value then
        tile.decorative_removal_probability = 1
    end
end
