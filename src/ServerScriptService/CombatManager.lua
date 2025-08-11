--[[
	ARCHIVO: CombatManager.lua (Versión Final y Completa de la Fase 1)
	UBICACIÓN: ServerScriptService/CombatManager.lua
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Cargar Módulos
local StatFormulas = require(ServerScriptService.Modules:WaitForChild("StatFormulas"))
local InventoryManager = require(ServerScriptService.Modules:WaitForChild("InventoryManager"))
local SkillData = require(ReplicatedStorage.Modules:WaitForChild("SkillData"))
local VFXData = require(ReplicatedStorage.Modules:WaitForChild("VFXData"))

-- Cargar Eventos Remotos
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerAttackEvent = RemoteEvents:WaitForChild("PlayerAttack")
local UseSkillEvent = RemoteEvents:WaitForChild("UseSkillEvent")
local ShowDamageIndicator = RemoteEvents:WaitForChild("ShowDamageIndicator")
local PlayVFXEvent = RemoteEvents:WaitForChild("PlayVFXEvent")
local RemoveVFXEvent = RemoteEvents:WaitForChild("RemoveVFXEvent")
local SkillConfirmEvent = RemoteEvents:FindFirstChild("SkillConfirmEvent") or Instance.new("RemoteEvent", RemoteEvents)
SkillConfirmEvent.Name = "SkillConfirmEvent"
SkillConfirmEvent.Parent = RemoteEvents

-- Tablas para gestionar cooldowns

local lastAttackTimes = {}
local lastSkillTimes = {}
local MELEE_RANGE = 12

-- Variable global para buffs activos
-- Variable global para buffs activos (compatible con Roblox Studio)
if not _G.activeBuffs then _G.activeBuffs = {} end
activeBuffs = _G.activeBuffs

-- Función auxiliar para dañar y "tagear" a un enemigo
local function damageAndTag(player, enemyModel, damageAmount, damageType)
	local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	local damageApplied = false
	if humanoid and humanoid.Health > 0 then
		local attackerTag = enemyModel:FindFirstChild("AttackerTag") or Instance.new("ObjectValue")
		attackerTag.Name = "AttackerTag"; attackerTag.Value = player; attackerTag.Parent = enemyModel
		humanoid:TakeDamage(damageAmount)
		damageApplied = true
	elseif enemyModel.PrimaryPart then
		-- Modelo personalizado sin Humanoid: aplicar daño simulado y mostrar número
		local attackerTag = enemyModel:FindFirstChild("AttackerTag") or Instance.new("ObjectValue")
		attackerTag.Name = "AttackerTag"; attackerTag.Value = player; attackerTag.Parent = enemyModel
		-- Aquí puedes agregar lógica para reducir vida personalizada si tienes un sistema propio
		damageApplied = true
	end
	if damageApplied then
		-- Mostrar el número de daño en Head, PrimaryPart, o el propio modelo si no existen
		local indicatorTarget = enemyModel:FindFirstChild("Head") or enemyModel.PrimaryPart or enemyModel
		ShowDamageIndicator:FireAllClients(indicatorTarget, damageAmount, damageType or "Normal")
	end
end

-- Función para el ataque básico con clic izquierdo
local function onPlayerAttack(player, targetEnemy)
	if not player.Character or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then return end

	local cooldown = StatFormulas:GetAttackCooldown(player)
	local lastAttack = lastAttackTimes[player.UserId] or 0
	if tick() - lastAttack < cooldown then return end

	if not targetEnemy or not targetEnemy:IsA("Model") then return end
	local enemyRoot = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy.PrimaryPart
	local playerRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
	if not enemyRoot or not playerRoot then return end
	if (playerRoot.Position - enemyRoot.Position).Magnitude > MELEE_RANGE then return end

	lastAttackTimes[player.UserId] = tick()

	-- ¡CORRECCIÓN! Fuerza la recalculación de stats antes de calcular el daño
	StatFormulas:RecalculateDerivedStats(player)
	local damage = StatFormulas:CalculateDamage(player)

	if damage > 0 then
		damageAndTag(player, targetEnemy, damage, "Normal")
	end
end
-- Función para usar una habilidad
local function onUseSkill(player, skillName, targetEnemy)
	if not player.Character or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then return end

	local skillInfo = SkillData[skillName]
	local playerStats = StatFormulas:GetStats(player)
	if not skillInfo or playerStats.ClassName ~= skillInfo.ClassName then return end

	if skillInfo.Targeting == "Targeted" and not targetEnemy then return end

	local baseCooldown = skillInfo.Cooldown
	local finalCooldown = baseCooldown / (1 + (playerStats.TotalAttackSpeed or 0) * 0.05)
	finalCooldown = math.max(finalCooldown, 0.2)

	local lastSkill = (lastSkillTimes[player.UserId] and lastSkillTimes[player.UserId][skillName]) or 0
	if tick() - lastSkill < finalCooldown then return end

	if playerStats.MP < skillInfo.ManaCost then return end

	if not lastSkillTimes[player.UserId] then lastSkillTimes[player.UserId] = {} end
	lastSkillTimes[player.UserId][skillName] = tick()
	StatFormulas:ModifyStat(player, "MP", playerStats.MP - skillInfo.ManaCost)

	local skillType = skillInfo.SkillType
	-- Refuerzo: El buff Inner solo modifica MaxHP, nunca bloquea daño ni targeting
	-- Si el buff está activo, no afecta el casteo ni el daño de Twisting Slash ni de otras skills

	if skillType == "Buff" then
		-- Confirmar skill al cliente para animación
		SkillConfirmEvent:FireClient(player, skillName)
		-- Lógica de aplicación de buffs
		if not activeBuffs[player.UserId] then activeBuffs[player.UserId] = {} end
		local effect = skillInfo.Effect
		local buffName = skillName .. "_Buff"
		local duration = skillInfo.Duration or 60
		local stats = StatFormulas:GetStats(player)
		local buffData = nil
		if effect then
			if effect.Type == "MaxHP" then
				local percent = effect.BasePercent or 10
				if effect.VitalityForMax and effect.MaxPercent and stats.VIT then
					if type(effect.VitalityForMax) == "number" and type(effect.MaxPercent) == "number" and type(stats.VIT) == "number" then
						local extra = (stats.VIT / effect.VitalityForMax) * effect.MaxPercent
						percent = math.clamp(percent + extra, percent, effect.MaxPercent)
					end
				end
				local hpBuff = math.floor((stats.MaxHP or 0) * (percent / 100))
				buffData = {Expires = tick() + duration, Effect = {Type = "MaxHP", Value = hpBuff}}
			elseif effect.Type == "Absorption" then
				local percent = effect.BasePercent or 10
				if effect.EnergyForMax and effect.MaxPercent and stats.ENE then
					if type(effect.EnergyForMax) == "number" and type(effect.MaxPercent) == "number" and type(stats.ENE) == "number" then
						local extra = (stats.ENE / effect.EnergyForMax) * effect.MaxPercent
						percent = math.clamp(percent + extra, percent, effect.MaxPercent)
					end
				end
				buffData = {Expires = tick() + duration, Effect = {Type = "Absorption", Value = percent}}
			elseif effect.Type == "Damage" then
				local percent = effect.BasePercent or 20
				if effect.EnergyScale and stats.ENE and type(effect.EnergyScale) == "number" and type(stats.ENE) == "number" then
					percent = percent + (stats.ENE * effect.EnergyScale)
				end
				local dmgBuff = math.floor((StatFormulas:CalculateDamage(player) or 0) * (percent / 100))
				buffData = {Expires = tick() + duration, Effect = {Type = "Damage", Value = dmgBuff}}
			elseif effect.Type == "Defense" then
				local value = effect.BaseValue or 30
				if effect.EnergyScale and stats.ENE and type(effect.EnergyScale) == "number" and type(stats.ENE) == "number" then
					value = value + math.floor(stats.ENE * effect.EnergyScale)
				end
				if effect.MaxValue and type(effect.MaxValue) == "number" then value = math.min(value, effect.MaxValue) end
				buffData = {Expires = tick() + duration, Effect = {Type = "Defense", Value = value}}
			end
		end
		if buffData then
			-- Si ya existe el buff, primero lo removemos
			if activeBuffs[player.UserId][buffName] then
				local prevBuff = activeBuffs[player.UserId][buffName]
				if prevBuff.Effect and prevBuff.Effect.Type == "MaxHP" then
					local stats = StatFormulas:GetStats(player)
					StatFormulas:ModifyStat(player, "MaxHP", math.max((stats.MaxHP or 0) - prevBuff.Effect.Value, 1))
				end
				activeBuffs[player.UserId][buffName] = nil
			end
			activeBuffs[player.UserId][buffName] = buffData
			-- Aplicar el buff de MaxHP directamente si corresponde
			if buffData.Effect and buffData.Effect.Type == "MaxHP" then
				StatFormulas:ModifyStat(player, "MaxHP", (StatFormulas:GetStats(player).MaxHP or 0) + buffData.Effect.Value)
				-- Expiración automática del buff y remoción del VFX
				task.delay(buffData.Expires - tick(), function()
					if activeBuffs[player.UserId] and activeBuffs[player.UserId][buffName] == buffData then
						local stats = StatFormulas:GetStats(player)
						StatFormulas:ModifyStat(player, "MaxHP", math.max((stats.MaxHP or 0) - buffData.Effect.Value, 1))
						activeBuffs[player.UserId][buffName] = nil
						StatFormulas:RecalculateDerivedStats(player)
						if RemoteEvents:FindFirstChild("UpdateClientStatsEvent") then
							local stats = StatFormulas:GetStats(player)
							RemoteEvents.UpdateClientStatsEvent:FireClient(player, stats)
						end
						-- Remover el VFX de Inner
						if RemoteEvents:FindFirstChild("RemoveVFXEvent") then
							RemoteEvents.RemoveVFXEvent:FireClient(player, "Inner")
						end
					end
				end)
			end
			-- Fuerza la recalculación de stats y daño tras aplicar cualquier buff
			StatFormulas:RecalculateDerivedStats(player)
			if RemoteEvents:FindFirstChild("UpdateClientStatsEvent") then
				local stats = StatFormulas:GetStats(player)
				RemoteEvents.UpdateClientStatsEvent:FireClient(player, stats)
			end
		end

	else -- Todas las habilidades de daño
		-- Confirmar skill al cliente para animación
		SkillConfirmEvent:FireClient(player, skillName)
		-- ¡CORRECCIÓN! Fuerza la recalculación de stats antes de calcular el daño
		StatFormulas:RecalculateDerivedStats(player)
		local damage = StatFormulas:CalculateDamage(player) * (skillInfo.DamageMultiplier or 1)

		if skillType == "SingleTargetMelee" and targetEnemy then
			-- Daño instantáneo si está en rango
			local enemyRoot = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy.PrimaryPart
			local playerRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
			if enemyRoot and playerRoot and (playerRoot.Position - enemyRoot.Position).Magnitude <= (skillInfo.Range or MELEE_RANGE) then
				damageAndTag(player, targetEnemy, damage, "Normal")
			end
		elseif (skillType == "SingleTargetRanged" or skillType == "Projectile" or skillType == "RangedCone") and targetEnemy then
			-- Daño solo cuando el VFX llegue (task.delay)
			local vfxInfo = VFXData[skillName]
			local travelTime = (vfxInfo and vfxInfo.Duration) or 0
			task.delay(travelTime, function()
				if targetEnemy and targetEnemy.Parent then
					local isValid = false
					if targetEnemy:FindFirstChildOfClass("Humanoid") and targetEnemy.Humanoid.Health > 0 then
						isValid = true
					elseif targetEnemy.PrimaryPart then
						isValid = true
					end
					if isValid then
						damageAndTag(player, targetEnemy, damage, "Normal")
					end
				end
			end)

		elseif (skillType == "MeleeAoE" or skillType == "CircularArea") then
			-- Daño en área: solo se aplica al inicio, nunca tras el delay
			local character = player.Character
			if not character then return end
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end
			local range = skillInfo.Range or 10
			StatFormulas:RecalculateDerivedStats(player)
			local areaDamage = StatFormulas:CalculateDamage(player) * (skillInfo.DamageMultiplier or 1)
			for _, enemy in ipairs(workspace.Zones:GetDescendants()) do
				if enemy:IsA("Model") then
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
					local isValid = false
					if enemy:FindFirstChildOfClass("Humanoid") and enemy.Humanoid.Health > 0 and enemyRoot then
						isValid = true
					elseif enemy.PrimaryPart then
						isValid = true
					end
					if isValid and enemyRoot and (enemyRoot.Position - rootPart.Position).Magnitude <= range then
						damageAndTag(player, enemy, areaDamage, "Normal")
					end
				end
			end
		end
	end

		if VFXData[skillName] then
			-- DeathStab: VFX tipo Lunge, sincroniza daño y VFX
			if skillName == "DeathStab" and targetEnemy then
				PlayVFXEvent:FireClient(player, skillName, targetEnemy)
				local vfxInfo = VFXData[skillName]
				local travelTime = (vfxInfo and vfxInfo.Duration) or 0.4
				task.delay(travelTime, function()
					if targetEnemy and targetEnemy.Parent then
						local isValid = false
						if targetEnemy:FindFirstChildOfClass("Humanoid") and targetEnemy.Humanoid.Health > 0 then
							isValid = true
						elseif targetEnemy.PrimaryPart then
							isValid = true
						end
						if isValid then
							damageAndTag(player, targetEnemy, StatFormulas:CalculateDamage(player) * (skillInfo.DamageMultiplier or 1), "Normal")
						end
					end
				end)
			elseif skillName == "Cyclone" and targetEnemy then
				PlayVFXEvent:FireClient(player, skillName, targetEnemy)
				-- Solo VFX, el daño ya se aplicó en el bloque principal
			elseif skillName == "TwistingSlash" then
				PlayVFXEvent:FireClient(player, skillName, player.Character)
				-- Solo VFX, el daño ya se aplicó en el bloque principal
			else
				PlayVFXEvent:FireClient(player, skillName, targetEnemy or player.Character)
			end
	end
end

-- Conectar eventos
PlayerAttackEvent.OnServerEvent:Connect(onPlayerAttack)
UseSkillEvent.OnServerEvent:Connect(onUseSkill)

-- Actualizar HUD al ingresar el jugador
game.Players.PlayerAdded:Connect(function(player)
	-- Inicializar stats si no existen
	local stats = StatFormulas:GetStats(player)
	if not stats or not stats.HP then
		local className = "DarkKnight"
		if player:FindFirstChild("ClassName") then
			className = player.ClassName.Value
		end
		StatFormulas:InitStats(player, className)
		stats = StatFormulas:GetStats(player)
	end
	StatFormulas:RecalculateDerivedStats(player)
	-- Enviar stats completos al HUD
	if RemoteEvents:FindFirstChild("UpdateClientStatsEvent") then
		RemoteEvents.UpdateClientStatsEvent:FireClient(player, stats)
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	lastAttackTimes[player.UserId] = nil
	lastSkillTimes[player.UserId] = nil
end)
