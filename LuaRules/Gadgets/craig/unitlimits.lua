-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

local UnitLimitMgr = CreateUnitLimitMgr(myTeamID)

function UnitLimitMgr:AllowUnitCreation(unitDefID)
]]--

function CreateUnitLimitMgr(myTeamID)

local UnitLimitMgr = {}

-- Format: map unitDefID -> limit
local limits = gadget.unitLimits

--------------------------------------------------------------------------------
--
--  Game call-ins
--

function UnitLimitMgr.AllowUnitCreation(unitDefID)
	if limits[unitDefID] then
		local count = Spring.GetTeamUnitDefCount(myTeamID, unitDefID)
		return (count or 0) < limits[unitDefID]
	end
	return true
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return UnitLimitMgr
end
