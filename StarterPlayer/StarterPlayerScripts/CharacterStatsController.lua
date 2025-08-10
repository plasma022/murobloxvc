-- Script del cliente para manejar la UI de asignación de puntos de estadísticas
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService") -- Necesario para los inputs

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local CharacterStatsGui = playerGui:WaitForChild("CharacterStatsGui")
-- Referencias a la UI
local statsGui = playerGui:WaitForChild("CharacterStatsGui")
local statsFrame = statsGui:WaitForChild("StatsFrame")
local openStatsButton = playerGui:WaitForChild("MainHudGui"):WaitForChild("HudFrame"):WaitForChild("OpenStatsButton")



-- Referencias a los TextLabels de valores
local levelText = statsFrame:WaitForChild("LevelText")
local pointsText = statsFrame:WaitForChild("PointsAvailableText")
local strText = statsFrame:WaitForChild("STR_Text")
local agiText = statsFrame:WaitForChild("AGI_Text")
local vitText = statsFrame:WaitForChild("VIT_Text")
local eneText = statsFrame:WaitForChild("ENE_Text")

-- Referencias a los TextLabels de descripciones
local strDesc = statsFrame:WaitForChild("STR_Desc")
local agiDesc = statsFrame:WaitForChild("AGI_Desc")
local vitDesc = statsFrame:WaitForChild("VIT_Desc")
local eneDesc = statsFrame:WaitForChild("ENE_Desc")

-- Referencias a los Botones
local strButton = statsFrame:WaitForChild("STR_Button")
local agiButton = statsFrame:WaitForChild("AGI_Button")
local vitButton = statsFrame:WaitForChild("VIT_Button")
local eneButton = statsFrame:WaitForChild("ENE_Button")

-- Eventos Remotos
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AssignStatPointEvent = RemoteEvents:WaitForChild("AssignStatPoint")
local UpdateClientStatsEvent = RemoteEvents:WaitForChild("UpdateClientStats")

-- Función para actualizar la UI con los datos más recientes (CORREGIDA)
local function updateStatsUI(stats)
	if not stats then return end

	-- Actualizar valores principales
	levelText.Text = "Nivel: " .. tostring(stats.Level or 1)
	pointsText.Text = "Puntos Disponibles: " .. tostring(stats.StatPoints or 0)
	strText.Text = "Fuerza: " .. tostring(stats.STR or 0)
	agiText.Text = "Agilidad: " .. tostring(stats.AGI or 0)
	vitText.Text = "Vitalidad: " .. tostring(stats.VIT or 0)
	eneText.Text = "Energía: " .. tostring(stats.ENE or 0)

	-- Construir las descripciones
	local playerClass = stats.ClassName
	local totalDamage = tostring(stats.TotalDamage or 0)
	local damageType = (playerClass == "Dark Wizard") and "Mágico" or "Físico"

	-- Daño y Velocidad de Ataque ahora van en la descripción de Fuerza
	strDesc.Text = string.format("Daño %s: %s\nVelocidad de Ataque: %s", damageType, totalDamage, tostring(stats.TotalAttackSpeed or 0))

	-- Defensa en Agilidad
	agiDesc.Text = "Defensa Total: " .. tostring(stats.TotalDefense or 0)

	-- Vida en Vitalidad con el nuevo formato
	vitDesc.Text = string.format("Vida Máxima: %d/%d", math.floor(stats.HP or 0), math.floor(stats.MaxHP or 0))

	-- Maná en Energía con el nuevo formato
	eneDesc.Text = string.format("Maná Máximo: %d/%d", math.floor(stats.MP or 0), math.floor(stats.MaxMP or 0))

	-- Mostrar u ocultar los botones "+" si hay puntos disponibles
	local hasPoints = (stats.StatPoints or 0) > 0
	strButton.Visible = hasPoints
	agiButton.Visible = hasPoints
	vitButton.Visible = hasPoints
	eneButton.Visible = hasPoints
end

-- Conectar los botones para que envíen el evento al servidor
strButton.MouseButton1Click:Connect(function() AssignStatPointEvent:FireServer("STR") end)
agiButton.MouseButton1Click:Connect(function() AssignStatPointEvent:FireServer("AGI") end)
vitButton.MouseButton1Click:Connect(function() AssignStatPointEvent:FireServer("VIT") end)
eneButton.MouseButton1Click:Connect(function() AssignStatPointEvent:FireServer("ENE") end)

-- Función para abrir/cerrar la ventana
local function toggleStatsWindow()
	statsFrame.Visible = not statsFrame.Visible
end

-- Conectar el botón del HUD
openStatsButton.MouseButton1Click:Connect(toggleStatsWindow)


-- ¡NUEVO! Conectar la tecla 'C'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C then
		toggleStatsWindow()
	end
end)

-- Suscribirse a las actualizaciones de estadísticas del servidor
UpdateClientStatsEvent.OnClientEvent:Connect(updateStatsUI)

-- Estado inicial
statsFrame.Visible = false
CharacterStatsGui.Enabled = true