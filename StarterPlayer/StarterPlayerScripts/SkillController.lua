--[[
	ARCHIVO: SkillController.lua (Versión Final y Completa)
	UBICACIÓN: StarterPlayer/StarterPlayerScripts/SkillController.lua
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Referencias a los Eventos
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UseSkillEvent = RemoteEvents:WaitForChild("UseSkillEvent")
local SkillConfirmEvent = RemoteEvents:WaitForChild("SkillConfirmEvent")
local SkillData = require(ReplicatedStorage.Modules:WaitForChild("SkillData"))
local PlayerAttackEvent = RemoteEvents:WaitForChild("PlayerAttack")

-- Referencias a la UI
local playerGui = player:WaitForChild("PlayerGui")
local skillBarFrame = playerGui:WaitForChild("SkillBarGui"):WaitForChild("SkillBarFrame")

-- Eventos para comunicar con CharacterAnimationHandler
local activeSkillChangedEvent = Instance.new("BindableEvent")
activeSkillChangedEvent.Name = "ActiveSkillChanged"
activeSkillChangedEvent.Parent = script

local playAnimationEvent = Instance.new("BindableEvent")
playAnimationEvent.Name = "PlayAnimationEvent"
playAnimationEvent.Parent = script

-- Variables de estado
local animationHandler = nil
local playerSkills = {}
local activeSkillName = nil
local isRightMouseDown = false
local canAttack = true
local canUseSkill = true

-- Conectar al personaje cuando aparezca para obtener el manejador de animación
player.CharacterAdded:Connect(function(char)
	local handlerScript = char:WaitForChild("CharacterAnimationHandler")
	animationHandler = require(handlerScript)
end)

-- Si el personaje ya existe, obtener el manejador
if player.Character then
	local handlerScript = player.Character:WaitForChild("CharacterAnimationHandler")
	animationHandler = require(handlerScript)
end

-- Función para actualizar el efecto visual de la habilidad activa
local function updateActiveSkillVisuals()
	for _, skill in ipairs(playerSkills) do
		local stroke = skill.button:FindFirstChildOfClass("UIStroke")
		if stroke then
			if skill.name == activeSkillName then
				stroke.Enabled = true
				stroke.Thickness = 2
				stroke.Color = Color3.fromRGB(255, 255, 0)
			else
				stroke.Enabled = false
				stroke.Thickness = 0
			end
		end
	end
end

-- Función para actualizar la barra de habilidades
local function updateSkillBar()
	local playerClass = player:GetAttribute("ClassName")
	if not playerClass then return end

	table.clear(playerSkills)
	local skillIndex = 1

	for skillName, skillInfo in pairs(SkillData) do
		if skillInfo.ClassName == playerClass and skillIndex <= 4 then
			local slot = skillBarFrame:FindFirstChild("SkillSlot" .. skillIndex)
			if slot then
				slot.Image = skillInfo.ImageId
				local skillNameValue = slot:FindFirstChild("SkillName") or Instance.new("StringValue")
				skillNameValue.Name = "SkillName"
				skillNameValue.Value = skillName
				skillNameValue.Parent = slot

				table.insert(playerSkills, {button = slot, name = skillName})
				skillIndex = skillIndex + 1
			end
		end
	end

	if #playerSkills > 0 then
		activeSkillName = playerSkills[1].name
		updateActiveSkillVisuals()
		activeSkillChangedEvent:Fire(activeSkillName)
	end
end

-- Bucle de casteo continuo
-- El casteo y animación ahora se sincronizan con la confirmación del servidor
local function onSkillConfirmed(skillName)
	local skillInfo = SkillData[skillName]
	if not skillInfo then 
		canAttack = true 
		return 
	end
	if animationHandler then
		animationHandler:PlayAnimation(skillName)
	end
	-- Solo los buffs permiten casteo inmediato
	if skillInfo.SkillType == "Buff" then
		canAttack = true
	else
		canAttack = false
		task.wait(skillInfo.Cooldown or 2)
		canAttack = true
	end
end

SkillConfirmEvent.OnClientEvent:Connect(onSkillConfirmed)

task.spawn(function()
	while true do
		if isRightMouseDown and activeSkillName and canAttack then
			local skillInfo = SkillData[activeSkillName]
			if skillInfo then
				local target = mouse.Target
				local targetModel = nil
				if target and target.Parent and target.Parent:IsA("Model") then
					if target.Parent:FindFirstChild("Humanoid") then
						targetModel = target.Parent
					elseif target.Parent.PrimaryPart then
						targetModel = target.Parent
					end
				end
				UseSkillEvent:FireServer(activeSkillName, targetModel)
				-- Esperar confirmación del servidor para animación y cooldown
			end
		end
		task.wait(0.05)
	end
end)

-- Manejadores de Input
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end

	-- Clic Izquierdo para Ataque Básico
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local target = mouse.Target
		if target and target:IsA("Model") and (target:FindFirstChild("Humanoid") or target.PrimaryPart) then
			PlayerAttackEvent:FireServer(target)
		elseif target and target.Parent and target.Parent:IsA("Model") and (target.Parent:FindFirstChild("Humanoid") or target.Parent.PrimaryPart) then
			PlayerAttackEvent:FireServer(target.Parent)
		end
	end
	-- Clic Derecho para Habilidades
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = true
		-- Ahora la animación y cooldown se manejan solo con la confirmación del servidor
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = true
	end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		local key = input.KeyCode
		local skillIndex = 0

		if key == Enum.KeyCode.One then skillIndex = 1
		elseif key == Enum.KeyCode.Two then skillIndex = 2
		elseif key == Enum.KeyCode.Three then skillIndex = 3
		elseif key == Enum.KeyCode.Four then skillIndex = 4
		end

		if skillIndex > 0 and playerSkills[skillIndex] then
			activeSkillName = playerSkills[skillIndex].name
			updateActiveSkillVisuals()
			activeSkillChangedEvent:Fire(activeSkillName)
		end
	end
end

local function onInputEnded(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = false
	end
end

-- Conectar los manejadores de input
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

-- Inicialización y conexión a cambios de clase
player:GetAttributeChangedSignal("ClassName"):Connect(updateSkillBar)
if player:GetAttribute("ClassName") then
	updateSkillBar()
else
	local connection
	connection = player.AttributeChanged:Connect(function(attribute)
		if attribute == "ClassName" then
			updateSkillBar()
			connection:Disconnect()
		end
	end)
end