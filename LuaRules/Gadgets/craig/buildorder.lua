-- Author: Tobi Vollebregt

--------------------------------------------------------------------------------
--
--  Convert names to unitDefIDs
--  Must be included after LuaRules/Config/craig/buildorder.lua
--

local function NameToID(name)
	local unitDef = UnitDefNames[name]
	if unitDef then
		return unitDef.id
	else
		error("Bad unitname: " .. name)
	end
end

local function NameArrayToIdArray(array)
	local newArray = {}
	for i,name in ipairs(array) do
		newArray[i] = NameToID(name)
	end
	return newArray
end

local function NameArrayToIdSet(array)
	local newSet = {}
	for i,name in ipairs(array) do
		newSet[NameToID(name)] = true
	end
	return newSet
end

do
	local unitBuildOrderById = {}
	for k,v in pairs(unitBuildOrder) do
		unitBuildOrderById[NameToID(k)] = NameArrayToIdArray(v)
	end
	gadget.unitBuildOrder = unitBuildOrderById
end

gadget.baseBuildOrder = NameArrayToIdArray(baseBuildOrder)
gadget.baseBuilders = NameArrayToIdSet(baseBuilders)
