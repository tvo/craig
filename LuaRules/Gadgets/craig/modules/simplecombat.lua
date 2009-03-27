-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- This module wraps the original -trivially simple- combat code.

--------------------------------------------------------------------------------
local function CreateModule(team)
local Mod = {}

-- constants
local MY_TEAM_ID = team.myTeamID
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

-- speedups
local Log = team.Log
local unitBuildOrder = gadget.unitBuildOrder --TODO: keep unitBuildOrder per team?

-- Enemy start positions (assumes this are base positions)
local enemyBases = {}
local enemyBaseCount = 0
local enemyBaseLastAttacked = 0

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function Mod.GameStart()
	-- Can not run this in the initialization code at the end of this file,
	-- because at that time Spring.GetTeamStartPosition seems to always return 0,0,0.
	for _,t in ipairs(Spring.GetTeamList()) do
		if (t ~= GAIA_TEAM_ID) and (not Spring.AreTeamsAllied(MY_TEAM_ID, t)) then
			local x,y,z = Spring.GetTeamStartPosition(t)
			if x and x ~= 0 then
				enemyBaseCount = enemyBaseCount + 1
				enemyBases[enemyBaseCount] = {x,y,z}
				Log("Enemy base spotted at coordinates: ", x, ", ", z)
			else
				Log("Oops, Spring.GetTeamStartPosition failed")
			end
		end
	end
	Log("Preparing to attack ", enemyBaseCount, " enemies")
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function Mod.UnitFinished(unitID, unitDefID, unitTeam)
	-- queue unitBuildOrders if we have any for this unitDefID
	if unitBuildOrder[unitDefID] then
		-- factory or builder?
		if (UnitDefs[unitDefID].TEDClass == "PLANT") then
			-- If there are no enemies, don't bother lagging Spring to death:
			-- just go through the build queue exactly once, instead of repeating it.
			if enemyBaseCount > 0 then
				--TODO: factory module; NOT simplecombat!!
				GiveOrderToUnit(unitID, CMD.REPEAT, {1}, {})
				-- Each next factory gives fight command to next enemy.
				-- Didn't use math.random() because it's really hard to establish
				-- a 100% correct distribution when you don't know whether the
				-- upper bound of the RNG is inclusive or exclusive.
				if (not waypointMgr) then
					--TODO: inside this if block really is simplecombat module
					enemyBaseLastAttacked = enemyBaseLastAttacked + 1
					if enemyBaseLastAttacked > enemyBaseCount then
						enemyBaseLastAttacked = 1
					end
					-- queue up a bunch of fight orders towards all enemies
					local idx = enemyBaseLastAttacked
					for i=1,enemyBaseCount do
						-- enemyBases[] is in the right format to pass into GiveOrderToUnit...
						GiveOrderToUnit(unitID, CMD.FIGHT, enemyBases[idx], {"shift"})
						idx = idx + 1
						if idx > enemyBaseCount then idx = 1 end
					end
				end
			end
			--TODO: factory module; NOT simplecombat!!
			for _,bo in ipairs(unitBuildOrder[unitDefID]) do
				Log("Queueing: ", UnitDefs[bo].humanName)
				GiveOrderToUnit(unitID, -bo, {}, {})
			end
		else
			Log("Warning: unitBuildOrder can only be used to control factories")
		end
		return true
	end
	return false
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return Mod
end

--------------------------------------------------------------------------------
return CreateModule
