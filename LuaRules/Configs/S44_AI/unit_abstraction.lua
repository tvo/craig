-- Author: Tobi Vollebregt

-- unit names must be lowercase!
local buildOrder = {
	gbrhq = {
		"gbrhqengineer",
		"gbrhqengineer",
		"gbr_platoon_hq",
		"gbr_platoon_hq",
		"gbr_platoon_hq",
	},
	gbrhqengineer = {
		"gbrbarracks",
		"gbrstorage",
	},
}


--------------------------------------------------------------------------------
--
--  Convert to sets with unitdef.id as key
--

local function UnitDefNameToID(name)
	local unitDef = UnitDefNames[name]
	if unitDef then
		return unitDef.id
	else
		error("Bad unitname: " .. name)
	end
end

local buildOrderById = {}

for tname,t in pairs(buildOrder) do
	local array = {}
	for i,name in ipairs(t) do
		array[i] = UnitDefNameToID(name)
	end
	buildOrderById[UnitDefNameToID(tname)] = array
end

gadget.buildOrder = buildOrderById
