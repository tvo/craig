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
	for k,v in pairs(gadget.unitBuildOrder) do
		unitBuildOrderById[NameToID(k)] = NameArrayToIdArray(v)
	end
	gadget.unitBuildOrder = unitBuildOrderById
end

do
	local baseBuildOrderById = {}
	for k,v in pairs(gadget.baseBuildOrder) do
		-- don't translate key here, it's the side
		baseBuildOrderById[k] = NameArrayToIdArray(v)
	end
	gadget.baseBuildOrder = baseBuildOrderById
end

gadget.baseBuilders = NameArrayToIdSet(gadget.baseBuilders)
