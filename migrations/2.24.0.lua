local mod_gui = require("mod-gui")

for _, player in pairs(game.players) do
    local button_flow = mod_gui.get_button_flow(player)
    if button_flow and button_flow.valid then
        local old_button = button_flow["Foundations"]
        if old_button and old_button.valid then
            old_button.destroy()
        end
    end
end
