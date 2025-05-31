if not storage then return end

if storage.player_index and not storage.player_data then
    local old_foundation = storage.foundation or "disabled"
    local old_button_on = storage.button_on
    local old_excludes = storage.excludes or {
        inserters = true,
        belts = true,
        poles = true,
    }

    storage.player_data = {
        [1] = {
            foundation = old_foundation,
            button_on = old_button_on,
            excludes = old_excludes,
        }
    }

    storage.foundation = nil
    storage.button_on = nil
    storage.player_index = nil
    storage.excludes = nil
end
