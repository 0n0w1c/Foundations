data:extend({
    {
        type = "sprite",
        name = "Foundations-disabled",
        filename = "__base__/graphics/icons/deconstruction-planner.png",
        width = 64,
        height = 64,
--        filename = "__core__/graphics/no-recipe.png",
--        width = 101,
--        height = 101,
        priority = "medium"
    }
})

data:extend({
    {
      type = "selection-tool",
      name = "foundations-fill-tool",
      icon = "__base__/graphics/icons/blueprint.png",
      icon_size = 64,
      flags = {},
      subgroup = "tool",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      alt_selection_color = { r = 0.7, g = 0.7, b = 0.7 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"any-tile"},
      selection_cursor_box_type = "entity",
      alt_selection_cursor_box_type = "entity",
    }
})
