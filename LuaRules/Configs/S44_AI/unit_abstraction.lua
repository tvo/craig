-- Author: Tobi Vollebregt

-- unit names must be lowercase!

local unitBuildOrder = {
	gbrhq = {
		"gbrhqengineer",
		"gbrhqengineer",
		"gbr_platoon_hq",
		"gbr_platoon_hq",
		"gbr_platoon_hq",
	},
}

local baseBuildOrder = {
	"gbrbarracks",
	"gbrbarracks",
	"gbrstorage",
	"gbrbarracks",
	--TODO: vehicle yard, towed gun yard, tank yard
}

local baseBuilders = {
	"gbrhqengineer",
	"gbrengineer",
	"gbrmatadorengvehicle",
	"gerengineer",
	"gerhqengineer",
	--TODO: eng vehicle
	"rusengineer",
	--TODO: commisar, eng vehicle
	"ushqengineer",
	"usengineer",
	"usgmcengvehicle",
}

--------------------------------------------------------------------------------
--
--  Convert names to unitDefIDs
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

local unitBuildOrderById = {}
for k,v in pairs(unitBuildOrder) do
	unitBuildOrderById[NameToID(k)] = NameArrayToIdArray(v)
end

gadget.unitBuildOrder = unitBuildOrderById
gadget.baseBuildOrder = NameArrayToIdArray(baseBuildOrder)
gadget.baseBuilders = NameArrayToIdSet(baseBuilders)
