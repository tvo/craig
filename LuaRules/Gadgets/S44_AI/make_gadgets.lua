#!/usr/bin/lua
-- Author: Tobi Vollebregt

--[[
This LUA script is NOT loaded by Spring, it's solely ment to regenerate
the "proxy" gadgets which load the actual AI for each team.

To run this script LUA 5.1 or newer is required.

The idea is, instead of making a single gadget which will then have to
differentiate between the teams and dispatch callins to the right team,
every team gets it's own gadget.

This script generates those gadgets. They consist of one gadget-global
variable 'AI_NUMBER' which is set to the index of the gadget. After this
assignment the main file of the AI is included, which will then control
the AI for the teamNumberth LUA AI team in the game.
]]--

-- Number of gadgets generated / maximum number of AI teams in game.
local numberOfGadgets = 5

for i = 1,numberOfGadgets do
	local f = assert(io.open("../../../LuaRules/Gadgets/S44_AI_"..i..".lua", "w"))
	f:write([==[
--[[
This is a generated file, DO NOT EDIT!
To regenerate, run make_gadgets.lua in
the LuaRules/Gadgets/S44_AI directory.
]]--
AI_NUMBER = ]==] .. i .. [==[

VFS.Include('LuaRules/Gadgets/S44_AI/main.lua')
]==])
	f:close()
end
