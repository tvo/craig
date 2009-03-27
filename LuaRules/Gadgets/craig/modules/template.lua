-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
The module interface is as follows:

All the LUA files in /modules/ are parsed and run a single time for the entire
gadget. They execute in the global (gadget) environment, and can set up gadget-
wide local variables / speedups, etc.  Execution of a module file should return
a single function.  This function is called to instantiate a copy of the module
for each AI controlled team.  The team table is the sole argument to the
function, and the module table is the sole return value.  The module table
may contain callins similar to gadget callins, with four main differences:
  1) module callins are only called for the team the module belongs to
  2) module callins are NOT self calls: do not use colons in their declaration!
  3) UnitCreated and UnitFinished may return true to indicate the module wants
     to take ownership of the unit.
  4) if any module "takes ownership", subsequent unit callins for that unit
     ONLY go to the module owning the unit.
]]--

--------------------------------------------------------------------------------
local function CreateModule(team)
local Mod = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function Mod.GameStart()
end

function Mod.GameFrame(f)
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function Mod.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	return false
end

function Mod.UnitFinished(unitID, unitDefID, unitTeam)
	return false
end

function Mod.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

--------------------------------------------------------------------------------
--
--  Initialization
--

return Mod
end

--------------------------------------------------------------------------------
return CreateModule
