data:extend({ {
	type = "bool-setting",
	name = "Foundations-gun-turret-needs-foundation",
	setting_type = "startup",
	default_value = false,
	order = '1',
} })

if mods["IndustrialRevolution3"] then
	data:extend({ {
		type = "bool-setting",
		name = "Foundations-IR3-scattergun-turret-needs-foundation",
		setting_type = "startup",
		default_value = false,
		order = '2',
	} })
end
