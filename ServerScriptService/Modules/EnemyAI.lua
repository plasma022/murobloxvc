-- Módulo que controla el comportamiento de los enemigos (Versión Completa y Corregida)
local EnemyAI = {}
EnemyAI.__index = EnemyAI

local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService:WaitForChild("Modules")

-- Cargar los módulos necesarios
local StatFormulas = require(Modules:WaitForChild("StatFormulas"))
local EnemyData = require(Modules:WaitForChild("EnemyData"))
local LootManager
pcall(function() LootManager = require(Modules:WaitForChild("LootManager")) end)

local ATTACK_DAMAGE = 10
local ATTACK_COOLDOWN = 2
local AGRO_RADIUS = 30
local PATROL_RADIUS = 50

function EnemyAI.new(enemyModel, spawnPosition)
	local self = setmetatable({}, EnemyAI)

	self.Model = enemyModel
	self.Humanoid = enemyModel:WaitForChild("Humanoid")
	self.RootPart = enemyModel:WaitForChild("HumanoidRootPart")
	self.Animator = self.Humanoid:WaitForChild("Animator")
	self.SpawnPosition = spawnPosition -- ¡CORRECCIÓN CLAVE! Guardar la posición de spawn
	self.lastAttack = 0

	self.Data = EnemyData[enemyModel.Name] or {}
	self.AttackRange = self.Data.AttackRange or 8

	local attackAnimInstance = self.Model:FindFirstChild("AttackAnim")
	if attackAnimInstance then
		self.AttackAnimation = self.Animator:LoadAnimation(attackAnimInstance)
	end

	-- Conexión al evento de muerte del enemigo
	self.Humanoid.Died:Connect(function()
		local attackerTag = self.Model:FindFirstChild("AttackerTag")
		local killerPlayer = attackerTag and attackerTag.Value

		if killerPlayer then
			local enemyData = EnemyData[self.Model.Name]
			if enemyData then
				StatFormulas:AddExp(killerPlayer, enemyData.Experience)

				local zenAmount = math.random(enemyData.MinZen, enemyData.MaxZen)
				StatFormulas:AddZen(killerPlayer, zenAmount)
			end
		end

		if LootManager then
			LootManager.DropLoot(self.Model.Name, self.RootPart.Position)
		end
	end)

	return self
end

-- (El resto de las funciones de la IA, como Run, FindTarget, Attack y Patrol, se mantienen igual)
function EnemyAI:Run()
	while self.Model and self.Humanoid.Health > 0 do
		local target = self:FindTarget()
		if target and target.Parent then
			-- Actualiza la posición del jugador en cada ciclo
			local targetRoot = target.Parent:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local distance = (self.RootPart.Position - targetRoot.Position).Magnitude
				if distance > self.AttackRange then
					self:Attack(target)
				else
					-- Mueve al enemigo hacia la posición ACTUAL del jugador
					self.Humanoid:MoveTo(targetRoot.Position)
					if tick() - self.lastAttack > ATTACK_COOLDOWN then
						self.lastAttack = tick()
						if self.AttackAnimation then
							self.AttackAnimation:Play()
							task.wait(0.5)
						end
						-- Verifica la posición actual antes de aplicar daño
						if target.Health > 0 and (self.RootPart.Position - targetRoot.Position).Magnitude <= self.AttackRange + 2 then
							target:TakeDamage(ATTACK_DAMAGE)
						end
					end
				end
			end
		else
			self:Patrol()
		end
		task.wait(0.5)
	end
end

function EnemyAI:FindTarget()
	local closestTarget, minDistance = nil, AGRO_RADIUS
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
			local distance = (self.RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < minDistance then
				minDistance = distance
				closestTarget = player.Character.Humanoid
			end
		end
	end
	return closestTarget
end

function EnemyAI:Attack(targetHumanoid)
	self.Humanoid:MoveTo(targetHumanoid.Parent.HumanoidRootPart.Position)
end

function EnemyAI:Patrol()
	local randomX = self.SpawnPosition.X + math.random(-PATROL_RADIUS, PATROL_RADIUS)
	local randomZ = self.SpawnPosition.Z + math.random(-PATROL_RADIUS, PATROL_RADIUS)
	local patrolTo = Vector3.new(randomX, self.SpawnPosition.Y, randomZ)
	self.Humanoid:MoveTo(patrolTo)
end

return EnemyAI