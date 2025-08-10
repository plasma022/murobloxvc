-- Script del cliente para mostrar los números de daño
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ShowDamageIndicator = ReplicatedStorage.RemoteEvents:WaitForChild("ShowDamageIndicator")
local damageTemplate = ReplicatedStorage.UI_Templates:WaitForChild("DamageIndicator")

local DAMAGE_COLORS = {
	Normal = Color3.fromRGB(255, 170, 0), -- Naranja
	Critical = Color3.fromRGB(0, 170, 255), -- Azul
	Excellent = Color3.fromRGB(0, 255, 0), -- Verde Flúor
	Ignore = Color3.fromRGB(0, 255, 255), -- Celeste Flúor
	Double = Color3.fromRGB(255, 255, 255), -- Blanco
}

local function showDamage(target, amount, type)
	if not target or not target:FindFirstChild("Head") then return end

	local indicator = damageTemplate:Clone()
	local label = indicator.DamageText

	label.Text = tostring(math.floor(amount))
	label.TextColor3 = DAMAGE_COLORS[type] or DAMAGE_COLORS.Normal

	indicator.Adornee = target.Head
	indicator.Parent = target.Head

	-- Animación
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {
		Position = UDim2.new(0.5, 0, 0.5, -100), -- Sube
		TextTransparency = 1
	}
	local tween = TweenService:Create(label, tweenInfo, goal)
	tween:Play()

	game:GetService("Debris"):AddItem(indicator, 1.5) -- Autodestrucción
end

ShowDamageIndicator.OnClientEvent:Connect(showDamage)