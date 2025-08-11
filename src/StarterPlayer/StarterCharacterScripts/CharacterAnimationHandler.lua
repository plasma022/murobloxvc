
local CharacterAnimationHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ExecuteSkillEvent = RemoteEvents:WaitForChild("ExecuteSkill")

-- Cargar las animaciones
local attackAnims = {
	["DeathStab"] = animator:LoadAnimation(script:WaitForChild("DeathStabAnim")),
	["Cyclone"] = animator:LoadAnimation(script:WaitForChild("CycloneAnim")),
}

-- Conectar los eventos de animación
for skillName, animTrack in pairs(attackAnims) do
	animTrack:GetMarkerReachedSignal("PlaySkillVFX"):Connect(function()
		local mouse = player:GetMouse()
		local target = mouse.Target
		local targetModel = target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent

		ExecuteSkillEvent:FireServer(skillName, targetModel)
	end)
end

-- Función que el SkillController llamará para reproducir una animación
function CharacterAnimationHandler:PlayAnimation(skillName)
	if attackAnims[skillName] and not attackAnims[skillName].IsPlaying then
		attackAnims[skillName]:Play()
	end
end

return CharacterAnimationHandler