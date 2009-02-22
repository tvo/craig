-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:


]]--

function CreateFlagsMgr(myTeamID, myAllyTeamID, Log)

-- Can not do flag capping if we don't have waypoints..
if (not gadget.waypointMgr) then
	return false
end

local FlagsMgr = {}

-- constants
local MINIMUM_FLAG_CAP_RATE = 1  --only units with flagcaprate at least this high are used
local RESERVED_FLAG_CAPPERS = 12 --number of units claimed by this module

-- speedups
local Log = gadget.Log
local DelayedCall = gadget.DelayedCall
local GetUnitPosition = Spring.GetUnitPosition
local GetUnitTeam = Spring.GetUnitTeam

local waypointMgr = gadget.waypointMgr
local waypoints = waypointMgr.GetWaypoints()
local flags = waypointMgr.GetFlags()

-- members
local units = {}
local unitCount = 0

--------------------------------------------------------------------------------

local function SendToNearestWaypointWithUncappedFlags(unitID)
	local previous, target = PathFinder.Dijkstra(waypoints, units[unitID], {}, function(u)
		return (not u:AreAllFlagsCappedByTeam(myTeamID)) and (#u.flags > 0)
	end)
	if target then
		units[unitID] = target --assume next call this unit will be at target
		for _,p in PathFinder.PathIterator(previous, target) do
			Spring.GiveOrderToUnit(unitID, CMD.FIGHT, {p.x, p.y, p.z}, {"shift"})
		end
	else
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function FlagsMgr.GameFrame(f)
	for u,p in pairs(units) do
		if p:AreAllFlagsCappedByTeam(myTeamID) then
			Log("All flags capped near: ", p.x, ", ", p.z)
			SendToNearestWaypointWithUncappedFlags(u)
		end
	end
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function FlagsMgr.UnitFinished(unitID, unitDefID, unitTeam)
	if (unitCount < RESERVED_FLAG_CAPPERS) and
	   ((tonumber(UnitDefs[unitDefID].customParams.flagcaprate or 0)) >= MINIMUM_FLAG_CAP_RATE) then

		units[unitID] = waypointMgr.GetTeamStartPosition(myTeamID)
		if (not units[unitID]) then return end

		unitCount = unitCount + 1
		Log("Capping flags using: ", UnitDefs[unitDefID].humanName)

		return true --signal Team.UnitFinished that we will control this unit
	end
end

function FlagsMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	if units[unitID] then
		units[unitID] = nil
		unitCount = unitCount - 1
		Log("Flag capper destroyed.")
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return FlagsMgr
end
