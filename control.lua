script.on_event(defines.events.on_player_created,
function(event)
	local player = game.players[event.player_index]
	local character = player.cutscene_character

	-- If cutscene character is null, try regular character
	if character == nil then
		character = player.character
	end

	-- If still no character, then in Sandbox mode
	if character == nil then
		player.print("You are in Sandbox mode, no soup for you!")
		return
	end

	local inventory = character.get_main_inventory()

	if settings.startup["Foundations-required-stone-furnace"].value then
		local give_stone_brick = true
		for name, version in pairs(game.active_mods) do
			if name == "aai-industry" or name == "IndustrialRevolution3" then
				give_stone_brick = false
			end
		end
		if give_stone_brick then
		    inventory.insert{name="stone-brick", count = 4}
		end
	end
end)
