-- Módulo que gestiona la creación de drops FÍSICOS en el mundo (Versión con Físicas)
local LootManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local ItemGenerator = require(ServerScriptService.Modules:WaitForChild("ItemGenerator"))
local LootTables = require(ServerScriptService.Modules:WaitForChild("LootTables"))
local DroppedItemTemplate = ReplicatedStorage:WaitForChild("ItemTemplates"):WaitForChild("DroppedItemTemplate")

-- Nueva función para crear un ítem dropeado a partir de datos existentes
function LootManager.CreateDroppedItem(itemData, position)
	if not itemData then return end

	local droppedItem = DroppedItemTemplate:Clone()
	droppedItem.Position = position + Vector3.new(0, 3, 0)
	droppedItem.Anchored = false

	local itemDataString = HttpService:JSONEncode(itemData)
	droppedItem:SetAttribute("ItemData", itemDataString)

	local prompt = droppedItem:WaitForChild("ProximityPrompt")
	prompt.ObjectText = itemData.Name

	droppedItem.Parent = workspace.Zones

	local touchConnection
	touchConnection = droppedItem.Touched:Connect(function(hit)
		if not hit:IsDescendantOf(workspace.Zones) or hit.Name ~= "DroppedItemTemplate" then
			droppedItem.Anchored = true
			touchConnection:Disconnect()
		end
	end)

	game:GetService("Debris"):AddItem(droppedItem, 15)

	print(string.format("Ítem '%s' ha sido tirado al suelo.", itemData.Name))
end

function LootManager.DropLoot(enemyName, position)
	local lootTable = LootTables[enemyName]
	if not lootTable then return end

	for _, lootInfo in ipairs(lootTable) do
		if math.random(1, 100) <= lootInfo.Chance then
			local newItemData = ItemGenerator.Generate(lootInfo.ItemName)
			if newItemData then
				-- 1. Clonar la plantilla del ítem físico
				local droppedItem = DroppedItemTemplate:Clone()
				droppedItem.Position = position + Vector3.new(0, 3, 0) -- Aparece un poco más arriba para que caiga

				-- Asegurarse de que no esté anclado al principio
				droppedItem.Anchored = false

				-- 2. Guardar los datos del ítem como un Atributo
				local itemDataString = HttpService:JSONEncode(newItemData)
				droppedItem:SetAttribute("ItemData", itemDataString)

				-- 3. Actualizar el texto del ProximityPrompt
				local prompt = droppedItem:WaitForChild("ProximityPrompt")
				prompt.ObjectText = newItemData.Name

				-- 4. Poner el ítem en el mundo
				droppedItem.Parent = workspace.Zones

				-- 5. ¡NUEVO! Conectar un evento para anclar el ítem cuando toque algo
				local touchConnection
				touchConnection = droppedItem.Touched:Connect(function(hit)
					-- Una vez que toca algo que no sea otro ítem, se ancla
					if not hit:IsDescendantOf(workspace.Zones) or hit.Name ~= "DroppedItemTemplate" then
						droppedItem.Anchored = true
						-- Desconectar el evento para que no se ejecute más
						touchConnection:Disconnect()
					end
				end)

				-- 6. ¡NUEVO! Hacer que desaparezca después de 15 segundos
				game:GetService("Debris"):AddItem(droppedItem, 15)

				print(string.format("¡%s ha dropeado %s en el suelo!", enemyName, newItemData.Name))
			end
		end
	end
end

return LootManager