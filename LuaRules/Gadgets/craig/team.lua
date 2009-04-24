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

local Team = {
	myTeamID = myTeamID,
	myAllyTeamID = myAllyTeamID,
	mySide = mySide,
}

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

--------------------------------------------------------------------------------

function Team.GetModule(name)
	for _,module in ipairs(modules) do
		if (module.name == name) then return module end
	end
	return nil, "C.R.A.I.G.: module " .. name .. " not found!"
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function Team.GameStart()
	Log("GameStart")

	for _,callIn in ipairs(callInLists.GameStart) do
		callIn()
	end
end

function Team.GameFrame(f)
	Log("GameFrame")

	for _,callIn in ipairs(callInLists.GameFrame) do
		callIn(f)
	end
end

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
end

function Team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	Log("UnitDestroyed: ", UnitDefs[unitDefID].humanName)

	for _,callIn in ipairs(callInLists.UnitDestroyed) do
		callIn(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
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

-- Module initialization
do
	for _,module in ipairs(gadget.modules) do
		local inst = module.ctor(Team)
		inst.name = module.name --needed in GetModule
		modules[#modules + 1] = inst
	end

	for _,callIn in ipairs(callIns) do
		callInLists[callIn] = {}
	end

	for _,callIn in ipairs(callIns) do
		local list = callInLists[callIn]
		for _,module in ipairs(modules) do
			if type(module[callIn]) == "function" then
				list[#list + 1] = module[callIn]
			end
		end
	end
end

Log("assigned to ", gadget.ghInfo.name, " (allyteam: ", myAllyTeamID, ", side: ", mySide, ")")

return Team
end
