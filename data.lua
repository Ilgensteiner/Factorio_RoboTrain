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
local roboport_wagon = deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
local requester_wagon = deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

-- Change the properties Roboport Waggon
roboport_wagon.type = "cargo-wagon"
roboport_wagon.name = "roboport-wagon-entity" -- Interner Name der Entität
roboport_wagon.icon = "__RoboTrain__/graphics/icons/roboport-wagon.png" -- Icon (für Karte, Zugübersicht etc.)
roboport_wagon.icon_size = 64
roboport_wagon.icon_mipmaps = 4
roboport_wagon.flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable"}
roboport_wagon.minable = {mining_time = 0.5, result = "roboport-wagon"} -- Was bekommt man beim Abbauen?
roboport_wagon.weight = 1200 -- Gewicht (Basis: 1000), vielleicht etwas schwerer wegen Roboport?
roboport_wagon.inventory_size = 20 -- Inventargröße (Basis: 40). Weniger Platz, da Raum für Roboport-Funktion benötigt wird? (Slots für Roboter, Reparaturkits)

-- Change the properties Requester Waggon
requester_wagon.type = "cargo-wagon"
requester_wagon.name = "requester-wagon-entity"
requester_wagon.icon = "__RoboTrain__/graphics/icons/requester-wagon.png"
requester_wagon.icon_size = 64
requester_wagon.icon_mipmaps = 4
requester_wagon.flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable"}
requester_wagon.minable = {mining_time = 0.5, result = "requester-wagon"} -- Was bekommt man beim Abbauen?

data:extend({roboport_wagon, requester_wagon})


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