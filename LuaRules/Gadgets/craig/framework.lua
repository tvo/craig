-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This file defines the following global functions:

In SYNCED code:

function gadget:Initialize()
function gadget:GameFrame(f)
function gadget:RecvLuaMsg(msg, player)

In UNSYNCED code:

function gadget:Initialize()
function GiveOrderToUnit(unitID, cmd, params, options)
TODO: function GiveOrderToUnitMap(...)
TODO: function GiveOrderToUnitArray(...)
TODO: function GiveOrderArrayToUnitMap(...)
TODO: function GiveOrderArrayToUnitArray(...)

When you need to handle one of the above callIns too, you can use the following
pattern to chain your functions together with those defined in this file:

do
	local GameFrame = gadget:GameFrame
	function gadget:GameFrame(f)
		-- insert your own code here
		return GameFrame(self, f)
	end
end
]]--


local function Log(...)
	--uncomment to debug LUA AI framework code
	Spring.Echo("LUA AI: " .. table.concat{...})
end


if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  SYNCED
--

--speedups
local GiveOrderToUnit = Spring.GiveOrderToUnit
local ValidUnitID = Spring.ValidUnitID
local GetUnitTeam = Spring.GetUnitTeam

-- globals
local orderQueue = {}
--local allowedPlayers = {}
local allowedTeams = {}

do
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) == name then
			local _,leader,_,_,_,_ = Spring.GetTeamInfo(t)
			--allowedPlayers[leader] = true
			--Log("SYNCED: allowed player: ", leader)
			allowedTeams[t] = true
			Log("SYNCED: allowed team: ", t)
		end
	end
end


local function DeserializeAndProcessOrder(msg)
	local b = {msg:byte(2, -1)} --first byte is signature
	local unitID = b[1] * 256 + b[2]

	-- unit may have died between SendLuaRulesMsg and GameFrame
	-- worse, a new unit might have been created with same unitID
	if ValidUnitID(unitID) and allowedTeams[GetUnitTeam(unitID)] then
		local cmd = b[3] * 256 + b[4] - 32768
		local options = b[5]
		local params = {}

		for i=6,#b,2 do
			params[#params+1] = b[i] * 256 + b[i+1] - 32768
		end

		Log("SYNCED: DeserializeAndProcessOrder: ", unitID)
		GiveOrderToUnit(unitID, cmd, params, options)
	end
end

--------------------------------------------------------------------------------
--
--  The call-in routines
--

function gadget:Initialize()
	Log("SYNCED: Initialize")
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


function gadget:GameFrame(f)
	if (next(orderQueue) ~= nil) then
		Log("SYNCED: GameFrame: processing ", #orderQueue, " orders")
		for _,order in ipairs(orderQueue) do
			DeserializeAndProcessOrder(order)
		end
		orderQueue = {}
	end
end


function gadget:RecvLuaMsg(msg, player)
	-- Tried to check allowedPlayers[player] too but this breaks replays, and
	-- Spring.IsReplay() only returns true for hosted replays, not local ones.
	if (msg:byte() == 213) then
		Log("SYNCED: RecvLuaMsg from player ", player)
		-- it's not allowed to call GiveOrderToUnit here
		orderQueue[#orderQueue+1] = msg
	end
end

else

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  UNSYNCED
--

--globals
local optionStringToNumber = {
	alt   = CMD.OPT_ALT,
	ctrl  = CMD.OPT_CTRL,
	shift = CMD.OPT_SHIFT,
	right = CMD.OPT_RIGHT,
}


local function SerializeOrder(unitID, cmd, params, options)
	-- convert the table format (e.g. '{"shift"}') for options to a number
	if type(options) == "table" then
		local newOptions = 0
		for _,opt in ipairs(options) do
			newOptions = newOptions + optionStringToNumber[opt]
		end
		options = newOptions
	end

	cmd = cmd + 32768 --signed 16 bit integer range

	local b = {
		213,          --signature
		unitID / 256,
		unitID % 256,
		cmd / 256,
		cmd % 256,
		options,
	}

	for i=1,#params do
		local param = math.floor(params[i]) + 32768
		b[#b+1] = param / 256
		b[#b+1] = param % 256
	end

	-- NETMSG_LUAMSG    : size = 7 + msg.size() + 1 = 14 + params.size() * 2
	-- NETMSG_AICOMMAND : size = 11 + params.size() * 4

	-- So for all orders with params.size() >= 2 I'm sending less bytes over
	-- the network then LuaUnsyncedCtrl::GiveOrderToUnit would have done if it
	-- had worked :-)

	return string.char(unpack(b))
end


function GiveOrderToUnit(unitID, cmd, params, options)
	Log("UNSYNCED: GiveOrderToUnit ", unitID)
	Spring.SendLuaRulesMsg(SerializeOrder(unitID, cmd, params, options))
end

--------------------------------------------------------------------------------
--
--  The call-in routines
--

function gadget:Initialize()
	Log("UNSYNCED: Initialize")
	for _,callIn in pairs(callInList) do
		local fun = gadget[callIn]
		--uncomment this to trace all callIn calls
		fun = function(name, ...) Spring.Echo("UNSYNCED: " .. name) gadget[callIn](name, ...) end
		gadgetHandler:AddSyncAction(callIn, fun)
	end
end

end
