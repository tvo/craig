-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
This class is implemented as a single function returning a table with public
interface methods.  Private data is stored in the function's closure.

Public interface:

local WaypointMgr = CreateWaypointMgr()

function WaypointMgr.GameFrame(f)
function WaypointMgr.UnitCreated(unitID, unitDefID, unitTeam, builderID)

function WaypointMgr.GetFrontline(myTeamID, myAllyTeamID)
	Returns frontline, previous. Frontline is the set of waypoints adjacent

]]--

function CreateWaypointMgr()

-- constants
local GAIA_TEAM_ID    = Spring.GetGaiaTeamID()
local FLAG_RADIUS     = 230 --from S44 game_flagManager.lua
local WAYPOINT_RADIUS = 230 --taken to be same as flag radius (for now?)
local WAYPOINT_HEIGHT = 100

-- speedups
local Log = Log
local GetUnitsInBox = Spring.GetUnitsInBox
local GetUnitsInCylinder = Spring.GetUnitsInCylinder
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitPosition = Spring.GetUnitPosition
local sqrt = math.sqrt

-- class
local WaypointMgr = {}

-- Array containing the waypoints and adjacency relations
-- Format: { { x = x, y = y, z = z, adj = {}, --[[ more properties ]]-- }, ... }
local waypoints = {}

-- Format: { [team1] = allyTeam1, [team2] = allyTeam2, ... }
local teamToAllyteam = {}

-- caches result of CalculateFrontline..
local frontlineCache = {}

-- caches result of Spring.GetTeamStartPosition
local teamStartPosition = {}


local function GetDist2D(x, z, p, q)
	local dx = x - p
	local dz = z - q
	return sqrt(dx * dx + dz * dz)
end


-- Returns the nearest waypoint to point x, z, and the distance to it.
local function GetNearestWaypoint2D(x, z)
	local minDist = 1.0e20
	local nearest
	for _,p in ipairs(waypoints) do
		local dist = GetDist2D(x, z, p.x, p.z)
		if (dist < minDist) then
			minDist = dist
			nearest = p
		end
	end
	return nearest, minDist
end


-- This calculates the set of waypoints which are
--  1) adjacent to waypoints possessed by an enemy, and
--  2) not possessed by any (other) enemy, and
--  3) reachable from hq, without going through enemy waypoints.
local function CalculateFrontline(myTeamID, myAllyTeamID)
	-- mark all waypoints adjacent to any enemy waypoints,
	-- and create a set of all enemy waypoints in 'blocked'.
	local marked = {}
	local blocked = {}
	for _,p in ipairs(waypoints) do
		if ((p.owner or myAllyTeamID) ~= myAllyTeamID) then
			blocked[p] = true
			for a,_ in pairs(p.adj) do
				if ((a.owner or myAllyTeamID) == myAllyTeamID) then
					marked[a] = true
				end
			end
		end
	end

	-- "perform a Dijkstra" starting at HQ
	local hq = teamStartPosition[myTeamID]
	local previous = PathFinder.Dijkstra(hq, blocked)

	-- now 'frontline' is intersection between 'marked' and 'previous'
	local frontline = {}
	for p,_ in pairs(marked) do
		frontline[p] = previous[p]
	end

	return frontline, previous
end


-- Called everytime a waypoint changes owner.
-- A waypoint changes owner when compared to previous update,
-- a different allyteam now possesses ALL units near the waypoint.
local function WaypointOwnerChange(waypoint, newOwner)
	local oldOwner = waypoint.owner
	waypoint.owner = newOwner

	if (oldOwner ~= nil) then
		-- invalidate cache for oldOwner
		for t,at in pairs(teamToAllyteam) do
			if (at == oldOwner) then
				frontlineCache[t] = nil
			end
		end
	end

	if (newOwner ~= nil) then
		-- invalidate cache for newOwner
		for t,at in pairs(teamToAllyteam) do
			if (at == newOwner) then
				frontlineCache[t] = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Waypoint prototype (Waypoint public interface)
--  TODO: do I actually need this... ?
--

local Waypoint = {}
Waypoint.__index = Waypoint

function Waypoint:GetFriendlyUnitCount(myAllyTeamID)
	return self.allyTeamUnitCount[myAllyTeamID] or 0
end

function Waypoint:GetEnemyUnitCount(myAllyTeamID)
	local sum = 0
	for at,count in pairs(self.allyTeamUnitCount) do
		if (at ~= myAllyTeamID) then
			sum = sum + count
		end
	end
	return sum
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  WaypointMgr public interface
--

