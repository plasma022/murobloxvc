--[[
	ARCHIVO: VFXController.lua (Versión Final Corregida)
	UBICACIÓN: StarterPlayer/StarterPlayerScripts/VFXController.lua
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Referencias
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayVFXEvent = RemoteEvents:WaitForChild("PlayVFXEvent")
local RemoveVFXEvent = RemoteEvents:WaitForChild("RemoveVFXEvent")
local VFX_Folder = ReplicatedStorage:WaitForChild("VFX")
local VFX_Data = require(ReplicatedStorage.Modules:WaitForChild("VFXData"))
local SkillData = require(ReplicatedStorage.Modules:WaitForChild("SkillData"))

-- Buffs activos
local activeBuffVFX = {}

-- Remover un VFX de buff
local function onRemoveVFX(skillName)
	if activeBuffVFX[skillName] then
		if activeBuffVFX[skillName].Parent then
			activeBuffVFX[skillName]:Destroy()
		end
		activeBuffVFX[skillName] = nil
	end
end

-- Ejecutar VFX
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
		warn("ADVERTENCIA: El modelo de efecto '" .. vfxClone.Name .. "' no tiene PrimaryPart asignada.")
		vfxClone:Destroy()
		return
	end
	vfxClone.Parent = workspace

	-- Activar partículas
	for _, descendant in ipairs(vfxClone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
			descendant:Emit(100)
		end
	end

	local vfxType = vfxInfo.VFXType or "Static"

	-- Buffs
	if skillName == "Inner" or (SkillData[skillName] and SkillData[skillName].SkillType == "Buff") then
		local attachPart = character:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = vfxClone.PrimaryPart
		weld.Part1 = attachPart
		weld.Parent = vfxClone.PrimaryPart
		vfxClone.PrimaryPart.Anchored = false
		if activeBuffVFX[skillName] then
			if activeBuffVFX[skillName].Parent then activeBuffVFX[skillName]:Destroy() end
			activeBuffVFX[skillName] = nil
		end
		activeBuffVFX[skillName] = vfxClone
		return
	end

	-- DeathStab (Lunge)
	if skillName == "DeathStab" then
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(startPart.CFrame)
		local tween = TweenService:Create(
			vfxClone.PrimaryPart,
			TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ CFrame = endPart.CFrame }
		)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)
		return
	end

	-- Cyclone
	if skillName == "Cyclone" then
		local attachPart = target:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		Debris:AddItem(vfxClone, vfxInfo.Duration)
		return
	end

	-- TwistingSlash
	if skillName == "TwistingSlash" then
		local attachPart = character:FindFirstChild("HumanoidRootPart")
		if not attachPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(attachPart.CFrame)
		Debris:AddItem(vfxClone, 0.4)
		return
	end

	-- Projectile
	if vfxType == "Projectile" then
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end
		vfxClone:SetPrimaryPartCFrame(startPart.CFrame)
		local tween = TweenService:Create(
			vfxClone.PrimaryPart,
			TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Linear),
			{ CFrame = endPart.CFrame }
		)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)
		return
	end

	-- FallingArea
	if vfxType == "FallingArea" then
		local targetPart = target:FindFirstChild("HumanoidRootPart")
		if not targetPart then vfxClone:Destroy(); return end
		local targetPosition = targetPart.Position

		-- Emitir desde el cielo
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
		return
	end

	-- Lunge
	if vfxType == "Lunge" then
		local startPart = character:FindFirstChild("HumanoidRootPart")
		local endPart = target:FindFirstChild("HumanoidRootPart")
		if not startPart or not endPart then vfxClone:Destroy(); return end
		local mainPart = vfxClone.PrimaryPart
		mainPart.CanCollide = false
		local startPos = startPart.Position
		local endPos = endPart.Position
		local distance = (endPos - startPos).Magnitude
		mainPart.CFrame = CFrame.new(startPos:Lerp(endPos, 0.5), endPos)
		local tween = TweenService:Create(
			mainPart,
			TweenInfo.new(vfxInfo.Duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = Vector3.new(1, 1, distance), Transparency = 1 }
		)
		tween:Play()
		Debris:AddItem(vfxClone, vfxInfo.Duration)
		return
	end

	-- Efectos estáticos
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

-- Conectar eventos
PlayVFXEvent.OnClientEvent:Connect(onPlayVFX)
RemoveVFXEvent.OnClientEvent:Connect(onRemoveVFX)
