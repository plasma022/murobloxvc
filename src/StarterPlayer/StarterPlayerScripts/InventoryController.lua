--[[
    ARCHIVO: InventoryController.lua (Versión Final y Completa)
    UBICACIÓN: StarterPlayer/StarterPlayerScripts/InventoryController.lua
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Referencia al botón de abrir inventario en el HUD
local mainHudGui = playerGui:FindFirstChild("MainHudGui")
local openInventoryButton = mainHudGui and mainHudGui:FindFirstChild("OpenInventoryButton")

-- Referencias a la UI del Inventario
local inventoryGui = playerGui:WaitForChild("InventoryGui")
local mainFrame = inventoryGui:WaitForChild("MainFrame")
local itemsGrid = mainFrame:WaitForChild("ItemsGrid")
local itemSlotTemplate = itemsGrid:WaitForChild("ItemSlotTemplate")
local equipmentFrame = mainFrame:WaitForChild("EquipmentFrame")
local tooltipFrame = mainFrame:WaitForChild("TooltipFrame")

-- Referencias a los Eventos Remotos
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local EquipItemEvent = RemoteEvents:WaitForChild("EquipItem")
local UpdateInventoryEvent = RemoteEvents:WaitForChild("UpdateInventory")
local DropItemEvent = RemoteEvents:WaitForChild("DropItemEvent")
local UpdateClientStatsEvent = RemoteEvents:WaitForChild("UpdateClientStats")



-- Variables de estado
local slotConnections = {}
local isTooltipHovered = false
local hideTooltipThread = nil
local draggingItemData = nil
local ghostIcon = nil
local mouseMoveConnection = nil
local currentPlayerStats = {}

-- Tabla para traducir los nombres de los requisitos
local statNameMap = {
	Strength = "STR", Agility = "AGI", Vitality = "VIT", Energy = "ENE"
}

-- Función para mostrar los detalles de un ítem
local function showTooltip(itemData)
	if hideTooltipThread then task.cancel(hideTooltipThread); hideTooltipThread = nil end

	tooltipFrame.ItemNameLabel.Text = itemData.Name .. " +" .. tostring(itemData.Level or 0)
	tooltipFrame.ItemTypeLabel.Text = itemData.Type or "Ítem"
	tooltipFrame.ItemDescriptionLabel.Text = itemData.Description or ""
	tooltipFrame.ItemStatsLabel.RichText = true

	local statsText = ""

	if itemData.MinDmg and itemData.MaxDmg then statsText ..= string.format("Daño: %d ~ %d\n", itemData.MinDmg, itemData.MaxDmg) end
	if itemData.Defense then statsText ..= "Defensa: " .. tostring(itemData.Defense) .. "\n" end
	if itemData.AttackSpeed then statsText ..= "Velocidad de Ataque: " .. tostring(itemData.AttackSpeed) .. "\n" end
	if itemData.MovementSpeed then statsText ..= "Velocidad de Movimiento: " .. tostring(itemData.MovementSpeed) .. "\n" end
	if itemData.Luck == true then statsText ..= "\n+ Suerte (+5% probabilidad crítica)\n(+25% probabilidad de exito)" end

	if itemData.ReqStats or itemData.ReqClass then
		statsText ..= "\nRequisitos:\n"
		if itemData.ReqClass then
			if currentPlayerStats and currentPlayerStats.ClassName and currentPlayerStats.ClassName == itemData.ReqClass then
				statsText ..= string.format("  Clase: %s\n", itemData.ReqClass)
			else
				statsText ..= string.format('<font color="rgb(255, 80, 80)">  Clase: %s</font>\n', itemData.ReqClass)
			end
		end
		if itemData.ReqStats then
			for stat, requiredValue in pairs(itemData.ReqStats) do
				local statAbbreviation = statNameMap[stat]
				if statAbbreviation and (currentPlayerStats[statAbbreviation] or 0) >= requiredValue then
					statsText ..= string.format("  %s: %d\n", stat, requiredValue)
				else
					statsText ..= string.format('<font color="rgb(255, 80, 80)">  %s: %d</font>\n', stat, requiredValue)
				end
			end
		end
	end

	tooltipFrame.ItemStatsLabel.Text = statsText
	tooltipFrame.Visible = true
end

-- Funciones para arrastrar y soltar
local function stopDrag()
	if mouseMoveConnection then mouseMoveConnection:Disconnect(); mouseMoveConnection = nil end
	if ghostIcon then ghostIcon:Destroy(); ghostIcon = nil end
	draggingItemData = nil
end

local function startDrag(itemData, slot)
	stopDrag()
	draggingItemData = itemData
	ghostIcon = Instance.new("ImageLabel")
	ghostIcon.Size = slot.Size
	ghostIcon.Image = slot.Image
	ghostIcon.BackgroundTransparency = 1
	ghostIcon.ZIndex = 10
	ghostIcon.Parent = mainFrame
	mouseMoveConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			ghostIcon.Position = UDim2.fromOffset(input.Position.X - mainFrame.AbsolutePosition.X, input.Position.Y - mainFrame.AbsolutePosition.Y)
		end
	end)
end

-- Función para poblar un slot de ítem
local function populateSlot(slot, itemData, isEquipped)
	-- Asigna la imagen, el nombre y el nivel al slot de la UI
	slot.Image = itemData.ImageId or ""
	local nameLabel = slot:FindFirstChild("ItemName")
	if nameLabel then nameLabel.Text = itemData.Name end
	local levelLabel = slot:FindFirstChild("ItemLevel")
	if levelLabel then levelLabel.Text = "+" .. tostring(itemData.Level or 0) end

	-- Limpia cualquier conexión de evento anterior para evitar bugs
	if slotConnections[slot] then
		for _, connection in ipairs(slotConnections[slot]) do
			connection:Disconnect()
		end
	end
	slotConnections[slot] = {}

	table.insert(slotConnections[slot], slot.MouseButton1Click:Connect(function()
		EquipItemEvent:FireServer(itemData.UniqueID)
	end))


	-- Conexiones para el Tooltip: Mostrar y ocultar los detalles del ítem
	table.insert(slotConnections[slot], slot.MouseEnter:Connect(function()
		showTooltip(itemData)
	end))
	table.insert(slotConnections[slot], slot.MouseLeave:Connect(function()
		hideTooltipThread = task.delay(0.1, function()
			if not isTooltipHovered then
				tooltipFrame.Visible = false
			end
		end)
	end))
end

-- Función para resetear un slot
local function resetSlot(slot)
	slot.Image = ""
	local nameLabel = slot:FindFirstChild("ItemName")
	if nameLabel then nameLabel.Text = "" end
	local levelLabel = slot:FindFirstChild("ItemLevel")
	if levelLabel then levelLabel.Text = "" end
	if slotConnections[slot] then
		for _, c in ipairs(slotConnections[slot]) do c:Disconnect() end
		slotConnections[slot] = nil
	end
end

-- Función principal para redibujar la UI del inventario
local function updateInventoryUI(inventoryData)
	if not inventoryData then return end
	for _, child in ipairs(itemsGrid:GetChildren()) do
		if child:IsA("ImageButton") and child.Name ~= "ItemSlotTemplate" then child:Destroy() end
	end
	for _, slot in pairs(equipmentFrame:GetChildren()) do
		if slot:IsA("ImageButton") then resetSlot(slot) end
	end
	local equippedItemsLookup = {}
	if inventoryData.Equipped then
		for _, uniqueId in pairs(inventoryData.Equipped) do equippedItemsLookup[uniqueId] = true end
	end
	if inventoryData.Items then
		for _, itemData in pairs(inventoryData.Items) do
			local isEquipped = equippedItemsLookup[itemData.UniqueID] or false
			if isEquipped then
				local equipmentSlot = equipmentFrame:FindFirstChild(itemData.Type)
				if equipmentSlot then populateSlot(equipmentSlot, itemData, true) end
			else
				local newSlot = itemSlotTemplate:Clone()
				newSlot.Name = itemData.UniqueID
				newSlot.Visible = true
				populateSlot(newSlot, itemData, false)
				newSlot.Parent = itemsGrid
			end
		end
	end
end

-- Manejador de Inputs
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	-- Tecla B para inventario
	if input.KeyCode == Enum.KeyCode.B then
		mainFrame.Visible = not mainFrame.Visible
	end
end

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingItemData then
		local mousePos = UserInputService:GetMouseLocation()
		local framePos = mainFrame.AbsolutePosition
		local frameSize = mainFrame.AbsoluteSize

		if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
			mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
			DropItemEvent:FireServer(draggingItemData.UniqueID)
		end

		stopDrag()
	end
end)

-- Conexiones

UserInputService.InputBegan:Connect(onInputBegan)
UpdateInventoryEvent.OnClientEvent:Connect(updateInventoryUI)
UpdateClientStatsEvent.OnClientEvent:Connect(function(stats) currentPlayerStats = stats end)
tooltipFrame.MouseEnter:Connect(function() isTooltipHovered = true; if hideTooltipThread then task.cancel(hideTooltipThread); hideTooltipThread = nil end end)
tooltipFrame.MouseLeave:Connect(function() isTooltipHovered = false; tooltipFrame.Visible = false end)

-- Conexión del botón de inventario en el HUD
if openInventoryButton then
	openInventoryButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
	end)
end

-- Estado inicial
inventoryGui.Enabled = true
mainFrame.Visible = false
tooltipFrame.Visible = false
