--[[
	ARCHIVO: PlayerManager.lua (Versión Completa con Buff de Bienvenida)
	UBICACIÓN: ServerScriptService/PlayerManager.lua
]]

local Players = game:GetService("Players")
Players.CharacterAutoLoads = false
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Cargar Módulos
local Modules = ServerScriptService:WaitForChild("Modules")
local StatFormulas = require(Modules:WaitForChild("StatFormulas"))
local InventoryManager = require(Modules:WaitForChild("InventoryManager"))
-- (Asegúrate de tener los demás módulos que usas aquí, como CharacterAppearanceManager)

-- Cargar Eventos Remotos
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local selectClassEvent = RemoteEvents:WaitForChild("SelectClassEvent")
local showClassSelectionEvent = RemoteEvents:WaitForChild("ShowClassSelection")
local updateClientStatsEvent = RemoteEvents:WaitForChild("UpdateClientStats")

-- DataStore
local playerDataStore = DataStoreService:GetDataStore("PlayerData_V4") -- O la versión que estés usando

-- Función que configura el personaje
local function setupCharacter(player, character)
	-- Buscar el modelo correcto según la clase
	local className = player:GetAttribute("ClassName") or (player:FindFirstChild("ClassName") and player.ClassName.Value)
	local modelName = nil
	if className == "DarkKnight" then
		modelName = "DK_StarterCharacter"
	elseif className == "DarkWizard" then
		modelName = "DW_StarterCharacter"
	elseif className == "FairyElf" then
		modelName = "FE_StarterCharacter"
	end
	if modelName then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local StarterPlayer = game:GetService("StarterPlayer")
		local starterModel = ReplicatedStorage:FindFirstChild(modelName)
		if starterModel then
			-- Elimina cualquier StarterCharacter anterior
			local oldStarterChar = StarterPlayer:FindFirstChild("StarterCharacter")
			if oldStarterChar then oldStarterChar:Destroy() end
			-- Clona y asigna el modelo como StarterCharacter
			local starterCharClone = starterModel:Clone()
			starterCharClone.Name = "StarterCharacter"
			starterCharClone.Parent = StarterPlayer
			-- Forzar respawn del jugador con el modelo correcto
			player:LoadCharacter()
			-- Elimina el StarterCharacter para no afectar a otros jugadores
			starterCharClone:Destroy()
		else
			warn("No se encontró el modelo de personaje para la clase:", className)
		end
	end
	local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
	local currentStats = StatFormulas:GetStats(player)
	if currentStats and currentStats.MaxHP then
		humanoid.MaxHealth = currentStats.MaxHP
		humanoid.Health = currentStats.MaxHP
	end
	task.wait(0.1)
	local updatedStats = StatFormulas:GetStats(player)
	updatedStats.HP = humanoid.Health
	if updatedStats.MaxMP then
		updatedStats.MP = updatedStats.MaxMP
		StatFormulas:ModifyStat(player, "MP", updatedStats.MaxMP)
	end
	updateClientStatsEvent:FireClient(player, updatedStats)
	humanoid.HealthChanged:Connect(function(newHealth)
		StatFormulas:ModifyStat(player, "HP", newHealth)
	end)
end

