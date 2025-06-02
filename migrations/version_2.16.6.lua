if not storage then return end

storage.player_data = storage.player_data or {}

if storage.foundation or storage.button_on ~= nil or storage.excludes then
    local old_foundation = storage.foundation or "Disabled"
    local old_button_on = storage.button_on ~= false
    local old_excludes = storage.excludes or
        {
            inserters = true,
            belts = true,
            poles = true,
        }

    for _, player in pairs(game.players) do
        local player_index = player.index
        if not storage.player_data[player_index] then
            storage.player_data[player_index] =
            {
                foundation = old_foundation,
                button_on = old_button_on,
                excludes = old_excludes,
            }
        end
    end

    storage.foundation = nil
    storage.button_on = nil
    storage.player_index = nil
    storage.excludes = nil
    storage.excluded_name_list = nil
    storage.excluded_type_list = nil
end
