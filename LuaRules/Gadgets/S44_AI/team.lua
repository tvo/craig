-- Author: Tobi Vollebregt

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

local team = CreateTeam(myTeamID, myAllyTeamID, mySide)

function team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
function team.UnitFinished(unitID, unitDefID, unitTeam)
function team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
function team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
function team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
]]--

function CreateTeam(myTeamID, myAllyTeamID, mySide)

local team = {}
local unitTypes = include("LuaRules/Configs/S44_AI/unit_abstraction.lua")
local buildsiteFinder = CreateBuildsiteFinder(myTeamID)

local Log = function (message)
	Log("Team[" .. myTeamID .. "] " .. message)
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

-- Currently unitTeam always equals myTeamID (enforced in gadget)

local function GiveEngineerBuildOrderToHQ(unitID, unitDefID)
	local unitDef = UnitDefs[unitDefID]
	for _,bo in pairs(unitDef.buildOptions) do
		if unitTypes.hqengineer[bo] then
			Spring.GiveOrderToUnit(unitID,-bo,{},{})
		end
	end
end

local function GiveBuildOrderToEngineer(engID, engDefID, boDefID)
	local x, y, z, facing = buildsiteFinder.FindBuildsite(engID, boDefID)
	if x then
		Spring.GiveOrderToUnit(engID, -boDefID, { x, y, z, facing }, {})
	else
		Log("Could not find buildsite for " .. UnitDefs[boDefID].humanName)
	end
end

local function GiveBarracksBuildOrderToEngineer(engID, engDefID)
	local engDef = UnitDefs[engDefID]
	for _,bo in pairs(engDef.buildOptions) do
		if unitTypes.barracks[bo] then
			GiveBuildOrderToEngineer(engID, engDefID, bo)
		end
	end
end

function team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if unitTypes.headquarter[unitDefID] then
		Log("It's my HQ!")
		GiveEngineerBuildOrderToHQ(unitID, unitDefID)
		GiveEngineerBuildOrderToHQ(unitID, unitDefID)
	elseif unitTypes.hqengineer[unitDefID] then
		Log("It's a HQ engineer!")
		GiveBarracksBuildOrderToEngineer(unitID, unitDefID)
	end
end

function team.UnitFinished(unitID, unitDefID, unitTeam)
	--buildsiteFinder.UnitFinished(unitID, unitDefID, unitTeam)
end

function team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

function team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam)
end

function team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam)
end

--------------------------------------------------------------------------------
--
--  Initialization
--
Log("assigned to " .. gadget:GetInfo().name .. " (allyteam: " .. myAllyTeamID .. ", side: " .. mySide .. ")")

return team
end