-- Se ejecuta cuando un jugador entra al juego
local function onPlayerAdded(player)
	local playerClass = Instance.new("StringValue")
	playerClass.Name = "ClassName"
	playerClass.Parent = player

	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)

	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId .. "-data")
	end)

	if not success then
		warn("No se pudo acceder a DataStore para el jugador:", player.Name, ". Error:", data)
		player:Kick("No se pudieron cargar tus datos. Inténtalo de nuevo.")
		return
	end

	if data and data.ClassName then
		print("Datos encontrados para", player.Name, ". Clase:", data.ClassName)
		player:SetAttribute("ClassName", data.ClassName)
		playerClass.Value = data.ClassName
		StatFormulas:InitStats(player, data.ClassName, data)
		InventoryManager.InitializeInventory(player, data)

		-- Aplicar buffs y recalcular stats
		StatFormulas:ApplyBeginnerBuffs(player)
		StatFormulas:RecalculateDerivedStats(player)

		-- Enviar stats completos al HUD
		local stats = StatFormulas:GetStats(player)
		stats.HP = stats.HP or stats.MaxHP or 100
		stats.MaxHP = stats.MaxHP or 100
		stats.MP = stats.MP or stats.MaxMP or 50
		stats.MaxMP = stats.MaxMP or 50
		stats.EXP = stats.EXP or 0
		stats.EXPToLevel = stats.EXPToLevel or 100
		stats.Level = stats.Level or 1
		stats.Zen = stats.Zen or 0
		updateClientStatsEvent:FireClient(player, stats)

		-- Forzar respawn con el modelo correcto usando StarterCharacter
		local StarterPlayer = game:GetService("StarterPlayer")
		local className = data.ClassName
		local modelName = nil
		if className == "DarkKnight" then
			modelName = "DK_StarterCharacter"
		elseif className == "DarkWizard" then
			modelName = "DW_StarterCharacter"
		elseif className == "FairyElf" then
			modelName = "FE_StarterCharacter"
		end
		if modelName then
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local starterModel = ReplicatedStorage:FindFirstChild(modelName)
			if starterModel then
				-- Elimina cualquier StarterCharacter anterior
				local oldStarterChar = StarterPlayer:FindFirstChild("StarterCharacter")
				if oldStarterChar then oldStarterChar:Destroy() end
				-- Clona y asigna el modelo como StarterCharacter
				local starterCharClone = starterModel:Clone()
				starterCharClone.Name = "StarterCharacter"
				starterCharClone.Parent = StarterPlayer
				player:LoadCharacter()
				-- Elimina el StarterCharacter para no afectar a otros jugadores
				starterCharClone:Destroy()
			else
				warn("No se encontró el modelo de personaje para la clase:", className)
			end
		end
	else
		print(player.Name, "es un jugador nuevo. Mostrando selección de clase.")
		showClassSelectionEvent:FireClient(player)
	end
end

-- Se ejecuta cuando un jugador nuevo selecciona su clase
local function onClassSelected(player, className)
	if className == "DarkKnight" or className == "DarkWizard" or className == "FairyElf" then
		local playerClassValue = player:FindFirstChild("ClassName")
		if playerClassValue and playerClassValue.Value == "" then
			playerClassValue.Value = className
			player:SetAttribute("ClassName", className)

			StatFormulas:InitStats(player, className)
			InventoryManager.InitializeInventory(player, nil)

			-- Aplicar buffs y recalcular stats para el nuevo personaje
			StatFormulas:ApplyBeginnerBuffs(player)
			StatFormulas:RecalculateDerivedStats(player)
			
			local initialStats = StatFormulas:GetStats(player)
			local initialInventory = InventoryManager.GetInventoryData(player)

			local dataToSave = {
				ClassName = className,
				Stats = initialStats,
				Inventory = initialInventory
			}

			local s, e = pcall(function() playerDataStore:SetAsync(player.UserId .. "-data", dataToSave) end)
			if not s then warn("Error al guardar datos iniciales para", player.Name, ":", e) end
		end
	end
end

-- Se ejecuta cuando un jugador sale del juego
local function onPlayerRemoving(player)
	local statsToSave = StatFormulas:GetStats(player)
	local inventoryToSave = InventoryManager.GetInventoryData(player)

	if not statsToSave or not inventoryToSave then
		warn("No se pudieron obtener los datos para guardar para el jugador:", player.Name)
		return
	end

	local dataToSave = {
		ClassName = player:FindFirstChild("ClassName").Value,
		Stats = statsToSave,
		Inventory = inventoryToSave
	}

	local s, e = pcall(function() playerDataStore:SetAsync(player.UserId .. "-data", dataToSave) end)
	if not s then warn("¡ERROR al guardar datos para", player.Name, "!", e) end
end

-- Conectar todas las funciones a los eventos correspondientes
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
selectClassEvent.OnServerEvent:Connect(onClassSelected)
