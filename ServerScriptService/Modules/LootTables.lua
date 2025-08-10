-- Base de datos de lo que dropea cada monstruo
local LootTables = {
	["Zombie"] = {
		{ItemName = "Pad Helmet", Chance = 15}, -- 15% de probabilidad
		{ItemName = "Pad Gloves", Chance = 0},
		{ItemName = "Pad Pants", Chance = 100},
		{ItemName = "Pad Armor", Chance = 0},
		{ItemName = "Pad Boots", Chance = 0},
	}
}
return LootTables
