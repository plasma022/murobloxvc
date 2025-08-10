--[[
	ARCHIVO: VFXController.lua (Versión Final y Completa)
	UBICACIÓN: StarterPlayer/StarterPlayerScripts/VFXController.lua
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Referencias a los recursos
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayVFXEvent = RemoteEvents:WaitForChild("PlayVFXEvent")
local RemoveVFXEvent = RemoteEvents:WaitForChild("RemoveVFXEvent")
local VFX_Folder = ReplicatedStorage:WaitForChild("VFX")
local VFX_Data = require(ReplicatedStorage.Modules:WaitForChild("VFXData"))
local SkillData = require(ReplicatedStorage.Modules:WaitForChild("SkillData"))

-- Tabla para rastrear los efectos de buff activos
local activeBuffVFX = {}

-- Función para eliminar un efecto de buff
local function onRemoveVFX(skillName)
	if activeBuffVFX[skillName] then
		activeBuffVFX[skillName]:Destroy()
		activeBuffVFX[skillName] = nil
	end
end

-- Función que se ejecuta cuando el servidor da la orden de crear un efecto
local function onPlayVFX(skillName, target)
	local vfxInfo = VFX_Data[skillName]
	if not vfxInfo or not target then return end

	local vfxTemplate = VFX_Folder:WaitForChild(vfxInfo.TemplateName, 5)
	if not vfxTemplate then
		warn("No se encontró la plantilla de VFX:", vfxInfo.TemplateName)
		return
	end

	local character = player.Character
	if not character then return end

	local vfxClone = vfxTemplate:Clone()
	if not vfxClone.PrimaryPart then
		warn("ADVERTENCIA: El modelo de efecto '" .. vfxClone.Name .. "' no tiene una PrimaryPart asignada.")
		vfxClone:Destroy()
		return
	end
	vfxClone.Parent = workspace
	local vfxType = vfxInfo.VFXType or "Static"
	-- Activar las partículas para todos los VFX
	for _, descendant in ipairs(vfxClone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
			descendant:Emit(100)
		end
	end

	-- Corrección específica para VFX de skills
	if skillName == "Inner" or (SkillData[skillName] and SkillData[skillName].SkillType == "Buff") then
		local attachPart = character:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = vfxClone.PrimaryPart
		weld.Part1 = attachPart
		weld.Parent = vfxClone.PrimaryPart
		vfxClone.PrimaryPart.Anchored = false
		if activeBuffVFX[skillName] then activeBuffVFX[skillName]:Destroy() end
		activeBuffVFX[skillName] = vfxClone
		return
	elseif skillName == "DeathStab" then
		-- VFX tipo Lunge: viaja del caster al target
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(startPart.CFrame)
		local tweenInfo = TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local goal = { CFrame = endPart.CFrame }
		local tween = TweenService:Create(vfxClone.PrimaryPart, tweenInfo, goal)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)
		return
	elseif skillName == "Cyclone" then
		-- VFX estático en el target
		local attachPart = target:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		Debris:AddItem(vfxClone, vfxInfo.Duration)
		return
	elseif skillName == "TwistingSlash" then
		-- VFX se muestra en el caster y se destruye tras 0.4 segundos
		local attachPart = character:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		Debris:AddItem(vfxClone, 0.4)
		return
	end

	-- Lógica de posicionamiento y animación
	if vfxType == "Projectile" then
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end

		vfxClone:SetPrimaryPartCFrame(startPart.CFrame)

		local tweenInfo = TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Linear)
		local goal = { CFrame = endPart.CFrame }
		local tween = TweenService:Create(vfxClone.PrimaryPart, tweenInfo, goal)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)

	elseif vfxType == "FallingArea" then
		local targetPart = target:FindFirstChild("HumanoidRootPart")
		if not targetPart then vfxClone:Destroy(); return end

	local vfxType = vfxInfo.VFXType or "Static"

	-- Lógica de posicionamiento y animación
	if skillName == "Inner" then
		-- El VFX de Inner se weldéa al jugador y nunca se ancla
		local attachPart = character:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = vfxClone.PrimaryPart
		weld.Part1 = attachPart
		weld.Parent = vfxClone.PrimaryPart
		vfxClone.PrimaryPart.Anchored = false
		if activeBuffVFX[skillName] then activeBuffVFX[skillName]:Destroy() end
		activeBuffVFX[skillName] = vfxClone
	elseif vfxType == "Projectile" then
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(startPart.CFrame)
		local tweenInfo = TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Linear)
		local goal = { CFrame = endPart.CFrame }
		local tween = TweenService:Create(vfxClone.PrimaryPart, tweenInfo, goal)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)
	elseif vfxType == "FallingArea" then
		local targetPart = target:FindFirstChild("HumanoidRootPart")
		if not targetPart then vfxClone:Destroy(); return end
		local targetPosition = targetPart.Position
		local skyEmitterPart = Instance.new("Part")
		skyEmitterPart.Size = Vector3.new(6, 2, 6)
		skyEmitterPart.CFrame = CFrame.new(targetPosition) * CFrame.new(0, 10, 0)
		skyEmitterPart.Anchored = true
		skyEmitterPart.Transparency = 1
		skyEmitterPart.Parent = workspace
		local fallingShardsTemplate = vfxClone.PrimaryPart:FindFirstChild("FallingShards")
		if fallingShardsTemplate then
			local fallingShards = fallingShardsTemplate:Clone()
			fallingShards.Parent = skyEmitterPart
			fallingShards.Enabled = true
		end
		task.delay(vfxInfo.FallDuration or 0.7, function()
			local groundEffect = vfxClone.PrimaryPart
			groundEffect.Position = Vector3.new(targetPosition.X, 0.5, targetPosition.Z)
			groundEffect.Anchored = true
			local redundantShards = groundEffect:FindFirstChild("FallingShards")
			if redundantShards then redundantShards:Destroy() end
			local groundMist = groundEffect:FindFirstChild("GroundMist")
			if groundMist then groundMist.Enabled = true end
			Debris:AddItem(vfxClone, vfxInfo.Duration)
		end)
		Debris:AddItem(skyEmitterPart, (vfxInfo.FallDuration or 0.7) + 0.5)
	elseif vfxType == "Lunge" then
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end
		local mainPart = vfxClone.PrimaryPart
		mainPart.CanCollide = false
		local startPos = startPart.Position
		local endPos = endPart.Position
		local distance = (endPos - startPos).Magnitude
		mainPart.CFrame = CFrame.new(startPos:Lerp(endPos, 0.5), endPos)
		local tweenInfo = TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		mainPart.Size = Vector3.new(4, 4, 0.1)
		mainPart.Transparency = 0.3
		local goal = {
			Size = Vector3.new(1, 1, distance),
			Transparency = 1
		}
		local tween = TweenService:Create(mainPart, tweenInfo, goal)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)
	else
		-- Efectos estáticos y buffs
		local attachPart = nil
		if vfxInfo.AttachTo == "Caster" then
			attachPart = character:FindFirstChild("HumanoidRootPart")
		elseif vfxInfo.AttachTo == "Target" then
			attachPart = target:FindFirstChild("HumanoidRootPart")
		end
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = vfxClone.PrimaryPart
		weld.Part1 = attachPart
		weld.Parent = vfxClone.PrimaryPart
		if SkillData[skillName] and SkillData[skillName].SkillType == "Buff" then
			if activeBuffVFX[skillName] then activeBuffVFX[skillName]:Destroy() end
			activeBuffVFX[skillName] = vfxClone
		else
			Debris:AddItem(vfxClone, vfxInfo.Duration)
		end
	end
		activeBuffVFX[skillName] = nil
	end
end

-- Conectar los eventos
PlayVFXEvent.OnClientEvent:Connect(onPlayVFX)
RemoveVFXEvent.OnClientEvent:Connect(onRemoveVFX)
