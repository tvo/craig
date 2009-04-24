-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- This file is responsible for loading configuration data from
-- LuaRules/Configs/craig/config.lua and putting it in the global environment.

include("LuaRules/Configs/craig/config.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- publish configuration in the gadget global environment
--

local function undeclared(_, key)
	error("Attempt to read undeclared configuration key: " .. tostring(key), 2)
end

local function readonly(_, key)
	error("Attempt to write readonly configuration key: " .. tostring(key), 2)
end


local tables

if (gadgetHandler:IsSyncedCode()) then
	tables = {
		"unitLimits",
	}
else
	tables = {
		"unitBuildOrder",
		"baseBuildOrder",
		"baseBuilders",
		"flags",
		"flagCappers",
		"reservedFlagCappers",
		"unitLimits",
	}
end


GG.CRAIG = {}

-- make the configuration tables readonly
for _,tname in ipairs(tables) do
	local table = gadget[tname]
	gadget[tname] = {}
	setmetatable(gadget[tname], {
		__index = table,
		__newindex = readonly,
	})
	GG.CRAIG[tname] = gadget[tname]
end

setmetatable(GG.CRAIG, {
	__index = undeclared,
	__newindex = readonly,
})
