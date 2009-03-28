-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- Module which gives each factory a repeat build queue based on unitBuildOrder.

--------------------------------------------------------------------------------
local function CreateModule(team)
local Mod = {}

-- speedups
local Log = team.Log
local unitBuildOrder = gadget.unitBuildOrder --TODO: keep unitBuildOrder per team?

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function Mod.UnitFinished(unitID, unitDefID, unitTeam)
	-- queue unitBuildOrders if we have any for this unitDefID
	if unitBuildOrder[unitDefID] then
		-- factory or builder?
		if (UnitDefs[unitDefID].TEDClass == "PLANT") then
			-- repeat order must come first, otherwise unit orders may get lost
			-- if the unit limit has been reached or a gadget blocks the command.
			GiveOrderToUnit(unitID, CMD.REPEAT, {1}, {})
			for _,bo in ipairs(unitBuildOrder[unitDefID]) do
				Log("Queueing: ", UnitDefs[bo].humanName)
				GiveOrderToUnit(unitID, -bo, {}, {})
			end
		end
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return Mod
end

--------------------------------------------------------------------------------
return {
	name = "factory",
	layer = 0,
	ctor = CreateModule,
}
