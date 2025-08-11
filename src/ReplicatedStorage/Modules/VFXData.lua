-- Módulo para definir los efectos visuales de cada habilidad (Versión Completa)
-- Ubicación: ReplicatedStorage/Modules/VFXData.lua

local VFXData = {
	-- ==== Dark Knight ====
	["Cyclone"] = { TemplateName = "CycloneVFX", AttachTo = "Target", Duration = 1, VFXType = "Static" },
	["TwistingSlash"] = { TemplateName = "TwistingSlashVFX", AttachTo = "Caster", Duration = 1.5, VFXType = "Static" },
	["DeathStab"] = { TemplateName = "DeathStabVFX",ImpactVFXName = "DeathStabImpactVFX", AttachTo = "Target", Duration = 0.4, VFXType = "Lunge" },
	["Inner"] = { TemplateName = "InnerVFX", AttachTo = "Caster", Duration = 2, VFXType = "Static" },

	-- ==== Dark Wizard ====
	["EnergyBall"] = { TemplateName = "EnergyBallVFX", AttachTo = "Target", Duration = 0.5, VFXType = "Projectile" },
	["EvilSpirit"] = { TemplateName = "EvilSpiritVFX", AttachTo = "Caster", Duration = 1.5, VFXType = "Static" },
	["IceStorm"] = { TemplateName = "IceStormVFX", AttachTo = "Target", Duration = 1.5, VFXType = "FallingArea", FallDuration = 0.4 },
	["ManaShield"] = { TemplateName = "ManaShieldVFX", AttachTo = "Caster", Duration = 2, VFXType = "Static" },

	-- ==== Fairy Elf ====
	["TripleShot"] = { TemplateName = "TripleShotVFX", AttachTo = "Target", Duration = 0.7, VFXType = "Projectile" },
	["IceArrow"] = { TemplateName = "IceArrowVFX", AttachTo = "Target", Duration = 0.6, VFXType = "Projectile" },
	["GreaterDamage"] = { TemplateName = "GreaterDamageVFX", AttachTo = "Caster", Duration = 2, VFXType = "Static" },
	["GreaterDefense"] = { TemplateName = "GreaterDefenseVFX", AttachTo = "Caster", Duration = 2, VFXType = "Static" }
}

return VFXData