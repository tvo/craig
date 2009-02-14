-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

local base = CreateBaseBuildMgr(myTeamID, myAllyTeamID, mySide, Log)

function base.GameFrame(f)
function base.UnitCreated(unitID, unitDefID, unitTeam, builderID)
function base.UnitFinished(unitID, unitDefID, unitTeam)
function base.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
]]--

function CreateBaseBuildMgr(myTeamID, myAllyTeamID, mySide, Log)

local base = {}

-- Base building (one global buildOrder)
local buildsiteFinder = CreateBuildsiteFinder(myTeamID)
local baseBuildOrder = gadget.baseBuildOrder[mySide]
local baseBuildIndex = 0
local baseBuilders = gadget.baseBuilders -- set of all unitDefIDs which are base builders
local myBaseBuilders = {}   -- set of all unitIDs which are the base builders of the team
local baseBuildOptions = {} -- map of unitDefIDs (buildOption) to unitDefIDs (builders)
local baseBuildOptionsDirty = false
local currentBuild          -- one unitDefID
local currentBuilder        -- one unitID
local bUseClosestBuildSite = true

-- does not modify sim; is called from outside GameFrame
local function BuildBaseInterrupted(violent)
	if violent then
		-- enforce randomized next buildsite, instead of
		-- hopelessly trying again and again on same place
		bUseClosestBuildSite = false
		baseBuildIndex = baseBuildIndex - 1
		Log("Reset baseBuildIndex to " .. baseBuildIndex)
	end
	currentBuild = nil
	currentBuilder = nil
end

-- modifies sim, only call this in GameFrame! (or use DelayedCall)
local function BuildBase()
	if currentBuild then
		local unitID = Spring.GetUnitIsBuilding(currentBuilder)
		local vx,vy,vz = Spring.GetUnitVelocity(currentBuilder)
		local _,_,inBuild = Spring.GetUnitIsStunned(currentBuilder)
		-- consider build aborted when:
		-- * the builder isn't building anymore (unitID == nil)
		-- * the builder doesn't exist anymore (vx == nil)
		-- * the builder is not moving, except when he is being build!
		if (unitID == nil) and ((vx == nil) or ((vx*vx + vz*vz < 0.0001) and (not inBuild))) then
			Log(UnitDefs[currentBuild].humanName .. " was finished/aborted, but neither UnitFinished nor UnitDestroyed was called")
			BuildBaseInterrupted(true) -- not THAT violent but need to reset baseBuildIndex either way..
		--[[else
			local _,_,inBuild = Spring.GetUnitIsStunned(unitID)
			if not inBuild then
				Log(UnitDefs[currentBuild].humanName .. " was finished, but neither UnitFinished nor UnitDestroyed was called (2)")
				BuildBaseInterrupted(false)
			end]]--
		end
	end

	-- nothing to do if something is still being build
	if currentBuild then return end

	local unitDefID = baseBuildOrder[baseBuildIndex + 1]
	-- restart queue when finished
	if not unitDefID then
		baseBuildIndex = 0
		unitDefID = baseBuildOrder[1]
		Log("Restarted baseBuildOrder, next item: " .. UnitDefs[unitDefID].humanName)
	end

	local builderDefID = baseBuildOptions[unitDefID]
	-- nothing to do if we have no builders available yet who can build this
	if not builderDefID then Log("No builder available for " .. UnitDefs[unitDefID].humanName) return end

	local builders = Spring.GetTeamUnitsByDefs(myTeamID, builderDefID)
	if not builders then Log("internal error: Spring.GetTeamUnitsByDefs returned nil") return end

	local builderID = builders[1]
	if not builderID then Log("internal error: Spring.GetTeamUnitsByDefs returned empty array") return end

	-- give the order to the builder, iff we can find a buildsite
	local x,y,z,facing = buildsiteFinder.FindBuildsite(builderID, unitDefID, bUseClosestBuildSite)
	if not x then Log("Could not find buildsite for " .. UnitDefs[unitDefID].humanName) return end

	Log("Queueing in place: " .. UnitDefs[unitDefID].humanName)
	Spring.GiveOrderToUnit(builderID, -unitDefID, {x,y,z,facing}, {})

	-- give guard order to all our other builders
	for u,_ in pairs(myBaseBuilders) do
		if u ~= builderID then
			Spring.GiveOrderToUnit(u, CMD.GUARD, {builderID}, {})
		end
	end

	-- finally, register the build as started
	baseBuildIndex = baseBuildIndex + 1
	currentBuild = unitDefID
	currentBuilder = builderID

	-- assume next build can safely be close to the builder again
	bUseClosestBuildSite = true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function base.GameFrame(f)
	-- update baseBuildOptions
	if baseBuildOptionsDirty then
		baseBuildOptionsDirty = false
		baseBuildOptions = {}
		local unitCounts = Spring.GetTeamUnitsCounts(myTeamID)
		for ud,_ in pairs(baseBuilders) do
			if unitCounts[ud] and unitCounts[ud] > 0 then
				Log(unitCounts[ud] .. " x " .. UnitDefs[ud].humanName)
				for _,bo in ipairs(UnitDefs[ud].buildOptions) do
					if not baseBuildOptions[bo] then
						Log("Base can now build " .. UnitDefs[bo].humanName)
						baseBuildOptions[bo] = ud --{}
					end
					--baseBuildOptions[bo][ud] = true
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

-- Short circuit callin which would otherwise only forward the call..
base.UnitCreated = buildsiteFinder.UnitCreated

function base.UnitFinished(unitID, unitDefID, unitTeam)
	-- update base building
	if baseBuilders[unitDefID] then
		-- keep track of all builders we've walking around
		myBaseBuilders[unitID] = true
		-- update list of buildings we can build
		for _,bo in ipairs(UnitDefs[unitDefID].buildOptions) do
			if not baseBuildOptions[bo] then
				Log("Base can now build " .. UnitDefs[bo].humanName)
				baseBuildOptions[bo] = unitDefID --{}
			end
			--baseBuildOptions[bo][unitDefID] = true
		end
	end

	if unitDefID == currentBuild then
		Log("CurrentBuild finished")
		BuildBaseInterrupted(false)
	end
end

function base.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)

	-- update baseBuildOptions
	if baseBuilders[unitDefID] then
		myBaseBuilders[unitID] = nil
		baseBuildOptionsDirty = true
	end

	-- update base building
	if unitDefID == currentBuild then
		Log("CurrentBuild destroyed")
		BuildBaseInterrupted(true)
	end
	if unitID == currentBuilder then
		Log("CurrentBuilder destroyed")
		BuildBaseInterrupted(true)
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

if not baseBuildOrder then
	error("C.R.A.I.G. is not configured properly to play as " .. mySide)
end

return base
end
