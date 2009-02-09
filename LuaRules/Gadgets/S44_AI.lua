-- Author: Tobi Vollebregt
-- Slightly based on the Kernel Panic AI by KDR_11k (David Becker) and zwzsg.

-- In-game, type /luarules s44ai in the console to toggle the ai debug messages

function gadget:GetInfo()
	return {
		name = "Spring: 1944 AI",
		desc = "An AI for Spring: 1944",
		author = "Tobi Vollebregt",
		date = "2009-02-08",
		license = "GNU General Public License",
		layer = 82,
		enabled = true
	}
end


-- constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

-- globals
local S44_AI_Debug_Mode = 1 -- Must be 0 or 1


if (gadgetHandler:IsSyncedCode()) then

--SYNCED


local teamData={}
local unitTypes = include("LuaRules/Configs/S44_AI/unit_abstraction.lua")


local function ChangeAIDebugVerbosity(cmd,line,words,player)
	local lvl = tonumber(words[1])
	if lvl then
		S44_AI_Debug_Mode = lvl
		Spring.Echo("S44 LUA AI debug verbosity set to " .. S44_AI_Debug_Mode)
	else
		if S44_AI_Debug_Mode > 0 then
			S44_AI_Debug_Mode = 0
		else
			S44_AI_Debug_Mode = 1
		end
		Spring.Echo("S44 LUA AI debug verbosity toggled to " .. S44_AI_Debug_Mode)
	end
	return true
end


local function SetupCmdChangeAIDebugVerbosity()
	local cmd,func,help
	cmd  = "s44ai"
	func = ChangeAIDebugVerbosity
	help = " [0|1]: make the S44 LUA AI shut up or fill your infolog"
	gadgetHandler:AddChatAction(cmd,func,help)
	Script.AddActionFallback(cmd .. ' ',help)
end


local function Log(message)
	if S44_AI_Debug_Mode > 0 then
		Spring.Echo("S44AI: " .. message)
	end
end


local function LogTeam(t,message)
	if S44_AI_Debug_Mode > 0 then
		Spring.Echo("S44AI: Team[" .. t .. "] " .. message)
	end
end


function gadget:Initialize()
	Log("gadget:Initialize")
	SetupCmdChangeAIDebugVerbosity()

	-- Initialise AI for all team that are set to use it
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) == gadget:GetInfo().name then
			LogTeam(t, "assigned to " .. gadget:GetInfo().name)
			local _,_,_,_,side,at = Spring.GetTeamInfo(t)
			teamData[t] = {
				allyTeam = at,
				side = side,
			}
		end
	end
	-- RemoveSelfIfNoTeam() -- Somehow gadgetHandler:RemoveGadget() remove other gadgets when executed at GameStart stage. Moved to GameFrame
end


local function RemoveSelfIfNoTeam()
	local AIcount=0
	for t,td in pairs(teamData) do
		AIcount = AIcount + 1
	end
	if (AIcount == 0) then -- #teamData is 0 even when there are teams, and teamData=={} is untrue even when teamData={}
		Log("removing self (no team)")
		gadgetHandler:RemoveGadget()
	end
end


function gadget:GameStart()
	-- this is executed AFTER headquarters / commander is spawned
	Log("gadget:GameStart")
end


function gadget:GameFrame(f)
	-- AI update
	if f % 128 < .1 then
		Log("gadget:GameFrame")
		RemoveSelfIfNoTeam()
	end
end


function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	Log("gadget:UnitCreated")
	Log("unitID/unitDefID/unitTeam/builderID: " .. (unitID or "nil") .."/".. (unitDefID or "nil") .."/".. (unitTeam or "nil") .."/".. (builderID or "nil"))
	if teamData[unitTeam] then
		if unitTypes.headquarters[unitDefID] then
			Log("It's my HQ!")
		end
	end
end


else

--UNSYNCED


end
