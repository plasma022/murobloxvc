
--[[
	ARCHIVO: StatFormulas.lua (Versión Final y Completa)
	UBICACIÓN: ServerScriptService/Modules/StatFormulas.lua
]]

local StatFormulas = {}

function StatFormulas:AddZen(player, amount)
	local stats = StatFormulas:GetStats(player)
	if not stats then return end
	stats.Zen = (stats.Zen or 0) + amount
	StatFormulas:ModifyStat(player, "Zen", stats.Zen)
	-- Actualiza el HUD usando el evento correcto
	UpdateClientStatsEvent:FireClient(player, stats)
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateClientStatsEvent = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateClientStats")
local PlayLevelUpEffectEvent = ReplicatedStorage.RemoteEvents:WaitForChild("PlayLevelUpEffect")
local AssignStatPointEvent = ReplicatedStorage.RemoteEvents:WaitForChild("AssignStatPoint")

local playerStats = {}
local activeBuffs = {}

local BASE_STATS = {
	["DarkKnight"] = {HP=79, MP=32, Level=1, EXP=0, STR=15, AGI=10, VIT=12, ENE=5, Zen=0},
	["DarkWizard"] = {HP=63, MP=18, Level=1, EXP=0, STR=5, AGI=10, VIT=8, ENE=20, Zen=0},
	["FairyElf"] = {HP=74, MP=30, Level=1, EXP=0, STR=10, AGI=15, VIT=10, ENE=10, Zen=0},
}
StatFormulas.BASE_STATS = BASE_STATS

local DEFAULT_STAT_POINTS_PER_LEVEL = 5
local BASE_WALKSPEED = 16

-- ¡NUEVO! Fórmula de EXP más rápida
local function calculateEXPToLevel(level)
	return math.floor(150 * (level ^ 1.5))
end

local function calculateMaxHP(className, level, vit)
	level = level or 1; vit = vit or 10
	local base = BASE_STATS[className] or BASE_STATS["DarkKnight"]
	if className == "DarkWizard" then return base.HP + math.floor(level * 1.5 + vit * 2)
	elseif className == "DarkKnight" then return base.HP + math.floor(level * 2.2 + vit * 3) * 1.1
	elseif className == "FairyElf" then return base.HP + math.floor(level * 1.8 + vit * 2.5)
	else return base.HP + math.floor(level * 2.2 + vit * 3) * 1.1 end
end

local function calculateMaxMP(className, level, ene)
	level = level or 1; ene = ene or 10
	local base = BASE_STATS[className] or BASE_STATS["DarkKnight"]
	if className == "DarkWizard" then return base.MP + math.floor(level * 2 + ene * 3)
	elseif className == "DarkKnight" then return base.MP + math.floor(level * 1 + ene * 1.5)
	elseif className == "FairyElf" then return base.MP + math.floor(level * 1.2 + ene * 2)
	else return base.MP + math.floor(level * 1 + ene * 1.5) end
end

local InventoryManager = nil
local function getInventoryManager()
	if not InventoryManager then
		pcall(function() InventoryManager = require(script.Parent:WaitForChild("InventoryManager")) end)
	end
	return InventoryManager
end

local function recalculateMaxStats(stats, className)
	if not stats then return end
	className = className or stats.ClassName or "DarkKnight"
	stats.MaxHP = calculateMaxHP(className, stats.Level, stats.VIT)
	stats.MaxMP = calculateMaxMP(className, stats.Level, stats.ENE)
end

function StatFormulas:InitStats(player, className, loadedData)
	if not player or not className then return end
	local stats = {}
	local base = BASE_STATS[className] or BASE_STATS["DarkKnight"]
	for stat, value in pairs(base) do stats[stat] = value end
	stats.ClassName = className
	stats.StatPoints = 0
	if loadedData and type(loadedData.Stats) == "table" then
		for stat, value in pairs(loadedData.Stats) do stats[stat] = value end
	end
	stats.EXPToLevel = calculateEXPToLevel(stats.Level)
	recalculateMaxStats(stats, className)
	stats.HP = stats.MaxHP
	stats.MP = stats.MaxMP
	playerStats[player.UserId] = stats
end

function StatFormulas:ModifyStat(player, statName, value)
	if not player or not statName then return end
	local stats = playerStats[player.UserId]
	if not stats then return end
	stats[statName] = value
	if statName == "Level" or statName == "VIT" or statName == "ENE" then recalculateMaxStats(stats, stats.ClassName) end
	if statName == "HP" then stats.HP = math.min(value, stats.MaxHP or value)
	elseif statName == "MP" then stats.MP = math.min(value, stats.MaxMP or value) end
	UpdateClientStatsEvent:FireClient(player, stats)
end

function StatFormulas:GetStats(player)
	if not player then return {} end
	return playerStats[player.UserId] or {}
end

