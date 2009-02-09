-- Author: Tobi Vollebregt

-- unit names must be lowercase!
local unitTypes = {
	headquarter = {
		"ai_gbrhq",
		"ai_gerhqbunker",
		"ai_ushq",
		"gbrhq",
		"gerhqbunker",
		"ushq",
	},
	hqengineer = {
		"gbrhqengineer",
		"gerhqengineer",
		"ushqengineer",
	},
	hqplatoon = {
		"gbr_platoon_hq",
		"gbr_platoon_hq_assault",
		"gbr_platoon_hq_rifle",
		"ger_platoon_hq",
		"ger_platoon_hq_assault",
		"ger_platoon_hq_rifle",
		"us_platoon_hq",
		"us_platoon_hq_assault",
		"us_platoon_hq_rifle",
	},
}

-------------------------------------------------
-- convert to sets with unitdef.id as key

--[[
for k,v in pairs(UnitDefNames) do
	Spring.Echo("UnitDefNames["..k.."]")
end
]]--

local unitTypesById = {}

for tname,t in pairs(unitTypes) do
	local set = {}
	for _,name in pairs(t) do
		local unitdef = UnitDefNames[name]
		if unitdef then
			set[unitdef.id] = true;
		else
			error("Bad unitname: " .. name)
		end
	end
	unitTypesById[tname] = set
end

return unitTypesById
