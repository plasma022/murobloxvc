--[[
    ARCHIVO: InventoryManager.lua (Versión Completa y Final)
    UBICACIÓN: ServerScriptService/Modules/InventoryManager.lua
]]

local InventoryManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StatFormulas = require(ServerScriptService.Modules:WaitForChild("StatFormulas"))
local UpdateInventoryEvent = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateInventory")
local EquipItemEvent = ReplicatedStorage.RemoteEvents:WaitForChild("EquipItem")

local playersData = {}

-- Inicializa el inventario para un jugador
function InventoryManager.InitializeInventory(player, loadedData)
	local inventory = (loadedData and loadedData.Inventory) or {}
	playersData[player.UserId] = {
		Items = inventory.Items or {},
		Equipped = inventory.Equipped or {}
	}
end

-- Desequipa todos los ítems de un jugador (usado al cambiar de clase)
function InventoryManager.UnequipAll(player)
	local inventory = playersData[player.UserId]
	if not inventory then return end
	inventory.Equipped = {}
end

-- Devuelve los datos del inventario de un jugador
function InventoryManager.GetInventoryData(player)
	return playersData[player.UserId]
end

-- Añade un ítem al inventario de un jugador
function InventoryManager.AddItem(player, itemData)
	local inventory = playersData[player.UserId]
	if inventory and inventory.Items then
		table.insert(inventory.Items, itemData)
		UpdateInventoryEvent:FireClient(player, inventory)
	end
end

-- Se ejecuta cuando un jugador hace clic en un ítem para equiparlo/desequiparlo
local function onEquipItem(player, itemUniqueID)
	local inventory = playersData[player.UserId]
	if not inventory then return end

	local itemToEquip
	for _, item in ipairs(inventory.Items) do
		if item.UniqueID == itemUniqueID then
			itemToEquip = item
			break
		end
	end

	if not itemToEquip then return end

	local itemType = itemToEquip.Type
	if not itemType then return end

	-- Si el ítem ya está equipado en su slot, lo desequipamos
	if inventory.Equipped[itemType] == itemUniqueID then
		inventory.Equipped[itemType] = nil
	else
		-- Si no, lo equipamos (la validación de requisitos se hace en el cliente y aquí)
		local playerStats = StatFormulas:GetStats(player)
		local canEquip = true

		if itemToEquip.ReqClass and itemToEquip.ReqClass ~= playerStats.ClassName then
			canEquip = false
		end

		if canEquip and itemToEquip.ReqStats then
			for stat, requiredValue in pairs(itemToEquip.ReqStats) do
				local statAbbreviation = StatFormulas.statNameMap[stat] -- Suponiendo que statNameMap está en StatFormulas
				if not statAbbreviation or (playerStats[statAbbreviation] or 0) < requiredValue then
					canEquip = false
					break
				end
			end
		end

		if canEquip then
			inventory.Equipped[itemType] = itemToEquip.UniqueID
		end
	end

	StatFormulas:RecalculateDerivedStats(player)
	UpdateInventoryEvent:FireClient(player, inventory)
end

EquipItemEvent.OnServerEvent:Connect(onEquipItem)

return InventoryManager
