-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- Slightly based on the Kernel Panic AI by KDR_11k (David Becker) and zwzsg.
-- Thanks to lurker for providing hints on how to make the AI run unsynced.

-- In-game, type /luarules craig in the console to toggle the ai debug messages

function gadget:GetInfo()
	return {
		name = "C.R.A.I.G.: 1944",
		desc = "Configurable Reusable Artificial Intelligence Gadget for Spring: 1944",
		author = "Tobi Vollebregt",
		date = "2009-02-12",
		license = "GNU General Public License",
  		layer = 82,
		enabled = true
	}

end


-- If no AIs are in the game, ask for a quiet death.
local team = {}
local teamLeader = {}
do
	local count = 0
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) == name then
			local _,leader,_,_,side,at = Spring.GetTeamInfo(t)
			team[t] = { leader = leader, side = side, allyTeam = at }
			teamLeader[leader] = t
			count = count + 1
		end
	end
	if count == 0 then return false end
end


-- Read mod options, we need this in both synced and unsynced code!
if (Spring.GetModOptions) then
	local modOptions = Spring.GetModOptions()
	difficulty = (modOptions.craig_difficulty or "hard")
else
	difficulty = "hard"
end


local callInList = {
	"GamePreload",
	"GameStart",
	"GameFrame",
	"TeamDied",
	"UnitCreated",
	"UnitFinished",
	"UnitDestroyed",
	"UnitTaken",
	"UnitGiven",
	"UnitIdle",
}

if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  SYNCED
--

local orderQueue = {}


function gadget:Initialize()
	-- Set up the forwarding calls to the unsynced part of the gadget.
	local SendToUnsynced = SendToUnsynced
	for _,callIn in pairs(callInList) do
		local fun = gadget[callIn]
		if (fun ~= nil) then
			gadget[callIn] = function(self, ...) fun(self, ...) SendToUnsynced(callIn, ...) end
		else
			gadget[callIn] = function(self, ...) SendToUnsynced(callIn, ...) end
		end
		gadgetHandler:UpdateCallIn(callIn)
	end
end


local function Refill(myTeamID, resource)
	if (gadget.difficulty ~= "easy") then
		local value,storage = Spring.GetTeamResources(myTeamID, resource)
		if (gadget.difficulty ~= "medium") then
			-- hard: full refill
			Spring.AddTeamResource(myTeamID, resource, storage - value)
		else
			-- medium: partial refill
			-- 1000 storage / 128 * 30 = approx. +234
			-- this means 100% cheat is bonus of +234 metal at 1k storage
			Spring.AddTeamResource(myTeamID, resource, (storage - value) * 0.06)
		end
	end
end


