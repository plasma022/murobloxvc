-- Script que gestiona la creación y reaparición de enemigos
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local EnemyAI = require(script.Parent.Modules:WaitForChild("EnemyAI"))

local ZONES_FOLDER = Workspace:WaitForChild("Zones")
local RESPAWN_TIME = 8 -- Segundos

local function setupSpawner(spawnPoint)
	local enemyName = spawnPoint:GetAttribute("EnemyType") or "Zombie" -- Por defecto spawnea "Spider"
	local enemyTemplate = ServerStorage:FindFirstChild(enemyName)

	if not enemyTemplate then
		warn("No se encontró la plantilla del enemigo:", enemyName)
		return
	end

	local function spawnEnemy()
		local newEnemy = enemyTemplate:Clone()
		newEnemy:SetPrimaryPartCFrame(spawnPoint.CFrame)
		newEnemy.Parent = Workspace.Zones -- Organizar los enemigos dentro de la carpeta Zones

		local ai = EnemyAI.new(newEnemy, spawnPoint.Position)
		coroutine.wrap(ai.Run)(ai) -- Ejecutar la IA en un hilo separado

		newEnemy.Humanoid.Died:Once(function()
			print(newEnemy.Name, "ha muerto. Reaparecerá en", RESPAWN_TIME, "segundos.")
			task.wait(0.5)
			newEnemy:Destroy()
			task.wait(RESPAWN_TIME - 0.5)
			spawnEnemy() -- Vuelve a llamar a la función para reaparecer
		end)
	end

	spawnEnemy()
end

-- Recorrer todas las zonas y puntos de spawn
for _, zone in ipairs(ZONES_FOLDER:GetChildren()) do
	for _, spawnPoint in ipairs(zone:GetChildren()) do
		if spawnPoint:IsA("BasePart") then
			setupSpawner(spawnPoint)
		end
	end
end