function WaypointMgr.GetFrontline(myTeamID, myAllyTeamID)
	if (not frontlineCache[myTeamID]) then
		frontlineCache[myTeamID] = { CalculateFrontline(myTeamID, myAllyTeamID) }
	end
	return unpack(frontlineCache[myTeamID])
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

function WaypointMgr.GameStart()
	-- Can not run this in the initialization code at the end of this file,
	-- because at that time Spring.GetTeamStartPosition seems to always return 0,0,0.
	for _,t in ipairs(Spring.GetTeamList()) do
		if (t ~= GAIA_TEAM_ID) then
			local x, y, z = Spring.GetTeamStartPosition(t)
			if x and x ~= 0 then
				teamStartPosition[t] = GetNearestWaypoint2D(x, z)
			end
		end
	end
end

function WaypointMgr.GameFrame(f)
	-- TODO: what's faster, one GetUnitsInBox query for each team
	-- or a single query and then counting units per allyeam team in LUA?
	-- TODO: spread out update over multiple GameFrames?
	for _,p in ipairs(waypoints) do
		-- Box check (as opposed to Rectangle, Sphere, Cylinder),
		-- because this allows us to easily exclude aircraft.
		local x1, y1, z1 = p.x - WAYPOINT_RADIUS, p.y - WAYPOINT_HEIGHT, p.z - WAYPOINT_RADIUS
		local x2, y2, z2 = p.x + WAYPOINT_RADIUS, p.y + WAYPOINT_HEIGHT, p.z + WAYPOINT_RADIUS
		local allyTeamUnitCount = {}
		for t,at in pairs(teamToAllyteam) do
			local units = GetUnitsInBox(x1, y1, z1, x2, y2, z2, t)
			allyTeamUnitCount[at] = (allyTeamUnitCount[at] or 0) + #units
		end
		local owner = nil
		for at,count in pairs(allyTeamUnitCount) do
			if (owner == nil) then
				if (allyTeamUnitCount[at] > 0) then owner = at end
			else
				if (allyTeamUnitCount[at] > 0) then owner = "disputed" end
			end
		end
		p.allyTeamUnitCount = allyTeamUnitCount
		if (owner ~= "disputed") and (owner ~= p.owner) then
			WaypointOwnerChange(p, owner)
		end
	end
end

--------------------------------------------------------------------------------
--
--  Unit call-ins
--

function WaypointMgr.UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if (UnitDefs[unitDefID].name == "flag") then
		-- This is O(n*m), with n = number of flags and m = number of waypoints.
		local x, y, z = GetUnitPosition(unitID)
		local p, dist = GetNearestWaypoint2D(x, z)
		if (dist < FLAG_RADIUS) then
			p.flags[#p.flags+1] = unitID
			Log("Flag ", unitID, " is near ", p.x, ", ", p.z)
		end
	end
end

--------------------------------------------------------------------------------
--
--  Initialization
--

do

local function LoadFile(filename)
	local text = VFS.LoadFile(filename, VFS.ZIP)
	if (text == nil) then
		Warning("Failed to load: ", filename)
		return nil
	end
	Warning("Map waypoint profile found. Loading waypoints.")
	local chunk, err = loadstring(text, filename)
	if (chunk == nil) then
		Warning("Failed to load: ", filename, "  (", err, ")")
		return nil
	end
	return chunk
end

local function AddWaypoint(x, y, z)
	local waypoint = {
		x = x, y = y, z = z, --position
		adj = {},            --map of adjacent waypoints -> edge distance
		flags = {},          --array of flag unitIDs
		allyTeamUnitCount = {},
	}
	setmetatable(waypoint, Waypoint)
	waypoints[#waypoints+1] = waypoint
	return waypoint
end

local function GetWaypointDist2D(a, b)
	local dx = a.x - b.x
	local dz = a.z - b.z
	return sqrt(dx * dx + dz * dz)
end

local function AddConnection(a, b)
	local dist = GetWaypointDist2D(a, b)
	a.adj[b] = dist
	b.adj[a] = dist
end

-- load chunk
local chunk = LoadFile("LuaRules/Configs/craig/maps/" .. Game.mapName .. ".lua")
if (chunk == nil) then
	Warning("No waypoint profile found. Will not use waypoints on this map.")
	return nil
end

-- execute chunk
setfenv(chunk, { AddWaypoint = AddWaypoint, AddConnection = AddConnection })
chunk()
Log(#waypoints, " waypoints succesfully loaded.")

-- make map of teams to allyTeams
-- this must contain not only AI teams, but also player teams!
for _,t in ipairs(Spring.GetTeamList()) do
	if (t ~= GAIA_TEAM_ID) then
		local _,_,_,_,_,at = Spring.GetTeamInfo(t)
		teamToAllyteam[t] = at
	end
end

end
return WaypointMgr
end
