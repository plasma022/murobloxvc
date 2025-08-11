
local CharacterAppearanceManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemModelsFolder = ReplicatedStorage:WaitForChild("ItemModels")

-- Tabla para rastrear los accesorios/herramientas equipados por cada jugador
local equippedModels = {}

function CharacterAppearanceManager.ClearAppearance(player)
	if equippedModels[player.UserId] then
		equippedModels[player.UserId] = {}
	end
	if player.Character then
		for _, child in ipairs(player.Character:GetChildren()) do
			if child:IsA("Accessory") or child:IsA("Tool") then
				child:Destroy()
			end
		end
	end
end

-- Función para equipar un modelo 3D
function CharacterAppearanceManager.EquipModel(player, itemData)
	local character = player.Character
	if not character or not itemData.ModelName then return end

	-- Primero, desequipar cualquier ítem que ya esté en ese slot
	CharacterAppearanceManager.UnequipModel(player, itemData.Type)

	local modelTemplate = ItemModelsFolder:FindFirstChild(itemData.ModelName)
	if not modelTemplate then
		warn("No se encontró el modelo 3D:", itemData.ModelName)
		return
	end

	local modelClone = modelTemplate:Clone()

	if modelClone:IsA("Accessory") then
		character:FindFirstChildOfClass("Humanoid"):AddAccessory(modelClone)
		equippedModels[player.UserId][itemData.Type] = modelClone
	elseif modelClone:IsA("Tool") then
		modelClone.Parent = character
		equippedModels[player.UserId][itemData.Type] = modelClone
	end
end

-- Función para desequipar un modelo 3D
function CharacterAppearanceManager.UnequipModel(player, itemType)
	if not equippedModels[player.UserId] or not equippedModels[player.UserId][itemType] then
		return
	end

	local modelToRemove = equippedModels[player.UserId][itemType]
	if modelToRemove and modelToRemove.Parent then
		modelToRemove:Destroy()
	end
	equippedModels[player.UserId][itemType] = nil
end

-- Inicializar la tabla para un nuevo jugador
game.Players.PlayerAdded:Connect(function(player)
	equippedModels[player.UserId] = {}
end)

game.Players.PlayerRemoving:Connect(function(player)
	equippedModels[player.UserId] = nil
end)

return CharacterAppearanceManager