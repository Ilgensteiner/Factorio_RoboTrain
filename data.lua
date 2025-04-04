-- data.lua for RoboTrain Mod

-- ### 1. Item Prototypen ###
-- Diese definieren die Items, die der Spieler im Inventar hat und zum Platzieren der Waggons verwendet.

data:extend({
    {
        type = "item",
        name = "roboport-wagon", -- Interner Name
        icon = "__RoboTrain__/graphics/icons/roboport-wagon.png", -- Platzhalter-Pfad zum Icon
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "train-transport", -- Wo es im Crafting-Menü erscheint (Logistik -> Zugtransport)
        order = "c[train-system]-d[roboport-wagon]", -- Sortierung innerhalb der Subgruppe
        place_result = "roboport-wagon-entity", -- Welche Entität wird platziert? (Siehe unten)
        stack_size = 5 -- Wieviele können gestapelt werden?
    },
    {
        type = "item",
        name = "requester-wagon", -- Interner Name
        icon = "__RoboTrain__/graphics/icons/requester-wagon.png", -- Platzhalter-Pfad zum Icon
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "train-transport",
        order = "c[train-system]-e[requester-wagon]",
        place_result = "requester-wagon-entity", -- Welche Entität wird platziert?
        stack_size = 5
    }
})

-- ### 2. Entity Prototypen ###
-- Diese definieren die eigentlichen Waggons, die auf den Schienen fahren.

-- Helper function to deep copy tables (necessary for inheriting complex structures like 'pictures')
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Get the base cargo wagon prototype to inherit from
local base_cargo_wagon = deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

data:extend({
    {
        type = "cargo-wagon",
        name = "roboport-wagon-entity", -- Interner Name der Entität
        icon = "__RoboTrain__/graphics/icons/roboport-wagon.png", -- Icon (für Karte, Zugübersicht etc.)
        collision_box = base_cargo_wagon.collision_box,
        icon_size = 64,
        icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable"},
        minable = {mining_time = 0.5, result = "roboport-wagon"}, -- Was bekommt man beim Abbauen?
        max_speed = base_cargo_wagon.max_speed,
        air_resistance = base_cargo_wagon.air_resistance,
        joint_distance = base_cargo_wagon.joint_distance,
        connection_distance = base_cargo_wagon.connection_distance,
        vertical_selection_shift = base_cargo_wagon.vertical_selection_shift,

        weight = 1200, -- Gewicht (Basis: 1000), vielleicht etwas schwerer wegen Roboport?
        braking_force = base_cargo_wagon.braking_force,
        friction_force = base_cargo_wagon.friction_force,
        energy_per_hit_point = base_cargo_wagon.energy_per_hit_point,

        inventory_size = 15, -- Inventargröße (Basis: 40). Weniger Platz, da Raum für Roboport-Funktion benötigt wird? (Slots für Roboter, Reparaturkits)
        -- WICHTIG: Wir erben die Grafiken und Sounds vom Basis-Waggon, bis wir eigene haben!
        pictures = base_cargo_wagon.pictures,
        horizontal_animation = base_cargo_wagon.horizontal_animation,
        vertical_animation = base_cargo_wagon.vertical_animation,
        horizontal_turret_animation = base_cargo_wagon.horizontal_turret_animation,
        vertical_turret_animation = base_cargo_wagon.vertical_turret_animation,
        turn_animation = base_cargo_wagon.turn_animation,
        sound_no_fuel = base_cargo_wagon.sound_no_fuel,
        working_sound = base_cargo_wagon.working_sound,
        -- Eigene Eigenschaften für die Logik in control.lua könnten hier hinzugefügt werden,
        -- aber im Moment verlassen wir uns auf den Namen zur Identifizierung.
        -- equipment_grid = "my-roboport-wagon-grid", -- Optional: Wenn man Ausrüstungsslots nutzen will (komplexer)
    },
    {
        type = "cargo-wagon",
        name = "requester-wagon-entity",
        icon = "__RoboTrain__/graphics/icons/requester-wagon.png",
        collision_box = base_cargo_wagon.collision_box,
        icon_size = 64,
        icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable"},
        minable = {mining_time = 0.5, result = "requester-wagon"},
        max_speed = base_cargo_wagon.max_speed,
        air_resistance = base_cargo_wagon.air_resistance,
        joint_distance = base_cargo_wagon.joint_distance,
        connection_distance = base_cargo_wagon.connection_distance,
        vertical_selection_shift = base_cargo_wagon.vertical_selection_shift,

        weight = 1000, -- Standardgewicht
        braking_force = base_cargo_wagon.braking_force,
        friction_force = base_cargo_wagon.friction_force,
        energy_per_hit_point = base_cargo_wagon.energy_per_hit_point,

        inventory_size = 40, -- Standard-Inventargröße für Güterwaggons
        -- WICHTIG: Wir erben die Grafiken und Sounds vom Basis-Waggon
        pictures = base_cargo_wagon.pictures,
        wheels = base_cargo_wagon.wheels,
        horizontal_animation = base_cargo_wagon.horizontal_animation,
        vertical_animation = base_cargo_wagon.vertical_animation,
        horizontal_turret_animation = base_cargo_wagon.horizontal_turret_animation,
        vertical_turret_animation = base_cargo_wagon.vertical_turret_animation,
        turn_animation = base_cargo_wagon.turn_animation,
        sound_no_fuel = base_cargo_wagon.sound_no_fuel,
        working_sound = base_cargo_wagon.working_sound,
    }
})


