-- set the mining_time for tiles
for _, tile in pairs(data.raw["tile"]) do
    if tile.minable then
        tile.minable.mining_time = settings.startup["Foundations-mining-time"].value
        tile.minable.hardness = nil
    end
end
