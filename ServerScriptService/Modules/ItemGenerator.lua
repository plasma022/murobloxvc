-- Módulo responsable de crear instancias de ítems con propiedades aleatorias (Versión Mejorada)
local ItemGenerator = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ItemData = require(ReplicatedStorage:WaitForChild("ItemData"))

-- ¡NUEVA FUNCIÓN! Busca un ítem por su nombre en la base de datos anidada
local function findItemBaseData(itemName)
	for className, classData in pairs(ItemData) do
		-- Buscar en la lista de armas de la clase
		if classData.Weapons then
			for _, weaponData in ipairs(classData.Weapons) do
				if weaponData.Name == itemName then
					return weaponData
				end
			end
		end
		-- Buscar en la lista de sets de la clase
		if classData.Sets then
			for setName, setData in pairs(classData.Sets) do
				for pieceName, pieceData in pairs(setData) do
					if pieceData.Name == itemName then
						return pieceData
					end
				end
			end
		end
	end
	return nil -- No se encontró el ítem
end

function ItemGenerator.Generate(itemName)
	-- 1. Validar que el ítem exista usando la nueva función de búsqueda
	local baseData = findItemBaseData(itemName)
	if not baseData then
		warn("Intento de generar un ítem que no existe:", itemName)
		return nil
	end

	-- 2. Crear una copia profunda de los datos base
	local newItem = {}
	for key, value in pairs(baseData) do
		if type(value) == "table" then
			newItem[key] = {}
			for k, v in pairs(value) do
				newItem[key][k] = v
			end
		else
			newItem[key] = value
		end
	end

	newItem.UniqueID = HttpService:GenerateGUID(false)

	-- 3. Añadir propiedades aleatorias
	newItem.Level = math.random(0, 3)
	newItem.Durability = math.random(20, 40) + (newItem.Level * 5)
	if math.random(1, 100) <= 100 then -- 10% de probabilidad de Suerte
		newItem.Luck = true
	else
		newItem.Luck = false
	end
	newItem.ExcellentOptions = {}

	-- 4. Ajustar stats según el nivel (si corresponde)
	if newItem.MinDmg then -- Para armas
		newItem.MinDmg = newItem.MinDmg + (newItem.Level * 2)
		newItem.MaxDmg = newItem.MaxDmg + (newItem.Level * 2)
	elseif newItem.Defense then -- Para piezas de set
		newItem.Defense = newItem.Defense + newItem.Level
	end

	return newItem
end

return ItemGenerator