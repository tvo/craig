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
				factories = {},
				engineers = {},
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


local function GiveEngineerBuildOrderToHQ(unitID, unitDefID)
	local unitDef = UnitDefs[unitDefID]
	for _,bo in pairs(unitDef.buildOptions) do
		if unitTypes.hqengineer[bo] then
			Log("Engineer found!")
			Spring.GiveOrderToUnit(unitID,-bo,{},{})
			Spring.GiveOrderToUnit(unitID,-bo,{},{})
			break
		end
	end
end


local function ClosestBuildSite(unitDefID, cx, cy, cz, facing)
	for dist=200,1000,100 do
		local x,z = cx + math.random(-dist, dist), cz + math.random(-dist, dist)
		local test = Spring.TestBuildOrder(unitDefID, x, cy, z, facing)
		if test >= 1 then
			return x, cy, z
		end
	end
end


local function GiveBuildOrderToEngineer(engID, engDefID, boDefID)
	local facing = 0
	local x, y, z = Spring.GetUnitPosition(engID)
	x, y, z = ClosestBuildSite(boDefID, x, y, z, facing)
	if x then
		Spring.GiveOrderToUnit(engID, -boDefID, { x, y, z, facing }, {})
	end
end


local function GiveBarrackBuildOrderToEngineer(engID, engDefID)
	local engDef = UnitDefs[engDefID]
	for _,bo in pairs(engDef.buildOptions) do
		if unitTypes.barracks[bo] then
			Log("Barracks found!")
			GiveBuildOrderToEngineer(engID, engDefID, bo)
		end
	end
end


function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	Log("gadget:UnitCreated")
	Log("unitID/unitDefID/unitTeam/builderID: " .. (unitID or "nil") .."/".. (unitDefID or "nil") .."/".. (unitTeam or "nil") .."/".. (builderID or "nil"))
	if teamData[unitTeam] then
		if unitTypes.headquarter[unitDefID] then
			Log("It's my HQ!")
			teamData[unitTeam].factories[unitID] = true
			GiveEngineerBuildOrderToHQ(unitID, unitDefID)
		elseif unitTypes.hqengineer[unitDefID] then
			Log("It's a HQ engineer!")
			teamData[unitTeam].engineers[unitID] = true
			GiveBarrackBuildOrderToEngineer(unitID, unitDefID)
		end
	end
end


-- this may be called by engine from inside Spring.GiveOrderToUnit (if unit limit is reached)
-- TODO: that will currently spam LUA errors....
function gadget:UnitIdle(unitID, unitDefID, unitTeam)
	Log("gadget:UnitIdle")
	Log("unitID/unitDefID/unitTeam: " .. (unitID or "nil") .."/".. (unitDefID or "nil") .."/".. (unitTeam or "nil") )
	if teamData[unitTeam] then
		if unitTypes.headquarter[unitDefID] then
			Log("It's my HQ!")
			teamData[unitTeam].factories[unitID] = true
			GiveEngineerBuildOrderToHQ(unitID, unitDefID)
		elseif unitTypes.hqengineer[unitDefID] then
			Log("It's a HQ engineer!")
			teamData[unitTeam].engineers[unitID] = true
			GiveBarrackBuildOrderToEngineer(unitID, unitDefID)
		end
	end
end

else

--UNSYNCED
-- tried to make the AI unsynced sometime but get no Unit* events then so it's pointless.. (and no errors either)

end
