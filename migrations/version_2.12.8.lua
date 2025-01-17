storage = storage or {}
if not storage then return end

storage.excludes = storage.excludes or {
    inserters = true,
    belts = true,
    poles = true,
}
