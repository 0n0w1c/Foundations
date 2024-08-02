local compatibility = {}

function compatibility.aai_industry()
    if settings.startup["aai-stone-path"].value and settings.global["Foundations-rough-stone-path"].value then
        add_to_global_tables("rough-stone-path", "stone")
    end
    if settings.global["Foundations-exclude-small-medium-electric-poles"].value then
        global.exclusion_name_list["small-iron-electric-pole"] = true
    end
end

function compatibility.dectorio()
    if settings.startup["dectorio-wood"].value and settings.global["Foundations-dect-wood-floor"].value then
        add_to_global_tables("dect-wood-floor", "dect-wood-floor")
    end
    if settings.startup["dectorio-concrete"].value and settings.global["Foundations-dect-concrete-grid"].value then
        add_to_global_tables("dect-concrete-grid", "dect-concrete-grid")
    end
    if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-coal-gravel"].value then
        add_to_global_tables("dect-coal-gravel", "dect-coal-gravel")
    end
    if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-copper-ore-gravel"].value then
        add_to_global_tables("dect-copper-ore-gravel", "dect-copper-ore-gravel")
    end
    if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-iron-ore-gravel"].value then
        add_to_global_tables("dect-iron-ore-gravel", "dect-iron-ore-gravel")
    end
    if settings.startup["dectorio-gravel"].value and settings.global["Foundations-dect-stone-gravel"].value then
        add_to_global_tables("dect-stone-gravel", "dect-stone-gravel")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-danger"].value then
        add_to_global_tables("dect-paint-danger-left", "dect-paint-danger")
        add_to_global_tables("dect-paint-danger-right", "dect-paint-danger")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-emergency"].value then
        add_to_global_tables("dect-paint-emergency-left", "dect-paint-emergency")
        add_to_global_tables("dect-paint-emergency-right", "dect-paint-emergency")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-caution"].value then
        add_to_global_tables("dect-paint-caution-left", "dect-paint-caution")
        add_to_global_tables("dect-paint-caution-right", "dect-paint-caution")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-radiation"].value then
        add_to_global_tables("dect-paint-radiation-left", "dect-paint-radiation")
        add_to_global_tables("dect-paint-radiation-right", "dect-paint-radiation")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-defect"].value then
        add_to_global_tables("dect-paint-defect-left", "dect-paint-defect")
        add_to_global_tables("dect-paint-defect-right", "dect-paint-defect")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-operations"].value then
        add_to_global_tables("dect-paint-operations-left", "dect-paint-operations")
        add_to_global_tables("dect-paint-operations-right", "dect-paint-operations")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-safety"].value then
        add_to_global_tables("dect-paint-safety-left", "dect-paint-safety")
        add_to_global_tables("dect-paint-safety-right", "dect-paint-safety")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-danger"].value then
        add_to_global_tables("dect-paint-refined-danger-left", "dect-paint-refined-danger")
        add_to_global_tables("dect-paint-refined-danger-right", "dect-paint-refined-danger")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-emergency"].value then
        add_to_global_tables("dect-paint-refined-emergency-left", "dect-paint-refined-emergency")
        add_to_global_tables("dect-paint-refined-emergency-right", "dect-paint-refined-emergency")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-caution"].value then
        add_to_global_tables("dect-paint-refined-caution-left", "dect-paint-refined-caution")
        add_to_global_tables("dect-paint-refined-caution-right", "dect-paint-refined-caution")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-radiation"].value then
        add_to_global_tables("dect-paint-refined-radiation-left", "dect-paint-refined-radiation")
        add_to_global_tables("dect-paint-refined-radiation-right", "dect-paint-refined-radiation")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-defect"].value then
        add_to_global_tables("dect-paint-refined-defect-left", "dect-paint-refined-defect")
        add_to_global_tables("dect-paint-refined-defect-right", "dect-paint-refined-defect")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-operations"].value then
        add_to_global_tables("dect-paint-refined-operations-left", "dect-paint-refined-operations")
        add_to_global_tables("dect-paint-refined-operations-right", "dect-paint-refined-operations")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-dect-paint-refined-safety"].value then
        add_to_global_tables("dect-paint-refined-safety-left", "dect-paint-refined-safety")
        add_to_global_tables("dect-paint-refined-safety-right", "dect-paint-refined-safety")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-acid-refined-concrete"].value then
        add_to_global_tables("acid-refined-concrete", "dect-acid-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-black-refined-concrete"].value then
        add_to_global_tables("black-refined-concrete", "dect-black-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-blue-refined-concrete"].value then
        add_to_global_tables("blue-refined-concrete", "dect-blue-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-brown-refined-concrete"].value then
        add_to_global_tables("brown-refined-concrete", "dect-brown-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-cyan-refined-concrete"].value then
        add_to_global_tables("cyan-refined-concrete", "dect-cyan-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-green-refined-concrete"].value then
        add_to_global_tables("green-refined-concrete", "dect-green-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-orange-refined-concrete"].value then
        add_to_global_tables("orange-refined-concrete", "dect-orange-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-pink-refined-concrete"].value then
        add_to_global_tables("pink-refined-concrete", "dect-pink-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-purple-refined-concrete"].value then
        add_to_global_tables("purple-refined-concrete", "dect-purple-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-red-refined-concrete"].value then
        add_to_global_tables("red-refined-concrete", "dect-red-refined-concrete")
    end
    if settings.startup["dectorio-painted-concrete"].value and settings.global["Foundations-yellow-refined-concrete"].value then
        add_to_global_tables("yellow-refined-concrete", "dect-yellow-refined-concrete")
    end
end

function compatibility.krastorio2()
    if settings.global["Foundations-kr-black-reinforced-plate"].value then
        add_to_global_tables("kr-black-reinforced-plate", "kr-black-reinforced-plate")
    end
    if settings.global["Foundations-kr-white-reinforced-plate"].value then
        add_to_global_tables("kr-white-reinforced-plate", "kr-white-reinforced-plate")
    end
end

function compatibility.lunarlandings()
    if settings.global["Foundations-ll-lunar-foundation"].value then
        add_to_global_tables("ll-lunar-foundation", "ll-lunar-foundation")
    end
end

function compatibility.space_exploration()
    if settings.global["Foundations-se-space-platform-scaffold"].value then
        add_to_global_tables("se-space-platform-scaffold", "se-space-platform-scaffold")
    end
    if settings.global["Foundations-se-spaceship-floor"].value then
        add_to_global_tables("se-spaceship-floor", "se-spaceship-floor")
    end
end

return compatibility
