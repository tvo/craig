-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

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

local Log = function (message)
	Log("Team[" .. myTeamID .. "] " .. message)
end

-- constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

-- Enemy start positions (assumes this are base positions)
local enemyBases = {}
local enemyBaseCount = 0
local enemyBaseLastAttacked = 0

-- Base building (one global buildOrder)
local base = CreateBaseBuildMgr(myTeamID, myAllyTeamID, mySide, Log)

-- Unit building (one buildOrder per factory)
local unitBuildOrder = gadget.unitBuildOrder

-- Unit limits
local unitLimitsMgr = CreateUnitLimitMgr(myTeamID)

local delayedCallQue = { first = 1, last = 0 }

local function DelayedCall(fun)
	delayedCallQue.last = delayedCallQue.last + 1
	delayedCallQue[delayedCallQue.last] = fun
end

local function PopDelayedCall()
	local ret = delayedCallQue[delayedCallQue.first]
	if ret then
		delayedCallQue.first = delayedCallQue.first + 1
	end
	return ret
end

local function Refill(resource)
	local value,storage = Spring.GetTeamResources(myTeamID, resource)
	Spring.AddTeamResource(myTeamID, resource, storage - value)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function team.GameStart()
	Log("GameStart")
	-- Can not run this in the initialization code at the end of this file,
	-- because at that time Spring.GetTeamStartPosition seems to always return 0,0,0.
	for _,t in ipairs(Spring.GetTeamList()) do
		--Log("considering team " .. t)
		if (t ~= GAIA_TEAM_ID) and (not Spring.AreTeamsAllied(myTeamID, t)) then
			local x,y,z = Spring.GetTeamStartPosition(t)
			if x and x ~= 0 then
				enemyBaseCount = enemyBaseCount + 1
				enemyBases[enemyBaseCount] = {x,y,z}
				Log("Enemy base spotted at coordinates: " .. x .. ", " .. z)
			else
				Log("Oops, Spring.GetTeamStartPosition failed")
			end
		end
	end
	Log("Preparing to attack " .. enemyBaseCount .. " enemies")
end

function team.GameFrame(f)
	Log("GameFrame")

	Refill("metal")
	Refill("energy")

	while true do
		local fun = PopDelayedCall()
		if fun then fun() else break end
	end

	base.GameFrame(f)
end

--------------------------------------------------------------------------------
--
--  Game call-ins
--

-- Short circuit callin which would otherwise only forward the call..
team.AllowUnitCreation = unitLimitsMgr.AllowUnitCreation

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

-- Currently unitTeam always equals myTeamID (enforced in gadget)

-- Short circuit callin which would otherwise only forward the call..
team.UnitCreated = base.UnitCreated

function team.UnitFinished(unitID, unitDefID, unitTeam)
	Log("UnitFinished: " .. UnitDefs[unitDefID].humanName)

	-- idea from BrainDamage: instead of cheating huge amounts of resources,
	-- just cheat in the cost of the units we build.
	--Spring.AddTeamResource(myTeamID, "metal", UnitDefs[unitDefID].metalCost)
	--Spring.AddTeamResource(myTeamID, "energy", UnitDefs[unitDefID].energyCost)

	-- queue unitBuildOrders if we have any for this unitDefID
	if unitBuildOrder[unitDefID] then
		DelayedCall(function()
			-- factory or builder?
			if (UnitDefs[unitDefID].TEDClass == "PLANT") then
				for _,bo in ipairs(unitBuildOrder[unitDefID]) do
					Log("Queueing: " .. UnitDefs[bo].humanName)
					Spring.GiveOrderToUnit(unitID, -bo, {}, {})
				end
				-- If there are no enemies, don't bother lagging Spring to death:
				-- just go through the build queue exactly once, instead of repeating it.
				if enemyBaseCount > 0 then
					Spring.GiveOrderToUnit(unitID, CMD.REPEAT, {1}, {})
					-- Each next factory gives fight command to next enemy.
					-- Didn't use math.random() because it's really hard to establish
					-- a 100% correct distribution when you don't know whether the
					-- upper bound of the RNG is inclusive or exclusive.
					enemyBaseLastAttacked = enemyBaseLastAttacked + 1
					if enemyBaseLastAttacked > enemyBaseCount then
						enemyBaseLastAttacked = 1
					end
					-- queue up a bunch of fight orders towards all enemies
					local idx = enemyBaseLastAttacked
					for i=1,enemyBaseCount do
						-- enemyBases[] is in the right format to pass into GiveOrderToUnit...
						Spring.GiveOrderToUnit(unitID, CMD.FIGHT, enemyBases[idx], {"shift"})
						idx = idx + 1
						if idx > enemyBaseCount then idx = 1 end
					end
				end
			else
				Log("Warning: unitBuildOrder can only be used to control factories")
			end
		end)
	end

	base.UnitFinished(unitID, unitDefID, unitTeam)
end

function team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	Log("UnitDestroyed: " .. UnitDefs[unitDefID].humanName)

	base.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

function team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	team.UnitDestroyed(unitID, unitDefID, unitTeam)
end

function team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	team.UnitCreated(unitID, unitDefID, unitTeam, nil)
	local _, _, inBuild = Spring.GetUnitIsStunned(unitID)
	if not inBuild then
		team.UnitFinished(unitID, unitDefID, unitTeam)
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

Log("assigned to " .. gadget:GetInfo().name .. " (allyteam: " .. myAllyTeamID .. ", side: " .. mySide .. ")")

return team
end
