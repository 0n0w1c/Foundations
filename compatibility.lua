require("constants")

local compatibility = {}

function compatibility.rough_stone_path()
    if settings.global["Foundations-rough-stone-path"].value then
        add_to_global_tile_names("rough-stone-path", "stone")
    end
    add_to_global_tile_to_item("rough-stone-path", "stone")
end

return compatibility
