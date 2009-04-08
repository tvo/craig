-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
In SYNCED code, this file returns true when there is at least one C.R.A.I.G.
bot in the game.  A second return value contains a set of the AI team indices.

In UNSYNCED code, this file returns true when the player is teamleader of at
least one C.R.A.I.G. bot in the game.  There is no second return value.

Example usage:
	if (not include("LuaRules/Gadgets/craig/enabled.lua")) then
		return false --ask for quiet death
	end
]]--

local NAME = "C.R.A.I.G."

if (gadgetHandler:IsSyncedCode()) then

	-- If no AIs are in the game, ask for a quiet death.
	local teams = {}
	local count = 0
	for _,t in ipairs(Spring.GetTeamList()) do
		if (Spring.GetTeamLuaAI(t):find(NAME) == 1) then
			teams[t] = true
			count = count + 1
		end
	end
	return count ~= 0, teams

else

	-- If we are not teamLeader of at least one AI team, ask for a quiet death.
	local count = 0
	local myPlayerID = Spring.GetMyPlayerID()
	for _,t in ipairs(Spring.GetTeamList()) do
		if (Spring.GetTeamLuaAI(t):find(NAME) == 1) then
			local _,leader,_,_,_,_ = Spring.GetTeamInfo(t)
			if (leader == myPlayerID) then
				count = count + 1
			end
		end
	end
	return count ~= 0

end
