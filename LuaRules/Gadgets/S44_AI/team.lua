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
local buildsiteFinder = CreateBuildsiteFinder(myTeamID)
local buildOrder = gadget.buildOrder

local Log = function (message)
	Log("Team[" .. myTeamID .. "] " .. message)
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

-- Currently unitTeam always equals myTeamID (enforced in gadget)

function team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam, builderID)
end

function team.UnitFinished(unitID, unitDefID, unitTeam)
	Log("UnitFinished "..unitID.."/"..unitDefID.."/"..unitTeam)
	if buildOrder[unitDefID] then
		for _,bo in ipairs(buildOrder[unitDefID]) do
			Log("Queueing " .. UnitDefs[bo].humanName)
			if UnitDefs[bo].speed == 0 then
				-- TODO: give build orders only after last building is finished building
				-- TODO: group build orders together (one construction site at a time)
				local x,y,z,facing = buildsiteFinder.FindBuildsite(unitID, bo)
				Spring.GiveOrderToUnit(unitID, -bo, {x,y,z,facing}, {"shift"})
			else
				Spring.GiveOrderToUnit(unitID, -bo, {}, {})
			end
		end
	end
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
