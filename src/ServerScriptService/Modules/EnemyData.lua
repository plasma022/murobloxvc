-- Módulo para almacenar los datos de cada tipo de enemigo
local EnemyData = {
	["Spider"] = {
		Experience = 15,
		AttackType = "Melee",
		AttackRange = 8,
		MinZen = 50,  -- Mínima cantidad de Zen que puede soltar
		MaxZen = 150, -- Máxima cantidad de Zen que puede soltar
	},
	["Zombie"] = { -- Asegúrate de tener una entrada para tus enemigos actuales
		Experience = 15,
		AttackType = "Melee",
		AttackRange = 8,
		MinZen = 75,
		MaxZen = 200,
	}
}

return EnemyData