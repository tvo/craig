-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

local Team = CreateTeam(myTeamID, myAllyTeamID, mySide)

function Team.Log(...)
function Team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
function Team.UnitFinished(unitID, unitDefID, unitTeam)
function Team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
function Team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
function Team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
]]--

local callIns = {
	"GameStart",
	"GameFrame",
	"UnitCreated",
	"UnitFinished",
	"UnitDestroyed",
	"UnitIdle",
}

--------------------------------------------------------------------------------
function CreateTeam(myTeamID, myAllyTeamID, mySide)

local Team = {}

do
	local GadgetLog = gadget.Log
	function Team.Log(...)
		GadgetLog("Team[", myTeamID, "] ", ...)
	end
end
local Log = Team.Log

-- modules
local modules = {}
local callInLists = {}

-- constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

-- Unit building (one buildOrder per factory)
local unitBuildOrder = gadget.unitBuildOrder

-- Unit limits
local unitLimitsMgr = CreateUnitLimitsMgr(myTeamID)

-- Combat management
local waypointMgr = gadget.waypointMgr
local lastWaypoint = 0
local combatMgr = CreateCombatMgr(myTeamID, myAllyTeamID, Log)

-- Flag capping
local flagsMgr = CreateFlagsMgr(myTeamID, myAllyTeamID, mySide, Log)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function Team.GameStart()
	Log("GameStart")

	-- TODO: somehow instantiate modules
	-- TODO: initialize modules
	-- TODO: all this could use some sort of ... "gadget^H^H^H^H^H^HmoduleHandler"?

	for _,callIn in ipairs(callIns) do
		callInLists[callIn] = {}
	end

	for _,callIn in ipairs(callIns) do
		for _,module in ipairs(modules) do
			if type(module[callIn]) == "function" then
				local list = callInLists[callIn]
				list[#list + 1] = module[callIn]
			end
		end
	end

	for _,callIn in ipairs(callInLists.GameFrame) do
		callIn()
	end

	-- TODO: waypoint module
	if waypointMgr then
		flagsMgr.GameStart()
	end
end

function Team.GameFrame(f)
	--Log("GameFrame")

	for _,callIn in ipairs(callInLists.GameFrame) do
		callIn(f)
	end

	-- TODO: waypoint module
	if waypointMgr then
		flagsMgr.GameFrame(f)
		combatMgr.GameFrame(f)
	end
end

--------------------------------------------------------------------------------
--
--  Game call-ins
--

-- TODO: base building module
-- Short circuit callin which would otherwise only forward the call..
Team.AllowUnitCreation = unitLimitsMgr.AllowUnitCreation

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

-- Currently unitTeam always equals myTeamID (enforced in gadget)

function Team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	Log("UnitCreated: ", UnitDefs[unitDefID].humanName)

	for _,callIn in ipairs(callInLists.UnitCreated) do
		if callIn(unitID, unitDefID, unitTeam, builderID) then return end
	end
end

function Team.UnitFinished(unitID, unitDefID, unitTeam)
	Log("UnitFinished: ", UnitDefs[unitDefID].humanName)

	for _,callIn in ipairs(callInLists.UnitFinished) do
		if callIn(unitID, unitDefID, unitTeam) then return end
	end

	--TODO: cheat module
	-- idea from BrainDamage: instead of cheating huge amounts of resources,
	-- just cheat in the cost of the units we build.
	--Spring.AddTeamResource(myTeamID, "metal", UnitDefs[unitDefID].metalCost)
	--Spring.AddTeamResource(myTeamID, "energy", UnitDefs[unitDefID].energyCost)

	-- TODO: how to determine module preference?

	-- if any unit manager takes care of the unit, return
	-- managers are in order of preference

	-- need to prefer flag capping over building to handle Russian commissars
	if waypointMgr then
		if flagsMgr.UnitFinished(unitID, unitDefID, unitTeam) then return end
	end

	if waypointMgr then
		if combatMgr.UnitFinished(unitID, unitDefID, unitTeam) then return end
	end
end

function Team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	Log("UnitDestroyed: ", UnitDefs[unitDefID].humanName)

	for _,callIn in ipairs(callInLists.UnitDestroyed) do
		callIn(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	end

	-- TODO: flag capping module (squads), combat module
	if waypointMgr then
		flagsMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
		combatMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	end
end

function Team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	Team.UnitDestroyed(unitID, unitDefID, unitTeam)
end

function Team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	Team.UnitCreated(unitID, unitDefID, unitTeam, nil)
	local _, _, inBuild = Spring.GetUnitIsStunned(unitID)
	if not inBuild then
		Team.UnitFinished(unitID, unitDefID, unitTeam)
	end
end

function Team.UnitIdle(unitID, unitDefID, unitTeam)
	Log("UnitIdle: ", UnitDefs[unitDefID].humanName)

	for _,callIn in ipairs(callInLists.UnitIdle) do
		callIn(unitID, unitDefID, unitTeam)
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

Log("assigned to ", gadget.ghInfo.name, " (allyteam: ", myAllyTeamID, ", side: ", mySide, ")")

return Team
end
