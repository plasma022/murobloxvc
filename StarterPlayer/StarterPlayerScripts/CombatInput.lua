-- CombatInput - Versión Final
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerAttackEvent = RemoteEvents:WaitForChild("PlayerAttack")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local target = mouse.Target
		-- Verifica si el objetivo tiene un Humanoid y está dentro de la carpeta Zones
		if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent:IsDescendantOf(workspace.Zones) then
			PlayerAttackEvent:FireServer(target.Parent)
		end
	end
end)