function StatFormulas:AddExp(player, amount)
	if not player or not amount then return end
	local stats = playerStats[player.UserId]
	if not stats then return end
	stats.EXP = (stats.EXP or 0) + amount
	local leveledUp = false
	while stats.EXP >= stats.EXPToLevel do
		leveledUp = true
		stats.EXP = stats.EXP - stats.EXPToLevel
		stats.Level = stats.Level + 1
		stats.StatPoints = (stats.StatPoints or 0) + DEFAULT_STAT_POINTS_PER_LEVEL
		stats.EXPToLevel = calculateEXPToLevel(stats.Level)
		recalculateMaxStats(stats, stats.ClassName)
		stats.HP = stats.MaxHP
		stats.MP = stats.MaxMP
	end
	if leveledUp then PlayLevelUpEffectEvent:FireClient(player) end
	UpdateClientStatsEvent:FireClient(player, stats)
end

function StatFormulas:GetAttackCooldown(player)
	local stats = self:GetStats(player)
	if not stats then return 2 end
	local attackSpeed = stats.TotalAttackSpeed or 0
	local cooldown = 1.5 / (1 + attackSpeed * 0.05)
	return math.max(cooldown, 0.2) 
end

-- ¡NUEVO! Función para aplicar los buffs iniciales
function StatFormulas:ApplyBeginnerBuffs(player)
	if not activeBuffs[player.UserId] then activeBuffs[player.UserId] = {} end

	-- Añadir un buff de +30 de daño que dura mucho tiempo
	activeBuffs[player.UserId]["BeginnerDamage"] = {
		Expires = tick() + 9999999,
		Effect = { Type = "Damage", Value = 30 } -- De Porcentaje a Valor
	}

	-- Añadir un buff de +50 de defensa
	activeBuffs[player.UserId]["BeginnerDefense"] = {
		Expires = tick() + 9999999,
		Effect = { Type = "Defense", Value = 50 } -- De Porcentaje a Valor
	}
	print(player.Name, "ha recibido los buffs de bienvenida.")
end

-- Calcula el RANGO de daño (Min y Max) (ACTUALIZADO)
function StatFormulas:CalculateDamageRange(player)
	local stats = self:GetStats(player)
	local className = stats.ClassName
	if not className then return 0, 0 end

	local level, STR, AGI, ENE = stats.Level or 1, stats.STR or 0, stats.AGI or 0, stats.ENE or 0
	local weaponMinDmg, weaponMaxDmg = 0, 0

	local inventoryManager = getInventoryManager()
	if inventoryManager and inventoryManager.GetInventoryData then
		local inventory = inventoryManager.GetInventoryData(player)
		if inventory and inventory.Equipped then
			for slot, uniqueId in pairs(inventory.Equipped) do
				local itemData
				for _, item in ipairs(inventory.Items) do
					if item.UniqueID == uniqueId then itemData = item; break; end
				end
				if itemData and (itemData.Type == "Sword" or itemData.Type == "Axe" or itemData.Type == "Staff" or itemData.Type == "Bow") then
					if itemData.MinDmg then
						weaponMinDmg = weaponMinDmg + itemData.MinDmg
						weaponMaxDmg = weaponMaxDmg + itemData.MaxDmg
					end
				end
			end
		end
	end
	local baseMinDmg, baseMaxDmg = 0, 0
	if className == "DarkKnight" then
		baseMinDmg = STR / 8
		baseMaxDmg = STR / 4
	elseif className == "DarkWizard" then
		baseMinDmg = ENE / 9
		baseMaxDmg = ENE / 4
	elseif className == "FairyElf" then
		baseMinDmg = (STR + AGI) / 14
		baseMaxDmg = (STR + AGI) / 8
	end

	local totalMinDmg = baseMinDmg + weaponMinDmg
	local totalMaxDmg = baseMaxDmg + weaponMaxDmg
	
	-- ¡NUEVO! Aplicar buffs de daño
	-- Aplicar buffs de daño
	if activeBuffs[player.UserId] then
		for buffName, buffInfo in pairs(activeBuffs[player.UserId]) do
			if buffInfo.Effect.Type == "Damage" and buffInfo.Effect.Value then
				-- ¡CORRECCIÓN! Sumar el valor plano en lugar de multiplicar
				totalMinDmg = totalMinDmg + buffInfo.Effect.Value
				totalMaxDmg = totalMaxDmg + buffInfo.Effect.Value
			end
		end
	end

	return math.floor(totalMinDmg), math.floor(totalMaxDmg)
end

-- Calcula un GOLPE de daño (un número aleatorio dentro del rango)
function StatFormulas:CalculateDamage(player)
	local minDmg, maxDmg = self:CalculateDamageRange(player)
	if minDmg > maxDmg then minDmg = maxDmg end
	if maxDmg <= 0 then return 0 end
	local dmg = math.random(minDmg, maxDmg)
	-- Aplicar buff de Absorption (reduce daño recibido, no daño infligido)
	return dmg
end