-- ### 3. Rezept Prototypen ###
-- Diese definieren, wie die Waggon-Items hergestellt werden.

data:extend({
    {
        type = "recipe",
        name = "roboport-wagon-recipe", -- Interner Name des Rezepts
        category = "crafting", -- Wo wird es hergestellt (Werkbank, Montagemaschine)
        enabled = false, -- Wird erst durch Technologie freigeschaltet
        energy_required = 15, -- Herstellungszeit (Sekunden)
        ingredients =
        {
            {type="item", name="cargo-wagon", amount=1},
            {type="item", name="roboport", amount=1},
            {type="item", name="advanced-circuit", amount=15},
            {type="item", name="steel-plate", amount=20}
        },
        results = {{type="item", name="roboport-wagon", amount=1}} -- Welches Item wird hergestellt?
    },
    {
        type = "recipe",
        name = "requester-wagon-recipe",
        category = "crafting",
        enabled = false,
        energy_required = 10,
        ingredients =
        {
            {type="item", name="cargo-wagon", amount=1},
            {type="item", name="buffer-chest", amount=1},
            {type="item", name="advanced-circuit", amount=5},
            {type="item", name="steel-plate", amount=10}
        },
        results = {{type="item", name="requester-wagon", amount=1}}
    }
})

-- ### 4. Technologie Prototyp ###
-- Definiert eine Technologie, um die Rezepte freizuschalten.

data:extend({
    {
        type = "technology",
        name = "robo-train-logistics", -- Interner Name der Technologie
        icon = "__RoboTrain__/graphics/technology/robo-train.png", -- Platzhalter Technologie-Icon
        icon_size = 256, -- Standardgröße für Tech-Icons
        icon_mipmaps = 4,
        effects = { -- Was wird freigeschaltet?
            {
                type = "unlock-recipe",
                recipe = "roboport-wagon-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "requester-wagon-recipe"
            }
        },
        prerequisites = {"automated-rail-transportation", "logistic-robotics"}, -- Voraussetzungen
        unit = { -- Forschungskosten
            count = 150, -- Anzahl Forschungseinheiten
            ingredients = { -- Benötigte Wissenschaftspakete
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 45 -- Zeit pro Einheit in Sekunden
        },
        order = "t-f-a" -- Ungefähre Position im Technologiebaum
    }
})

-- Ende der data.lua