-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

function CombatMgr.GameFrame(f)
function CombatMgr.UnitFinished(unitID, unitDefID, unitTeam)
function CombatMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
]]--

function CreateCombatMgr(myTeamID, myAllyTeamID, Log)

-- Can not manage combat if we don't have waypoints..
if (not gadget.waypointMgr) then
	return false
end

local CombatMgr = {}

-- speedups
local Log = gadget.Log
local DelayedCall = gadget.DelayedCall
local GetUnitPosition = Spring.GetUnitPosition
local GetUnitTeam = Spring.GetUnitTeam

local waypointMgr = gadget.waypointMgr
local waypoints = waypointMgr.GetWaypoints()
local flags = waypointMgr.GetFlags()

-- members
local lastWaypoint = 0

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function CombatMgr.GameFrame(f)
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function CombatMgr.UnitFinished(unitID, unitDefID, unitTeam)
	-- if it's a mobile unit, give it orders towards frontline
	if waypointMgr and UnitDefs[unitDefID].speed ~= 0 then
		DelayedCall(unitID, function()
			local frontline, previous = waypointMgr.GetFrontline(myTeamID, myAllyTeamID)
			lastWaypoint = (lastWaypoint % #frontline) + 1
			local target = frontline[lastWaypoint]
			if (target ~= nil) then
				PathFinder.GiveOrdersToUnit(previous, target, unitID, CMD.FIGHT)
			end
		end)

		return true --signal Team.UnitFinished that we will control this unit
	end
end

function CombatMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return CombatMgr
end
