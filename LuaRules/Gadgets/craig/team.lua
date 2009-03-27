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

function CreateTeam(myTeamID, myAllyTeamID, mySide)

local Team = {}

do
	local GadgetLog = gadget.Log
	function Team.Log(...)
		GadgetLog("Team[", myTeamID, "] ", ...)
	end
end
local Log = Team.Log

-- constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

-- Base building (one global buildOrder)
local baseMgr = CreateBaseMgr(myTeamID, myAllyTeamID, mySide, Log)

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

	-- TODO: waypoint module
	if waypointMgr then
		flagsMgr.GameStart()
	end
end

function Team.GameFrame(f)
	--Log("GameFrame")

	-- TODO: base building module
	baseMgr.GameFrame(f)

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

-- TODO: base building module
-- Short circuit callin which would otherwise only forward the call..
Team.UnitCreated = baseMgr.UnitCreated

function Team.UnitFinished(unitID, unitDefID, unitTeam)
	Log("UnitFinished: ", UnitDefs[unitDefID].humanName)

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

	if baseMgr.UnitFinished(unitID, unitDefID, unitTeam) then return end

	if waypointMgr then
		if combatMgr.UnitFinished(unitID, unitDefID, unitTeam) then return end
	end
end

function Team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	Log("UnitDestroyed: ", UnitDefs[unitDefID].humanName)

	-- TODO: base building module
	baseMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)

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
end

--------------------------------------------------------------------------------
--
--  Initialization
--

Log("assigned to ", gadget.ghInfo.name, " (allyteam: ", myAllyTeamID, ", side: ", mySide, ")")

return Team
end
