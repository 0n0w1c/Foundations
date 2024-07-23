local furnace_default = false

if mods["IndustrialRevolution3"] or mods["aai-industry"] then
    furnace_default = true
end

data:extend({
    {
        type = 'bool-setting',
        name = 'Foundations-required-stone-furnace',
        setting_type = 'startup',
        default_value = furnace_default,
        order = '1'
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "Foundations-required-electric-poles",
        setting_type = "startup",
        default_value = true,
        order = '2',
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "Foundations-required-gun-turret",
        setting_type = "startup",
        default_value = false,
        order = '3',
    }
})

if mods["IndustrialRevolution3"] then
    data:extend({
        {
            type = "bool-setting",
            name = "Foundations-required-IR3-scattergun-turret",
            setting_type = "startup",
            default_value = false,
            order = '4',
        }
    })
end
