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
local DelayedCall = gadget.DelayedCall

local waypointMgr = gadget.waypointMgr
local waypoints = waypointMgr.GetWaypoints()
local flags = waypointMgr.GetFlags()

-- members
local lastWaypoint = 0
local units = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function CombatMgr.GameFrame(f)
	-- one wave every 5 minutes only
	if f % 9000 >= 128 then return end

	Log("GO GO GO")

	-- make temporary data structure of squads (units at or moving towards same waypoint)
	local squads = {} -- waypoint -> array of unitIDs
	for u,p in pairs(units) do
		local squad = (squads[p] or {})
		squad[#squad+1] = u
		squads[p] = squad
	end

	-- give each orders towards the nearest enemy waypoint
	for p,unitArray in pairs(squads) do
		local previous, target = PathFinder.Dijkstra(waypoints, p, {}, function(p)
			return ((p.owner or myAllyTeamID) ~= myAllyTeamID)
		end)
		if target then
			for _,u in ipairs(unitArray) do
				units[u] = target --assume next call this unit will be at target
				PathFinder.GiveOrdersToUnit(previous, target, u, CMD.FIGHT)
			end
		end
	end
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
				units[unitID] = target -- remember where we are going for UnitIdle
				PathFinder.GiveOrdersToUnit(previous, target, unitID, CMD.FIGHT)
			end
		end)

		return true --signal Team.UnitFinished that we will control this unit
	end
end

function CombatMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	units[unitID] = nil
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return CombatMgr
end
