script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    local character = player.cutscene_character

    if not character and player.character then
        character = player.character
    else
        return
    end

    local inventory = character.get_main_inventory()

    if settings.startup["Foundations-required-stone-furnace"].value then
        local give_stone_brick = true
        for name, version in pairs(game.active_mods) do
            if name == "aai-industry" or name == "IndustrialRevolution3" then
                give_stone_brick = false
                break
            end
        end

        if give_stone_brick then
            inventory.insert{name="stone-brick", count = 4}
        end
    end
end)
