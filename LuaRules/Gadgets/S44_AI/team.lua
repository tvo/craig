-- Author: Tobi Vollebregt

local team = {}

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
	return
end

function team:UnitCreated(unitID, unitDefID, builderID)
	self:Log("UnitCreated")
	return
end