-- Calcula la defensa total (¡CORREGIDO!)
function StatFormulas:CalculateDefense(player)
	local stats = self:GetStats(player)
	local className = stats.ClassName
	if not className then return 0 end

	local AGI = stats.AGI or 0
	local defenseFromItems = 0

	local inventoryManager = getInventoryManager()
	if inventoryManager and inventoryManager.GetInventoryData then
		local inventory = inventoryManager.GetInventoryData(player)
		if inventory and inventory.Equipped then
			for slot, uniqueId in pairs(inventory.Equipped) do
				local itemData
				for _, item in ipairs(inventory.Items) do
					if item.UniqueID == uniqueId then itemData = item; break; end
				end
				if itemData and itemData.Defense then
					defenseFromItems = defenseFromItems + itemData.Defense
				end
			end
		end
	end

	local baseDefense = AGI / 3
	local totalDefense = baseDefense + defenseFromItems

	-- Aplicar buffs de defensa
	if activeBuffs[player.UserId] then
		for buffName, buffInfo in pairs(activeBuffs[player.UserId]) do
			if buffInfo.Effect.Type == "Defense" and buffInfo.Effect.Value then
				totalDefense = totalDefense + buffInfo.Effect.Value
			end
			-- Buff de Absorption: suma defensa porcentual
			if buffInfo.Effect.Type == "Absorption" and buffInfo.Effect.Value then
				totalDefense = totalDefense * (1 + buffInfo.Effect.Value / 100)
			end
		end
	end

	return math.floor(totalDefense)
end

function StatFormulas:CalculateAttackSpeed(player)
	local stats = self:GetStats(player)
	local className = stats.ClassName
	if not className then return 0 end
	local AGI = stats.AGI or 0
	local aspdFromItems = 0
	local inventoryManager = getInventoryManager()
	if inventoryManager and inventoryManager.GetInventoryData then
		local inventory = inventoryManager.GetInventoryData(player)
		if inventory and inventory.Equipped then
			for slot, uniqueId in pairs(inventory.Equipped) do
				local itemData
				for _, item in ipairs(inventory.Items) do
					if item.UniqueID == uniqueId then itemData = item; break; end
				end
				if itemData and itemData.AttackSpeed then
					aspdFromItems = aspdFromItems + itemData.AttackSpeed
				end
			end
		end
	end
	local baseASPD = AGI / 15
	local totalASPD = baseASPD + aspdFromItems
	-- Buff de AttackSpeed
	if activeBuffs[player.UserId] then
		for buffName, buffInfo in pairs(activeBuffs[player.UserId]) do
			if buffInfo.Effect.Type == "AttackSpeed" and buffInfo.Effect.Value then
				totalASPD = totalASPD + buffInfo.Effect.Value
			end
		end
	end
	return math.floor(totalASPD)
end

function StatFormulas:CalculateMovementSpeed(player)
	local stats = self:GetStats(player)
	if not stats then return BASE_WALKSPEED end
	local movementSpeedFromItems = 0
	local inventoryManager = getInventoryManager()
	if inventoryManager and inventoryManager.GetInventoryData then
		local inventory = inventoryManager.GetInventoryData(player)
		if inventory and inventory.Equipped then
			for slot, uniqueId in pairs(inventory.Equipped) do
				local itemData
				for _, item in ipairs(inventory.Items) do
					if item.UniqueID == uniqueId then itemData = item; break; end
				end
				if itemData and itemData.MovementSpeed then
					movementSpeedFromItems = movementSpeedFromItems + itemData.MovementSpeed
				end
			end
		end
	end
	local totalMoveSpeed = BASE_WALKSPEED + movementSpeedFromItems
	-- Buff de MovementSpeed
	if activeBuffs[player.UserId] then
		for buffName, buffInfo in pairs(activeBuffs[player.UserId]) do
			if buffInfo.Effect.Type == "MovementSpeed" and buffInfo.Effect.Value then
				totalMoveSpeed = totalMoveSpeed + buffInfo.Effect.Value
			end
		end
	end
	return totalMoveSpeed
end

-- Recalcula todas las estadísticas derivadas (CORREGIDO)
function StatFormulas:RecalculateDerivedStats(player)
	local stats = self:GetStats(player)
	if not stats or not next(stats) then return end

	-- Guardar el rango de daño para mostrarlo en la UI
	stats.MinDamage, stats.MaxDamage = self:CalculateDamageRange(player)
	stats.TotalDamage = self:CalculateDamage(player)
	stats.TotalDefense = self:CalculateDefense(player)
	stats.TotalAttackSpeed = self:CalculateAttackSpeed(player)
	stats.TotalMovementSpeed = self:CalculateMovementSpeed(player)

	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = stats.TotalMovementSpeed
	end
	UpdateClientStatsEvent:FireClient(player, stats)
end

local function onAssignStatPoint(player, statName)
	if not player or not statName then return end
	local stats = playerStats[player.UserId]
	if not stats or (stats.StatPoints or 0) <= 0 then return end
	if statName == "STR" or statName == "AGI" or statName == "VIT" or statName == "ENE" then
		stats[statName] = (stats[statName] or 0) + 1
		stats.StatPoints = stats.StatPoints - 1
		StatFormulas:RecalculateDerivedStats(player)
	end
end

AssignStatPointEvent.OnServerEvent:Connect(onAssignStatPoint)

return StatFormulas
