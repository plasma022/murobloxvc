--[[
    ItemData.lua (Versión Final y Completa)
    Base de datos de ítems expandida con 5 armas y 5 sets para cada clase.
]]
local ItemData = {
	DarkWizard = {
		Weapons = {
			{ Name = "Skull Staff", Type = "Staff", MinDmg = 28, MaxDmg = 42, AttackSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 40, Agility = 20 }, ReqClass = "DarkWizard" },
			{ Name = "Serpent Staff", Type = "Staff", MinDmg = 36, MaxDmg = 52, AttackSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 60, Agility = 25 }, ReqClass = "DarkWizard" },
			{ Name = "Legendary Staff", Type = "Staff", MinDmg = 45, MaxDmg = 60, AttackSpeed = 6, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 80, Agility = 30 }, ReqClass = "DarkWizard" },
			{ Name = "Staff of Destruction", Type = "Staff", MinDmg = 58, MaxDmg = 75, AttackSpeed = 6, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 110, Agility = 35 }, ReqClass = "DarkWizard" },
			{ Name = "Platina Staff", Type = "Staff", MinDmg = 70, MaxDmg = 90, AttackSpeed = 7, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 140, Agility = 40 }, ReqClass = "DarkWizard" },
		},
		Sets = {
			Pad = {
				Helmet = { Name = "Pad Helmet", Type = "Casco", Defense = 10, ImageId = "rbxassetid://90412853917216", ReqStats = { Energy = 20, Agility = 10 }, ReqClass = "DarkWizard" },
				Armor = { Name = "Pad Armor", Type = "Pecho", Defense = 15, ImageId = "rbxassetid://72001732663752", ReqStats = { Energy = 20, Agility = 10 }, ReqClass = "DarkWizard" },
				Pants = { Name = "Pad Pants", Type = "Pantalones", Defense = 12, ImageId = "rbxassetid://117997610277464", ReqStats = { Energy = 20, Agility = 10 }, ReqClass = "DarkWizard" },
				Gloves = { Name = "Pad Gloves", Type = "Guantes", Defense = 8, AttackSpeed = 1, ImageId = "rbxassetid://99466614742015", ReqStats = { Energy = 20, Agility = 10 }, ReqClass = "DarkWizard" },
				Boots = { Name = "Pad Boots", Type = "Botas", Defense = 9, MovementSpeed = 2, ImageId = "rbxassetid://109571555814663", ReqStats = { Energy = 20, Agility = 10 }, ReqClass = "DarkWizard" },
			},
			Bone = {
				Helmet = { Name = "Bone Helmet", Type = "Casco", Defense = 20, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 40, Agility = 20 }, ReqClass = "DarkWizard" },
				Armor = { Name = "Bone Armor", Type = "Pecho", Defense = 25, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 40, Agility = 20 }, ReqClass = "DarkWizard" },
				Pants = { Name = "Bone Pants", Type = "Pantalones", Defense = 22, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 40, Agility = 20 }, ReqClass = "DarkWizard" },
				Gloves = { Name = "Bone Gloves", Type = "Guantes", Defense = 15, AttackSpeed = 2, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 40, Agility = 20 }, ReqClass = "DarkWizard" },
				Boots = { Name = "Bone Boots", Type = "Botas", Defense = 18, MovementSpeed = 3, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 40, Agility = 20 }, ReqClass = "DarkWizard" },
			},
			Legendary = {
				Helmet = { Name = "Legendary Helmet", Type = "Casco", Defense = 35, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 70, Agility = 30 }, ReqClass = "DarkWizard" },
				Armor = { Name = "Legendary Armor", Type = "Pecho", Defense = 42, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 70, Agility = 30 }, ReqClass = "DarkWizard" },
				Pants = { Name = "Legendary Pants", Type = "Pantalones", Defense = 38, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 70, Agility = 30 }, ReqClass = "DarkWizard" },
				Gloves = { Name = "Legendary Gloves", Type = "Guantes", Defense = 28, AttackSpeed = 3, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 70, Agility = 30 }, ReqClass = "DarkWizard" },
				Boots = { Name = "Legendary Boots", Type = "Botas", Defense = 30, MovementSpeed = 4, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 70, Agility = 30 }, ReqClass = "DarkWizard" },
			},
			GrandSoul = {
				Helmet = { Name = "Grand Soul Helmet", Type = "Casco", Defense = 50, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 100, Agility = 40 }, ReqClass = "DarkWizard" },
				Armor = { Name = "Grand Soul Armor", Type = "Pecho", Defense = 60, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 100, Agility = 40 }, ReqClass = "DarkWizard" },
				Pants = { Name = "Grand Soul Pants", Type = "Pantalones", Defense = 55, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 100, Agility = 40 }, ReqClass = "DarkWizard" },
				Gloves = { Name = "Grand Soul Gloves", Type = "Guantes", Defense = 40, AttackSpeed = 4, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 100, Agility = 40 }, ReqClass = "DarkWizard" },
				Boots = { Name = "Grand Soul Boots", Type = "Botas", Defense = 45, MovementSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 100, Agility = 40 }, ReqClass = "DarkWizard" },
			},
			DarkSoul = {
				Helmet = { Name = "Dark Soul Helmet", Type = "Casco", Defense = 70, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 130, Agility = 50 }, ReqClass = "DarkWizard" },
				Armor = { Name = "Dark Soul Armor", Type = "Pecho", Defense = 85, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 130, Agility = 50 }, ReqClass = "DarkWizard" },
				Pants = { Name = "Dark Soul Pants", Type = "Pantalones", Defense = 77, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 130, Agility = 50 }, ReqClass = "DarkWizard" },
				Gloves = { Name = "Dark Soul Gloves", Type = "Guantes", Defense = 60, AttackSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 130, Agility = 50 }, ReqClass = "DarkWizard" },
				Boots = { Name = "Dark Soul Boots", Type = "Botas", Defense = 65, MovementSpeed = 6, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Energy = 130, Agility = 50 }, ReqClass = "DarkWizard" },
			},
		}
	},
	DarkKnight = {
		Weapons = {
			{ Name = "Short Sword", Type = "Sword", MinDmg = 12, MaxDmg = 18, AttackSpeed = 7, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 30, Agility = 15 }, ReqClass = "DarkKnight" },
			{ Name = "Blade", Type = "Sword", MinDmg = 25, MaxDmg = 35, AttackSpeed = 8, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 50, Agility = 20 }, ReqClass = "DarkKnight" },
			{ Name = "Lightning Sword", Type = "Sword", MinDmg = 38, MaxDmg = 48, AttackSpeed = 8, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 70, Agility = 25 }, ReqClass = "DarkKnight" },
			{ Name = "Sword of Destruction", Type = "Sword", MinDmg = 50, MaxDmg = 65, AttackSpeed = 9, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 90, Agility = 30 }, ReqClass = "DarkKnight" },
			{ Name = "Daybreak", Type = "Sword", MinDmg = 65, MaxDmg = 80, AttackSpeed = 9, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 120, Agility = 35 }, ReqClass = "DarkKnight" },
		},
		Sets = {
			Leather = {
				Helmet = { Name = "Leather Helmet", Type = "Casco", Defense = 15, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 20, Agility = 10 }, ReqClass = "DarkKnight" },
				Armor = { Name = "Leather Armor", Type = "Pecho", Defense = 20, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 20, Agility = 10 }, ReqClass = "DarkKnight" },
				Pants = { Name = "Leather Pants", Type = "Pantalones", Defense = 17, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 20, Agility = 10 }, ReqClass = "DarkKnight" },
				Gloves = { Name = "Leather Gloves", Type = "Guantes", Defense = 10, AttackSpeed = 1, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 20, Agility = 10 }, ReqClass = "DarkKnight" },
				Boots = { Name = "Leather Boots", Type = "Botas", Defense = 12, MovementSpeed = 2, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 20, Agility = 10 }, ReqClass = "DarkKnight" },
			},
			Scale = {
				Helmet = { Name = "Scale Helmet", Type = "Casco", Defense = 25, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 40, Agility = 20 }, ReqClass = "DarkKnight" },
				Armor = { Name = "Scale Armor", Type = "Pecho", Defense = 32, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 40, Agility = 20 }, ReqClass = "DarkKnight" },
				Pants = { Name = "Scale Pants", Type = "Pantalones", Defense = 28, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 40, Agility = 20 }, ReqClass = "DarkKnight" },
				Gloves = { Name = "Scale Gloves", Type = "Guantes", Defense = 18, AttackSpeed = 2, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 40, Agility = 20 }, ReqClass = "DarkKnight" },
				Boots = { Name = "Scale Boots", Type = "Botas", Defense = 20, MovementSpeed = 3, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 40, Agility = 20 }, ReqClass = "DarkKnight" },
			},
			Dragon = {
				Helmet = { Name = "Dragon Helmet", Type = "Casco", Defense = 40, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 80, Agility = 35 }, ReqClass = "DarkKnight" },
				Armor = { Name = "Dragon Armor", Type = "Pecho", Defense = 50, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 80, Agility = 35 }, ReqClass = "DarkKnight" },
				Pants = { Name = "Dragon Pants", Type = "Pantalones", Defense = 44, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 80, Agility = 35 }, ReqClass = "DarkKnight" },
				Gloves = { Name = "Dragon Gloves", Type = "Guantes", Defense = 30, AttackSpeed = 3, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 80, Agility = 35 }, ReqClass = "DarkKnight" },
				Boots = { Name = "Dragon Boots", Type = "Botas", Defense = 34, MovementSpeed = 4, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 80, Agility = 35 }, ReqClass = "DarkKnight" },
			},
			BlackDragon = {
				Helmet = { Name = "Black Dragon Helmet", Type = "Casco", Defense = 55, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 110, Agility = 45 }, ReqClass = "DarkKnight" },
				Armor = { Name = "Black Dragon Armor", Type = "Pecho", Defense = 68, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 110, Agility = 45 }, ReqClass = "DarkKnight" },
				Pants = { Name = "Black Dragon Pants", Type = "Pantalones", Defense = 60, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 110, Agility = 45 }, ReqClass = "DarkKnight" },
				Gloves = { Name = "Black Dragon Gloves", Type = "Guantes", Defense = 45, AttackSpeed = 4, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 110, Agility = 45 }, ReqClass = "DarkKnight" },
				Boots = { Name = "Black Dragon Boots", Type = "Botas", Defense = 50, MovementSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 110, Agility = 45 }, ReqClass = "DarkKnight" },
			},
			GreatDragon = {
				Helmet = { Name = "Great Dragon Helmet", Type = "Casco", Defense = 75, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 140, Agility = 55 }, ReqClass = "DarkKnight" },
				Armor = { Name = "Great Dragon Armor", Type = "Pecho", Defense = 90, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 140, Agility = 55 }, ReqClass = "DarkKnight" },
				Pants = { Name = "Great Dragon Pants", Type = "Pantalones", Defense = 82, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 140, Agility = 55 }, ReqClass = "DarkKnight" },
				Gloves = { Name = "Great Dragon Gloves", Type = "Guantes", Defense = 65, AttackSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 140, Agility = 55 }, ReqClass = "DarkKnight" },
				Boots = { Name = "Great Dragon Boots", Type = "Botas", Defense = 70, MovementSpeed = 6, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Strength = 140, Agility = 55 }, ReqClass = "DarkKnight" },
			},
		}
	},
	FairyElf = {
		Weapons = {
			{ Name = "Short Bow", Type = "Bow", MinDmg = 20, MaxDmg = 28, AttackSpeed = 10, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 35, Strength = 20 }, ReqClass = "FairyElf"
			},
			{ Name = "Battle Bow", Type = "Bow", MinDmg = 30, MaxDmg = 40, AttackSpeed = 10, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 50, Strength = 25 }, ReqClass = "FairyElf"
			},
			{ Name = "Silver Bow", Type = "Bow", MinDmg = 42, MaxDmg = 55, AttackSpeed = 12, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 70, Strength = 30 }, ReqClass = "FairyElf"
			},
			{ Name = "Celestial Bow", Type = "Bow", MinDmg = 55, MaxDmg = 70, AttackSpeed = 12, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 90, Strength = 35 }, ReqClass = "FairyElf"
			},
			{ Name = "Albatross Bow", Type = "Bow", MinDmg = 70, MaxDmg = 85, AttackSpeed = 14, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 120, Strength = 40 }, ReqClass = "FairyElf"
			},
		},
		Sets = {
			Vine = {
				Helmet = { Name = "Vine Helmet", Type = "Casco", Defense = 12, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 25, Strength = 15 }, ReqClass = "FairyElf"
				},
				Armor = { Name = "Vine Armor", Type = "Pecho", Defense = 17, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 25, Strength = 15 }, ReqClass = "FairyElf"
				},
				Pants = { Name = "Vine Pants", Type = "Pantalones", Defense = 14, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 25, Strength = 15 }, ReqClass = "FairyElf"
				},
				Gloves = { Name = "Vine Gloves", Type = "Guantes", Defense = 10, AttackSpeed = 3, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 25, Strength = 15 }, ReqClass = "FairyElf"
				},
				Boots = { Name = "Vine Boots", Type = "Botas", Defense = 11, MovementSpeed = 4, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 25, Strength = 15 }, ReqClass = "FairyElf"
				},
			},
			Wind = {
				Helmet = { Name = "Wind Helmet", Type = "Casco", Defense = 22, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 45, Strength = 20 }, ReqClass = "FairyElf"
				},
				Armor = { Name = "Wind Armor", Type = "Pecho", Defense = 28, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 45, Strength = 20 }, ReqClass = "FairyElf"
				},
				Pants = { Name = "Wind Pants", Type = "Pantalones", Defense = 24, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 45, Strength = 20 }, ReqClass = "FairyElf"
				},
				Gloves = { Name = "Wind Gloves", Type = "Guantes", Defense = 16, AttackSpeed = 4, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 45, Strength = 20 }, ReqClass = "FairyElf"
				},
				Boots = { Name = "Wind Boots", Type = "Botas", Defense = 19, MovementSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 45, Strength = 20 }, ReqClass = "FairyElf"
				},
			},
			Guardian = {
				Helmet = { Name = "Guardian Helmet", Type = "Casco", Defense = 34, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 75, Strength = 30 }, ReqClass = "FairyElf"
				},
				Armor = { Name = "Guardian Armor", Type = "Pecho", Defense = 40, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 75, Strength = 30 }, ReqClass = "FairyElf"
				},
				Pants = { Name = "Guardian Pants", Type = "Pantalones", Defense = 36, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 75, Strength = 30 }, ReqClass = "FairyElf"
				},
				Gloves = { Name = "Guardian Gloves", Type = "Guantes", Defense = 25, AttackSpeed = 5, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 75, Strength = 30 }, ReqClass = "FairyElf"
				},
				Boots = { Name = "Guardian Boots", Type = "Botas", Defense = 28, MovementSpeed = 6, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 75, Strength = 30 }, ReqClass = "FairyElf"
				},
			},
			Divine = {
				Helmet = { Name = "Divine Helmet", Type = "Casco", Defense = 48, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 105, Strength = 40 }, ReqClass = "FairyElf"
				},
				Armor = { Name = "Divine Armor", Type = "Pecho", Defense = 55, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 105, Strength = 40 }, ReqClass = "FairyElf"
				},
				Pants = { Name = "Divine Pants", Type = "Pantalones", Defense = 50, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 105, Strength = 40 }, ReqClass = "FairyElf"
				},
				Gloves = { Name = "Divine Gloves", Type = "Guantes", Defense = 38, AttackSpeed = 6, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 105, Strength = 40 }, ReqClass = "FairyElf"
				},
				Boots = { Name = "Divine Boots", Type = "Botas", Defense = 42, MovementSpeed = 7, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 105, Strength = 40 }, ReqClass = "FairyElf"
				},
			},
			RedSpirit = {
				Helmet = { Name = "Red Spirit Helmet", Type = "Casco", Defense = 65, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 135, Strength = 50 }, ReqClass = "FairyElf"
				},
				Armor = { Name = "Red Spirit Armor", Type = "Pecho", Defense = 75, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 135, Strength = 50 }, ReqClass = "FairyElf"
				},
				Pants = { Name = "Red Spirit Pants", Type = "Pantalones", Defense = 68, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 135, Strength = 50 }, ReqClass = "FairyElf"
				},
				Gloves = { Name = "Red Spirit Gloves", Type = "Guantes", Defense = 55, AttackSpeed = 7, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 135, Strength = 50 }, ReqClass = "FairyElf"
				},
				Boots = { Name = "Red Spirit Boots", Type = "Botas", Defense = 60, MovementSpeed = 8, ImageId = "rbxassetid://PASTE_YOUR_ID_HERE", ReqStats = { Agility = 135, Strength = 50 }, ReqClass = "FairyElf"
				},
			},
		}
	}
}

return ItemData
