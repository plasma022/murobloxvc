-- Ubicación: ServerScriptService/Modules/EnemyAI.lua
-- Módulo que controla el comportamiento de los enemigos (Versión con Barra de Vida y Daño al Jugador)
local EnemyAI = {}
EnemyAI.__index = EnemyAI

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ServerScriptService:WaitForChild("Modules")

-- Cargar los módulos necesarios
local StatFormulas = require(Modules:WaitForChild("StatFormulas"))
local EnemyData = require(Modules:WaitForChild("EnemyData"))
local LootManager
pcall(function() LootManager = require(Modules:WaitForChild("LootManager")) end)

-- Referencia al evento de daño
local ShowDamageIndicator = ReplicatedStorage.RemoteEvents:WaitForChild("ShowDamageIndicator")

-- Constantes de comportamiento
local AGRO_RADIUS = 40
local PATROL_RADIUS = 50
local DEAGRO_DISTANCE = 60

function EnemyAI.new(enemyModel, spawnPosition)
	local self = setmetatable({}, EnemyAI)

	self.Model = enemyModel
	self.Humanoid = enemyModel:WaitForChild("Humanoid")
	self.RootPart = enemyModel:WaitForChild("HumanoidRootPart")
	self.Animator = self.Humanoid:WaitForChild("Animator")
	self.SpawnPosition = spawnPosition
	self.lastAttackTime = 0

	self.Data = EnemyData[enemyModel.Name] or {}

	-- Asignar stats al Humanoide
	self.Humanoid.MaxHealth = self.Data.MaxHP or 100
	self.Humanoid.Health = self.Humanoid.MaxHealth
	self.AttackRange = self.Data.AttackRange or 10
	self.AttackSpeed = self.Data.AttackSpeed or 2

	-- *** GESTIÓN DE LA BARRA DE VIDA ***
	local healthBarTemplate = ReplicatedStorage.UI_Templates:FindFirstChild("EnemyHealthBarTemplate")
	if healthBarTemplate then
		local healthBarClone = healthBarTemplate:Clone()
		local infoText = healthBarClone:FindFirstChild("InfoText")
		local barFill = healthBarClone:FindFirstChild("BarBackground"):FindFirstChild("BarFill")

		-- Establecer el texto inicial
		infoText.Text = string.format("Lv. %d | %s", self.Data.Level or 1, self.Model.Name)

		-- Función para actualizar la barra
		local function updateHealthBar(newHealth)
			local healthPercent = math.clamp(newHealth / self.Humanoid.MaxHealth, 0, 1)
			barFill.Size = UDim2.new(healthPercent, 0, 1, 0)
		end

		-- Conectar al evento de cambio de vida
		self.Humanoid.HealthChanged:Connect(updateHealthBar)
		updateHealthBar(self.Humanoid.Health) -- Llamar una vez para el estado inicial

		healthBarClone.Adornee = self.Model:FindFirstChild("Head") or self.RootPart
		healthBarClone.Parent = self.Model
	end

	-- Cargar animaciones (sin cambios)
	local attackAnimInstance = self.Model:FindFirstChild("AttackAnim")
	if attackAnimInstance then
		self.AttackAnimation = self.Animator:LoadAnimation(attackAnimInstance)
		self.AttackAnimation.Priority = Enum.AnimationPriority.Action
	end
	local walkAnimInstance = self.Model:FindFirstChild("Walk")
	if walkAnimInstance then
		self.WalkAnimation = self.Animator:LoadAnimation(walkAnimInstance)
		self.WalkAnimation.Looped = true
		self.WalkAnimation.Priority = Enum.AnimationPriority.Action
	end

	-- Conexión al evento de muerte (sin cambios)
	self.Humanoid.Died:Connect(function()
		local attackerTag = self.Model:FindFirstChild("AttackerTag")
		local killerPlayer = attackerTag and attackerTag.Value
		if killerPlayer and killerPlayer:IsA("Player") then
			if self.Data.Experience then StatFormulas:AddExp(killerPlayer, self.Data.Experience) end
			if self.Data.MinZen and self.Data.MaxZen then
				local zenAmount = math.random(self.Data.MinZen, self.Data.MaxZen)
				StatFormulas:AddZen(killerPlayer, zenAmount)
			end
		end
		if LootManager then LootManager.DropLoot(self.Model.Name, self.RootPart.Position) end
	end)

	return self
end

-- Función para gestionar el estado de las animaciones (sin cambios)
function EnemyAI:SetAnimation(animationName)
	if animationName == "Walk" then
		if self.AttackAnimation and self.AttackAnimation.IsPlaying then self.AttackAnimation:Stop() end
		if self.WalkAnimation and not self.WalkAnimation.IsPlaying then self.WalkAnimation:Play() end
	elseif animationName == "Attack" then
		if self.WalkAnimation and self.WalkAnimation.IsPlaying then self.WalkAnimation:Stop() end
		if self.AttackAnimation then self.AttackAnimation:Play() end
	else -- "Idle" o detener todo
		if self.WalkAnimation and self.WalkAnimation.IsPlaying then self.WalkAnimation:Stop() end
		if self.AttackAnimation and self.AttackAnimation.IsPlaying then self.AttackAnimation:Stop() end
	end
end

-- Bucle principal de la IA (sin cambios)
function EnemyAI:Run()
	while self.Model and self.Humanoid.Health > 0 do
		local target = self:FindTarget()
		if target and target.Parent then
			self:ChaseAndAttack(target)
		else
			self:Patrol()
		end
		task.wait(0.2)
	end
	self:SetAnimation("Idle")
end

-- Lógica de persecución y ataque
function EnemyAI:ChaseAndAttack(target)
	local targetRoot = target.Parent:FindFirstChild("HumanoidRootPart")
	if not targetRoot then self:Patrol(); return end
	local distance = (self.RootPart.Position - targetRoot.Position).Magnitude
	if distance > DEAGRO_DISTANCE then self:Patrol(); return end

	if distance > self.AttackRange then
		self:SetAnimation("Walk")
		self.Humanoid:MoveTo(targetRoot.Position)
	else
		self:SetAnimation("Idle")
		self.Humanoid:MoveTo(self.RootPart.Position)

		if tick() - self.lastAttackTime >= self.AttackSpeed then
			self.lastAttackTime = tick()
			local lookAtPosition = Vector3.new(targetRoot.Position.X, self.RootPart.Position.Y, targetRoot.Position.Z)
			self.RootPart.CFrame = CFrame.new(self.RootPart.Position, lookAtPosition)
			self:SetAnimation("Attack")

			local damage = math.random(self.Data.MinDmg or 5, self.Data.MaxDmg or 10)
			target:TakeDamage(damage)

			-- *** MOSTRAR DAÑO AL JUGADOR ***
			-- Enviamos el evento para que el cliente del jugador muestre el daño que ha recibido.
			ShowDamageIndicator:FireAllClients(target.Parent, damage, "EnemyAttack")
		end
	end
end

-- Busca al jugador más cercano (sin cambios)
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

-- Patrulla (sin cambios)
function EnemyAI:Patrol()
	self:SetAnimation("Walk")
	local randomX = self.SpawnPosition.X + math.random(-PATROL_RADIUS, PATROL_RADIUS)
	local randomZ = self.SpawnPosition.Z + math.random(-PATROL_RADIUS, PATROL_RADIUS)
	local patrolTo = Vector3.new(randomX, self.SpawnPosition.Y, randomZ)
	self.Humanoid:MoveTo(patrolTo)
end

return EnemyAI
