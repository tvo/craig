-- Author: Tobi Vollebregt

local team = {}
local unitTypes = include("LuaRules/Configs/S44_AI/unit_abstraction.lua")

function CreateTeam()
	local retval = {}
	setmetatable(retval, {__index = team})
	return retval
end

function team:Log(message)
	Log("Team[" .. self.teamID .. "] " .. message)
	return
end

function team:Initialize(teamID, allyTeamID, side)
	self.teamID = teamID
	self.allyTeamID = allyTeamID
	self.side = side
	self:Log("assigned to " .. gadget:GetInfo().name .. " (allyteam: " .. allyTeamID .. ", side: " .. side .. ")")
	self.buildsiteFinder = CreateBuildsiteFinder(teamID)
	return
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

-- Currently unitTeam always equals self.teamID

function team:GiveEngineerBuildOrderToHQ(unitID, unitDefID)
	local unitDef = UnitDefs[unitDefID]
	for _,bo in pairs(unitDef.buildOptions) do
		if unitTypes.hqengineer[bo] then
			Spring.GiveOrderToUnit(unitID,-bo,{},{})
		end
	end
end

function team:GiveBuildOrderToEngineer(engID, engDefID, boDefID)
	local x, y, z, facing = self.buildsiteFinder.FindBuildsite(engID, boDefID)
	if x then
		Spring.GiveOrderToUnit(engID, -boDefID, { x, y, z, facing }, {})
	else
		self:Log("Could not find buildsite for " .. UnitDefs[boDefID].humanName)
	end
end

function team:GiveBarracksBuildOrderToEngineer(engID, engDefID)
	local engDef = UnitDefs[engDefID]
	for _,bo in pairs(engDef.buildOptions) do
		if unitTypes.barracks[bo] then
			self:GiveBuildOrderToEngineer(engID, engDefID, bo)
		end
	end
end

function team:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	self.buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if unitTypes.headquarter[unitDefID] then
		self:Log("It's my HQ!")
		self:GiveEngineerBuildOrderToHQ(unitID, unitDefID)
		self:GiveEngineerBuildOrderToHQ(unitID, unitDefID)
	elseif unitTypes.hqengineer[unitDefID] then
		self:Log("It's a HQ engineer!")
		self:GiveBarracksBuildOrderToEngineer(unitID, unitDefID)
	end
end

function team:UnitFinished(unitID, unitDefID, unitTeam)
	--self.buildsiteFinder.UnitFinished(unitID, unitDefID, unitTeam)
end

function team:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	self.buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

function team:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	self:Log("UnitTaken")
	self.buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam)
end

function team:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	self:Log("UnitGiven")
	self.buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam)
end
