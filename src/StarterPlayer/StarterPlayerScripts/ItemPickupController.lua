-- Script del cliente que maneja la recogida de ítems
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local PickupItemEvent = ReplicatedStorage.RemoteEvents:WaitForChild("PickupItem")

-- Esta función se conectará a CUALQUIER ProximityPrompt que aparezca en el juego
local function onPromptTriggered(prompt, player)
	-- Nos aseguramos de que sea un prompt de un ítem dropeado
	local itemModel = prompt.Parent
	if itemModel:GetAttribute("ItemData") then
		print("Cliente intentando recoger ítem:", itemModel:GetAttribute("ItemData"))
		-- Deshabilitar el prompt para evitar doble clic
		prompt.Enabled = false
		-- Avisar al servidor que queremos recoger este objeto
		PickupItemEvent:FireServer(itemModel)
	end
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
