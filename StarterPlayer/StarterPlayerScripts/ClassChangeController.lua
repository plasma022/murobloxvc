print("[ClassChangeController] Script iniciado y listo para escuchar el chat.")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ChangeClassEvent = RemoteEvents:WaitForChild("ChangeClassEvent")

player.Chatted:Connect(function(message)
	local args = message:split(" ")
	local command = args[1]:lower()

	if command == "/changeclass" then
		local className = args[2]
		if className then
			warn("[DEBUG] Comando de cambio de clase detectado. Enviando al servidor:", className)
			ChangeClassEvent:FireServer(className)
		else
			print("Comando inválido. Uso: /changeclass <NombreDeLaClase>")
		end
	end
end)
