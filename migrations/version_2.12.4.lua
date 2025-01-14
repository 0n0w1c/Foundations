require("constants")

storage = storage or {}
if not storage then return end

if storage.foundation then
    storage.foundation = DISABLED
end

if storage.tile_names_index then
    storage.tile_names_index = nil
end
