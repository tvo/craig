-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
Module implementing base building.
Relies on buildsite.lua to find build sites.

Possible improvements:
- Rebuild destroyed buildings with higher priority then continuing on BO.
- Split base builder group in two groups when it becomes too big. This would
  allow it to truely expand exponentionally :-)
]]--

--------------------------------------------------------------------------------
local function CreateModule(team)
local BaseMgr = {}

-- constants
local myTeamID = team.myTeamID
local mySide = team.mySide

-- speedups
local GetUnitDefID = Spring.GetUnitDefID
local Log = team.Log

-- Base building (one global buildOrder)
local buildsiteFinder = CreateBuildsiteFinder(myTeamID)
local baseBuildOrder = gadget.baseBuildOrder[mySide]
local baseBuildIndex = 0
local baseBuilders = gadget.baseBuilders -- set of all unitDefIDs which are base builders
local myBaseBuilders = {}   -- set of all unitIDs which are the base builders of the team
local baseBuildOptions = {} -- map of unitDefIDs (buildOption) to unitDefIDs (builders)
local baseBuildOptionsDirty = false
local currentBuildDefID     -- one unitDefID
local currentBuildID        -- one unitID
local currentBuilder        -- one unitID
local bUseClosestBuildSite = true

local function BuildBaseFinished()
	currentBuildDefID = nil
	currentBuildID = nil
	currentBuilder = nil
end

local function BuildBaseInterrupted()
	-- enforce randomized next buildsite, instead of
	-- hopelessly trying again and again on same place
	bUseClosestBuildSite = false
	baseBuildIndex = baseBuildIndex - 1
	return BuildBaseFinished()
end

local function BuildBase()
	if currentBuildDefID then
		if #(Spring.GetUnitCommands(currentBuilder, 1) or {}) == 0 then
			Log(UnitDefs[currentBuildDefID].humanName, " was finished/aborted, but neither UnitFinished nor UnitDestroyed was called")
			BuildBaseInterrupted()
		end
	end

	-- nothing to do if something is still being build
	if currentBuildDefID then return end

	local unitDefID
	local newIndex = baseBuildIndex
	repeat
		newIndex = (newIndex % #baseBuildOrder) + 1
		unitDefID = baseBuildOrder[newIndex]
	until (newIndex == baseBuildIndex) or
		-- check if Spring would block this build (unit restriction)
		((Spring.GetTeamUnitDefCount(myTeamID, unitDefID) or 0) < UnitDefs[unitDefID].maxThisUnit and
		-- check if some part of the AI would block this build
		gadget:AllowUnitCreation(unitDefID, nil, myTeamID))

	local builderDefID = baseBuildOptions[unitDefID]
	-- nothing to do if we have no builders available yet who can build this
	if not builderDefID then Log("No builder available for ", UnitDefs[unitDefID].humanName) return end

	local builders = {}
	for u,_ in pairs(myBaseBuilders) do
		if (GetUnitDefID(u) == builderDefID) then
			builders[#builders+1] = u
		end
	end

	-- get a builder that isn't being build
	local builderID
	for _,u in ipairs(builders) do
		local _,_,inBuild = Spring.GetUnitIsStunned(u)
		if not inBuild then builderID = u break end
	end
	builderID = (builderID or builders[1])
	if not builderID then Log("internal error: no builders were found") return end

	-- give the order to the builder, iff we can find a buildsite
	local x,y,z,facing = buildsiteFinder.FindBuildsite(builderID, unitDefID, bUseClosestBuildSite)
	if not x then Log("Could not find buildsite for ", UnitDefs[unitDefID].humanName) return end

	Log("Queueing in place: ", UnitDefs[unitDefID].humanName)
	GiveOrderToUnit(builderID, -unitDefID, {x,y,z,facing}, {})

	-- give guard order to all our other builders
	for u,_ in pairs(myBaseBuilders) do
		if u ~= builderID then
			GiveOrderToUnit(u, CMD.GUARD, {builderID}, {})
		end
	end

	-- finally, register the build as started
	baseBuildIndex = newIndex
	currentBuildDefID = unitDefID
	currentBuilder = builderID

	-- assume next build can safely be close to the builder again
	bUseClosestBuildSite = true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function BaseMgr.GameFrame(f)
	-- update baseBuildOptions
	if baseBuildOptionsDirty then
		baseBuildOptionsDirty = false
		baseBuildOptions = {}
		local unitCounts = Spring.GetTeamUnitsCounts(myTeamID)
		for ud,_ in pairs(baseBuilders) do
			if unitCounts[ud] and unitCounts[ud] > 0 then
				Log(unitCounts[ud], " x ", UnitDefs[ud].humanName)
				for _,bo in ipairs(UnitDefs[ud].buildOptions) do
					if not baseBuildOptions[bo] then
						Log("Base can now build ", UnitDefs[bo].humanName)
						baseBuildOptions[bo] = ud
					end
				end
			end
		end
	end

	return BuildBase()
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function BaseMgr.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam)

	if (not currentBuildID) and (unitDefID == currentBuildDefID) and (builderID == currentBuilder) then
		currentBuildID = unitID
	end
end

function BaseMgr.UnitFinished(unitID, unitDefID, unitTeam)
	if (unitDefID == currentBuildDefID) and ((not currentBuildID) or (unitID == currentBuildID)) then
		Log("CurrentBuild finished")
		BuildBaseFinished()
	end

	-- update base building
	if baseBuilders[unitDefID] then
		-- keep track of all builders we've walking around
		myBaseBuilders[unitID] = true
		-- update list of buildings we can build
		for _,bo in ipairs(UnitDefs[unitDefID].buildOptions) do
			if not baseBuildOptions[bo] then
				Log("Base can now build ", UnitDefs[bo].humanName)
				baseBuildOptions[bo] = unitDefID
			end
		end
		-- give the builder a guard order on current builder
		if currentBuilder then
			GiveOrderToUnit(unitID, CMD.GUARD, {currentBuilder}, {})
		end
		return true --signal Team.UnitFinished that we will control this unit
	end
end

function BaseMgr.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)

	-- update baseBuildOptions
	if baseBuilders[unitDefID] then
		myBaseBuilders[unitID] = nil
		baseBuildOptionsDirty = true
	end

	-- update base building
	if (unitDefID == currentBuildDefID) and ((not currentBuildID) or (unitID == currentBuildID)) then
		Log("CurrentBuild destroyed")
		BuildBaseInterrupted()
	end
	if unitID == currentBuilder then
		Log("CurrentBuilder destroyed")
		BuildBaseInterrupted()
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

if not baseBuildOrder then
	error("C.R.A.I.G. is not configured properly to play as " .. mySide)
end

return BaseMgr
end

--------------------------------------------------------------------------------
return CreateModule
