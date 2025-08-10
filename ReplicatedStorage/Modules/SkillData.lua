-- Módulo para almacenar los datos de todas las habilidades del juego (Versión Final)
local SkillData = {
	-- ==== Dark Knight ====
	["Cyclone"] = {
		Name = "Cyclone Sword", ClassName = "DarkKnight", ManaCost = 1, Cooldown = 1.5,
		SkillType = "SingleTargetMelee", Targeting = "Targeted", Range = 12,
		DamageMultiplier = 1.2, -- 120% del daño total
		ImageId = "rbxassetid://77329175261521" -- Pega tu ID de imagen aquí
	},
	["TwistingSlash"] = {
		Name = "Twisting Slash", ClassName = "DarkKnight", ManaCost = 1, Cooldown = 2,
		SkillType = "MeleeAoE", Range = 10, Targeting = "Self",
		DamageMultiplier = 1.1, -- 110% del daño total en área
		ImageId = "rbxassetid://93107442019349"
	},
	["DeathStab"] = {
		Name = "Death Stab", ClassName = "DarkKnight", ManaCost = 1, Cooldown = 3,
		SkillType = "SingleTargetMelee", Targeting = "Targeted", Range = 12,
		DamageMultiplier = 1.8, -- 180% del daño total
		ImageId = "rbxassetid://100074345540137"
	},
	["Inner"] = {
		Name = "Inner Strength", ClassName = "DarkKnight", ManaCost = 1, Cooldown = 45, 
		SkillType = "Buff", Targeting = "Self", Duration = 60,
		Effect = { Type = "MaxHP", BasePercent = 10, MaxPercent = 30, VitalityForMax = 1500 },
		ImageId = "rbxassetid://134425311950945"
	},

	-- ==== Dark Wizard ====
	["EnergyBall"] = {
		Name = "Energy Ball", ClassName = "DarkWizard", ManaCost = 3, Cooldown = 1, 
		SkillType = "Projectile", Targeting = "Targeted", Range = 40,
		DamageMultiplier = 1.1,
		ImageId = "rbxassetid://76727627021005"
	},
	["EvilSpirit"] = {
		Name = "Evil Spirit", ClassName = "DarkWizard", ManaCost = 12, Cooldown = 5, 
		SkillType = "ConeArea", Range = 40, TargetCount = 5, Targeting = "Self",
		DamageMultiplier = 0.9,
		ImageId = "rbxassetid://134787483687563"
	},
	["IceStorm"] = {
		Name = "Ice Storm", ClassName = "DarkWizard", ManaCost = 15, Cooldown = 6, 
		SkillType = "CircularArea", Range = 20, Targeting = "Targeted",
		DamageMultiplier = 1.4,
		Effect = { Type = "Slow", Chance = 20, Percent = 50, Duration = 3 },
		ImageId = "rbxassetid://125127345279202"
	},
	["ManaShield"] = {
		Name = "Mana Shield", ClassName = "DarkWizard", ManaCost = 20, Cooldown = 3, 
		SkillType = "Buff", Targeting = "Self", Duration = 60,
		Effect = { Type = "Absorption", BasePercent = 10, MaxPercent = 30, EnergyForMax = 2000 },
		ImageId = "rbxassetid://114905448282923"
	},

	-- ==== Fairy Elf ====
	["TripleShot"] = {
		Name = "Triple Shot", ClassName = "FairyElf", ManaCost = 5, Cooldown = 2,
		SkillType = "RangedCone", Range = 40, TargetCount = 3, Targeting = "Targeted",
		DamageMultiplier = 0.7, -- 70% del daño total por flecha
		ImageId = "rbxassetid://109905544767279"
	},
	["IceArrow"] = {
		Name = "Ice Arrow", ClassName = "FairyElf", ManaCost = 8, Cooldown = 8,
		SkillType = "SingleTargetRangedDebuff", Range = 50, Targeting = "Targeted",
		DamageMultiplier = 1.3,
		Effect = { Type = "Freeze", Chance = 25, Duration = 2 },
		ImageId = "rbxassetid://87924652960899"
	},
	["GreaterDamage"] = {
		Name = "Greater Damage", ClassName = "FairyElf", ManaCost = 12, Cooldown = 60,
		SkillType = "Buff", Targeting = "Self", Duration = 60,
		Effect = { Type = "Damage", BasePercent = 20, MaxPercent = 30, EnergyScale = 0.01 },
		ImageId = "rbxassetid://91498147913282"
	},
	["GreaterDefense"] = {
		Name = "Greater Defense", ClassName = "FairyElf", ManaCost = 12, Cooldown = 60,
		SkillType = "Buff", Targeting = "Self", Duration = 60,
		Effect = { Type = "Defense", BaseValue = 30, MaxValue = 50, EnergyScale = 0.02 },
		ImageId = "rbxassetid://139589261038283"
	}
}
return SkillData
