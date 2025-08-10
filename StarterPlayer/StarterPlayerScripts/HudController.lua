-- Script del cliente para controlar y actualizar el HUD del jugador (Versión Final Corregida)
-- Ubicación: StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHudGui = playerGui:WaitForChild("MainHudGui")
local hudFrame = mainHudGui:WaitForChild("HudFrame")


-- Referencias a los elementos de la UI
local levelText = hudFrame:WaitForChild("LevelText")
local healthBar = hudFrame:WaitForChild("HealthBar_Background"):WaitForChild("HealthBar_Fill")
local healthText = hudFrame:WaitForChild("HealthBar_Background"):WaitForChild("HealthText")
local manaBar = hudFrame:WaitForChild("ManaBar_Background"):WaitForChild("ManaBar_Fill")
local manaText = hudFrame:WaitForChild("ManaBar_Background"):WaitForChild("ManaText")
local expBar = hudFrame:WaitForChild("ExpBar_Background"):WaitForChild("ExpBar_Fill")
local expText = hudFrame:WaitForChild("ExpBar_Background"):WaitForChild("ExpText")
local zenText = hudFrame:WaitForChild("ZenText")


-- Referencias a los eventos del servidor
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UpdateClientStatsEvent = RemoteEvents:WaitForChild("UpdateClientStats")


-- Función principal para actualizar todo el HUD
local function updateHud(stats)
	if not stats or next(stats) == nil then

		return
	end

	-- CORRECCIÓN: Asegurarse de que el HUD sea visible
	mainHudGui.Enabled = true
	hudFrame.Visible = true

	-- Actualizar Nivel
	levelText.Text = "Nivel: " .. tostring(stats.Level or 1)

	-- Actualizar Barra de Vida
	local currentHP = stats.HP or stats.MaxHP or 100
	local maxHP = stats.MaxHP or 100
	if maxHP == 0 then maxHP = 1 end -- Evitar división por cero
	healthBar:TweenSize(UDim2.new(currentHP / maxHP, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	healthText.Text = string.format("%d / %d", math.floor(currentHP), math.floor(maxHP))

	-- Actualizar Barra de Maná
	local currentMP = stats.MP or stats.MaxMP or 50
	local maxMP = stats.MaxMP or 50
	if maxMP == 0 then maxMP = 1 end -- Evitar división por cero
	manaBar:TweenSize(UDim2.new(currentMP / maxMP, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	manaText.Text = string.format("%d / %d", math.floor(currentMP), math.floor(maxMP))

	-- Actualizar Barra de Experiencia
	local currentEXP = stats.EXP or 0
	local maxEXP = stats.EXPToLevel or 100
	if maxEXP == 0 then maxEXP = 1 end -- Evitar división por cero
	expBar:TweenSize(UDim2.new(currentEXP / maxEXP, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	expText.Text = string.format("EXP: %d / %d", math.floor(currentEXP), math.floor(maxEXP))
	
	-- ¡NUEVO! Actualizar el texto del Zen
	zenText.Text = "Zen: " .. tostring(stats.Zen or 0)
end


-- Conectar la función al evento de actualización de stats
UpdateClientStatsEvent.OnClientEvent:Connect(updateHud)