local function DeserializeOrder(msg)
	local b = {msg:byte(1, -1)}

	local unitID = b[1] * 256 + b[2]
	local cmd = b[3] * 256 + b[4] - 32768
	local options = b[5]
	local params = {}

	for i=6,#b,2 do
		params[#params+1] = b[i] * 256 + b[i+1]
	end

	return unitID, cmd, params, options
end


function gadget:GameFrame(f)
	for _,order in ipairs(orderQueue) do
		Spring.GiveOrderToUnit(DeserializeOrder(order))
	end
	orderQueue = {}

	-- Perform economy cheating, this must be done in synced code!
	if f % 128 < 0.1 then
		for t,_ in pairs(team) do
			Refill(t, "metal")
			Refill(t, "energy")
		end
	end
end


function gadget:RecvLuaMsg(msg, player)
	if (not teamLeader[player]) then
		Spring.Echo("WARNING: PLAYER " .. player .. "TRIED TO SPOOF A C.R.A.I.G. LUA MESSAGE!!!")
		return
	end
	orderQueue[#orderQueue+1] = msg
end


else

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  UNSYNCED
--

CMD.alt = CMD.OPT_ALT
CMD.ctrl = CMD.OPT_CTRL
CMD.shift = CMD.OPT_SHIFT
CMD.right = CMD.OPT_RIGHT


local function SerializeOrder(unitID, cmd, params, options)
	if type(options) == "table" then
		local newOptions = 0
		for _,opt in ipairs(options) do
			newOptions = newOptions + CMD[opt]
		end
		options = newOptions
	end

	local b = {}

	b[1] = unitID / 256
	b[2] = unitID % 256
	cmd = cmd + 32768
	b[3] = cmd / 256
	b[4] = cmd % 256
	b[5] = options

	for i=1,#params do
		params[i] = math.floor(params[i])
		b[#b+1] = params[i] / 256
		b[#b+1] = params[i] % 256
	end

	return string.char(unpack(b))
end


function Spring.GiveOrderToUnit(...)
	Spring.SendLuaRulesMsg(SerializeOrder(...))
end


--constants
local MY_PLAYER_ID = Spring.GetMyPlayerID()

-- If we are not teamLeader of an AI team, ask for a quiet death.
do
	local count = 0
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) == name then
			local _,leader,_,_,_,_ = Spring.GetTeamInfo(t)
			if (leader == MY_PLAYER_ID) then count = count + 1 end
		end
	end
	if count == 0 then return false end
end

--------------------------------------------------------------------------------

-- globals
waypointMgr = {}

-- include configuration
include("LuaRules/Configs/craig/buildorder.lua")

-- include code
include("LuaRules/Gadgets/craig/buildorder.lua")
include("LuaRules/Gadgets/craig/buildsite.lua")
include("LuaRules/Gadgets/craig/base.lua")
include("LuaRules/Gadgets/craig/combat.lua")
include("LuaRules/Gadgets/craig/flags.lua")
include("LuaRules/Gadgets/craig/pathfinder.lua")
include("LuaRules/Gadgets/craig/unitlimits.lua")
include("LuaRules/Gadgets/craig/team.lua")
include("LuaRules/Gadgets/craig/waypoints.lua")

-- locals
local CRAIG_Debug_Mode = 1 -- Must be 0 or 1
local delayedCalls = {}
local team = {}
local waypointMgrGameFrameRate = 0

--------------------------------------------------------------------------------

local function ChangeAIDebugVerbosity(cmd,line,words,player)
	local lvl = tonumber(words[1])
	if lvl then
		CRAIG_Debug_Mode = lvl
		Spring.Echo("C.R.A.I.G.: debug verbosity set to " .. CRAIG_Debug_Mode)
	else
		if CRAIG_Debug_Mode > 0 then
			CRAIG_Debug_Mode = 0
		else
			CRAIG_Debug_Mode = 1
		end
		Spring.Echo("C.R.A.I.G.: debug verbosity toggled to " .. CRAIG_Debug_Mode)
	end
	return true
end

local function SetupCmdChangeAIDebugVerbosity()
	local cmd,func,help
	cmd  = "craig"
	func = ChangeAIDebugVerbosity
	help = " [0|1]: make C.R.A.I.G. shut up or fill your infolog"
	gadgetHandler:AddChatAction(cmd,func,help)
	--Script.AddActionFallback(cmd .. ' ',help)
end

function gadget.Log(...)
	if CRAIG_Debug_Mode > 0 then
		Spring.Echo("C.R.A.I.G.: " .. table.concat{...})
	end
end

-- This is for log messages which can not be turned off (e.g. while loading.)
function gadget.Warning(...)
	Spring.Echo("C.R.A.I.G.: " .. table.concat{...})
end

--------------------------------------------------------------------------------

-- Runs fun() in the next GameFrame. If unitID is destoyed, fun() is never run.
-- Limitations: 1) There can only be one delayed call per unit per GameFrame
--              and 2) the delayed calls are executed in arbitrary order.
function gadget.DelayedCall(unitID, fun)
	if delayedCalls[unitID] then
		Log("Warning: second delayed call for ", unitID)
	end
	delayedCalls[unitID] = fun
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

-- Execution order:
--  gadget:Initialize
--  gadget:GamePreload
--  gadget:UnitCreated (for each HQ / comm)
--  gadget:GameStart

function gadget:Initialize()
	setmetatable(gadget, {
		__index = function() error("Attempt to read undeclared global variable", 2) end,
		__newindex = function() error("Attempt to write undeclared global variable", 2) end,
	})
	for _,callIn in pairs(callInList) do
		local fun = gadget[callIn]
		--fun = function(name, ...) Spring.Echo("UNSYNCED: "..name) gadget[callIn](name, ...) end
		gadgetHandler:AddSyncAction(callIn, fun)
	end
	SetupCmdChangeAIDebugVerbosity()
end

function gadget:GamePreload()
	-- This is executed BEFORE headquarters / commander is spawned
	Log("gadget:GamePreload")
	-- Intialise waypoint manager
	waypointMgr = CreateWaypointMgr()
	if waypointMgr then
		waypointMgrGameFrameRate = waypointMgr.GetGameFrameRate()
	end
	-- Initialise AI for all team that are set to use it
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) ==  name then
			local _,leader,_,_,side,at = Spring.GetTeamInfo(t)
			if (leader == MY_PLAYER_ID) then
				team[t] = CreateTeam(t, at, side)
			end
		end
	end
end

function gadget:GameStart()
	-- This is executed AFTER headquarters / commander is spawned
	Log("gadget:GameStart")
	if waypointMgr then
		waypointMgr.GameStart()
	end
	for _,t in pairs(team) do
		t.GameStart()
	end
end

function gadget:GameFrame(f)
	-- run delayed calls
	for u,fun in pairs(delayedCalls) do
		fun()
		delayedCalls[u] = nil
	end

	-- waypointMgr update
	if waypointMgr and f % waypointMgrGameFrameRate < .1 then
		waypointMgr.GameFrame(f)
	end

	-- AI update
	if f % 128 < .1 then
		for _,t in pairs(team) do
			t.GameFrame(f)
		end
	end
end

--------------------------------------------------------------------------------
--
--  Game call-ins
--

function gadget:TeamDied(teamID)
	if team[teamID] then
		team[teamID] = nil
		Log("removed team ", teamID)
	end

	--TODO: need to call this for other/enemy teams too, so a team
	-- can adjust it's fight orders to the remaining living teams.
	--for _,t in pairs(team) do
	--	t.TeamDied(teamID)
	--end
end

function gadget:AllowUnitCreation(unitDefID, builderID, builderTeam, x, y, z)
	if team[builderTeam] then
		return team[builderTeam].AllowUnitCreation(unitDefID, builderID, builderTeam, x, y, z)
	end
	return true
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if waypointMgr then
		waypointMgr.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	end
	if team[unitTeam] then
		team[unitTeam].UnitCreated(unitID, unitDefID, unitTeam, builderID)
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if team[unitTeam] then
		team[unitTeam].UnitFinished(unitID, unitDefID, unitTeam)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	if team[unitTeam] then
		delayedCalls[unitID] = nil
		team[unitTeam].UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	end
end

function gadget:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	if team[unitTeam] then
		delayedCalls[unitID] = nil
		team[unitTeam].UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	end
end

function gadget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	if team[unitTeam] then
		team[unitTeam].UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	end
end

-- This may be called by engine from inside Spring.GiveOrderToUnit (e.g. if unit limit is reached)
function gadget:UnitIdle(unitID, unitDefID, unitTeam)
	if team[unitTeam] then
		team[unitTeam].UnitIdle(unitID, unitDefID, unitTeam)
	end
end

end
