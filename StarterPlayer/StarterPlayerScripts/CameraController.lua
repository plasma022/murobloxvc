-- Script del cliente para manejar el bloqueo de la cámara
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local cameraLocked = false

-- Función para cambiar el modo de la cámara
local function toggleCameraLock()
	cameraLocked = not cameraLocked

	if cameraLocked then
		-- Cámara bloqueada detrás del personaje (clásico de ARPG)
		camera.CameraType = Enum.CameraType.Custom
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	else
		-- Cámara libre controlada por el jugador
		camera.CameraType = Enum.CameraType.Custom
		player.CameraMode = Enum.CameraMode.Classic
	end
end

-- Conectar la tecla 'X'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.X then
		toggleCameraLock()
	end
end)

-- Establecer el estado inicial de la cámara
player.CameraMode = Enum.CameraMode.Classic
