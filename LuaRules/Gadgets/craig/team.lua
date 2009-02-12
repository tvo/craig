-- Author: Tobi Vollebregt

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

local team = CreateTeam(myTeamID, myAllyTeamID, mySide)

function team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
function team.UnitFinished(unitID, unitDefID, unitTeam)
function team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
function team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
function team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
]]--

function CreateTeam(myTeamID, myAllyTeamID, mySide)

local team = {}
local buildsiteFinder = CreateBuildsiteFinder(myTeamID)

local unitBuildOrder = gadget.unitBuildOrder
local baseBuildOrder = gadget.baseBuildOrder
local baseBuildIndex = 0
local baseBuilders = gadget.baseBuilders

local baseBuildOptions = {} -- map of unitDefIDs (buildOption) to unitDefIDs (builders)
local currentBuild          -- one unitDefID
local currentBuilder        -- one unitID

local delayedCallQue = { first = 1, last = 0 }

local Log = function (message)
	Log("Team[" .. myTeamID .. "] " .. message)
end

local function DelayedCall(fun)
	delayedCallQue.last = delayedCallQue.last + 1
	delayedCallQue[delayedCallQue.last] = fun
end

local function PopDelayedCall()
	local ret = delayedCallQue[delayedCallQue.first]
	if ret then
		delayedCallQue.first = delayedCallQue.first + 1
	end
	return ret
end

local function BuildBase()
	-- nothing to do if something is still being build
	if currentBuild then return end

	local unitDefID = baseBuildOrder[baseBuildIndex + 1]
	-- restart queue when finished
	if not unitDefID then
		baseBuildIndex = 0
		unitDefID = baseBuildOrder[1]
	end

	local builderDefID = baseBuildOptions[unitDefID]
	-- nothing to do if we have no builders available yet who can build this
	if not builderDefID then return end

	local builders = Spring.GetTeamUnitsByDefs(myTeamID, builderDefID)
	if not builders then Log("internal error: Spring.GetTeamUnitsByDefs returned nil") return end

	local builderID = builders[1]
	if not builderID then Log("internal error: Spring.GetTeamUnitsByDefs returned empty array") return end

	-- give the order to the builder
	local x,y,z,facing = buildsiteFinder.FindBuildsite(builderID, unitDefID)
	Spring.GiveOrderToUnit(builderID, -unitDefID, {x,y,z,facing}, {})

	-- give guard order to the other builders with the same def
	for i=2,#builders do
		Spring.GiveOrderToUnit(builders[i], CMD.GUARD, {builderID}, {})
	end

	-- TODO: give guard order to all builders with another def

	-- finally, register the build as started
	baseBuildIndex = baseBuildIndex + 1
	currentBuild = unitDefID
	currentBuilder = builderID
end

local function BuildBaseInterrupted(violent)
	if violent then
		baseBuildIndex = baseBuildIndex - 1
	end
	currentBuild = nil
	currentBuilder = nil
end

function team.GameFrame(f)
	Log("GameFrame")

	while true do
		local fun = PopDelayedCall()
		if fun then fun() else break end
	end

	BuildBase()
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

-- Currently unitTeam always equals myTeamID (enforced in gadget)

function team.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	buildsiteFinder.UnitCreated(unitID, unitDefID, unitTeam, builderID)
end

function team.UnitFinished(unitID, unitDefID, unitTeam)
	Log("UnitFinished "..unitID.."/"..unitDefID.."/"..unitTeam)

	-- queue unitBuildOrders if we have any for this unitDefID
	if unitBuildOrder[unitDefID] then
		DelayedCall(function()
			for _,bo in ipairs(unitBuildOrder[unitDefID]) do
				Log("Queueing " .. UnitDefs[bo].humanName)
				if UnitDefs[bo].speed == 0 then
					-- It's not recommended to put buildings in unitBuildOrder,
					-- but keep it supported anyway.. might be useful sometime.
					local x,y,z,facing = buildsiteFinder.FindBuildsite(unitID, bo)
					Spring.GiveOrderToUnit(unitID, -bo, {x,y,z,facing}, {"shift"})
				else
					Spring.GiveOrderToUnit(unitID, -bo, {}, {})
				end
			end
		end)
	end

	-- update base building
	if baseBuilders[unitDefID] then
		for _,bo in ipairs(UnitDefs[unitDefID].buildOptions) do
			if not baseBuildOptions[bo] then
				Log("Base can now build " .. UnitDefs[bo].humanName)
				baseBuildOptions[bo] = unitDefID --{}
			end
			--baseBuildOptions[bo][unitDefID] = true
		end
	end
	if unitDefID == currentBuild then
		BuildBaseInterrupted(false)
	end
end

function team.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	buildsiteFinder.UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)

	-- update baseBuildOptions
	if baseBuilders[unitDefID] then
		baseBuildOptions = {}
		local unitCounts = Spring.GetTeamUnitsCounts(myTeamID)
		for _,ud in ipairs(baseBuilders) do
			if unitCounts[ud] and unitCounts[ud] > 0 then
				for _,bo in ipairs(UnitDefs[ud].buildOptions) do
					if not baseBuildOptions[bo] then
						baseBuildOptions[bo] = ud --{}
					end
					--baseBuildOptions[bo][ud] = true
				end
			end
		end
	end

	-- update base building
	if unitDefID == currentBuild then
		BuildBaseInterrupted(true)
	end
	if unitID == currentBuilder then
		BuildBaseInterrupted(true)
	end
end

function team.UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	team.UnitDestroyed(unitID, unitDefID, unitTeam)
end

function team.UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	team.UnitCreated(unitID, unitDefID, unitTeam, nil)
	local _, _, inBuild = Spring.GetUnitIsStunned(unitID)
	if not inBuild then
		team.UnitFinished(unitID, unitDefID, unitTeam)
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--
Log("assigned to " .. gadget:GetInfo().name .. " (allyteam: " .. myAllyTeamID .. ", side: " .. mySide .. ")")

return team
end
