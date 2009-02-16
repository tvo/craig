-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- based on unit_WaypointDragger.lua by Kloot

local GetGameSeconds = Spring.GetGameSeconds
local GetMouseState = Spring.GetMouseState

local WorldToScreenCoords = Spring.WorldToScreenCoords
local TraceScreenRay = Spring.TraceScreenRay

local floor = math.floor
local mod = math.fmod
local sqrt = math.sqrt

local glVertex = gl.Vertex
local glBeginEnd = gl.BeginEnd
local glColor = gl.Color
local glLineWidth = gl.LineWidth
local glLineStipple = gl.LineStipple
local glDrawGroundCircle = gl.DrawGroundCircle

local shiftKey = 304
local controlKey = 306
local altKey = 308
local shiftPressed = false
local controlPressed = false
local altPressed = false
local lmbOld = false

local selectedWaypoint
local selectedTargetWaypoint -- for connecting waypoints

local lastWaypointID = 0

-- Format: { id1 = { x1, y1, z1, id = id1 }, id2 = { x2, y2, z2, id = id2 }, ... }
local waypoints = {}

-- Format: { [concat(id1, id2)] = true, [concat(id3, id4)] = true, ... }
local connections = {}



local function AddWaypoint(x, y, z)
	lastWaypointID = lastWaypointID + 1
	waypoints[lastWaypointID] = { x, y, z, id = lastWaypointID }
	return waypoints[lastWaypointID]
end



local function ToggleConnection(a, b)
	if (a.id > b.id) then a,b = b,a end
	local key = 4096 * a.id + b.id
	if connections[key] then
		connections[key] = nil
	else
		connections[key] = { a, b }
	end
end


local function AddConnection(a, b)
	if (a.id > b.id) then a,b = b,a end
	local key = 4096 * a.id + b.id
	if (not connections[key]) then
		connections[key] = { a, b }
	end
end



-- Sort for deterministic serialization (better for version control..)

local function Sort(t, compare)
	local i = 0
	local ret = {}
	for k, v in pairs(t) do
		i = i + 1
		ret[i] = v
	end
	table.sort(ret, compare)
	return ret
end

local function Save()
	local fname = "craig_maps/" .. Game.mapName .. ".lua"
	local f,err = io.open(fname, "w")
	if (not f) then
		Spring.Echo(err)
		return
	end
	f:write("local w = {\n")
	for i,waypoint in ipairs(Sort(waypoints, function(a, b) return a.id < b.id end)) do
		f:write("\t{ x = "..floor(waypoint[1])..", y = "..floor(waypoint[2])..", z = "..floor(waypoint[3]).." },\n")
		waypoint.index = i
	end
	f:write("}\n\n")
	for _,conn in ipairs(Sort(connections, function(a, b)
			if a[1].index < b[1].index then return true end
			if a[1].index > b[1].index then return false end
			return a[2].index < b[2].index end)) do
		local left = "w["..conn[1].index.."]"
		local right = "w["..conn[2].index.."]"
		-- connect in two directions
		f:write(left.."[#"..left.."+1] = "..right.."\n")
		f:write(right.."[#"..right.."+1] = "..left.."\n")
	end
	f:write("\nreturn w\n")
	f:close()
	Spring.Echo("Saved to: " .. fname)
end

local function Load()
	-- load chunk
	local fname = "craig_maps/" .. Game.mapName .. ".lua"
	local chunk,err = loadfile(fname)
	if (not chunk) then
		Spring.Echo(err)
		return
	end
	-- execute chunk
	local data = chunk()
	-- clear any existing data
	lastWaypointID = 0
	waypoints = {}
	connections = {}
	for _,v in ipairs(data) do
		v.waypoint = AddWaypoint(v.x, v.y, v.z)
	end
	for _,v in ipairs(data) do
		for _,w in ipairs(v) do
			AddConnection(v.waypoint, w.waypoint)
		end
	end
	Spring.Echo("Loaded from: " .. fname)
end



function widget:GetInfo()
	return {
		name      = "Waypoint Editor",
		desc      = "Waypoint Editor for C.R.A.I.G.",
		author    = "Tobi Vollebregt (based on WaypointDragger by Kloot)",
		date      = "February 16, 2009",
		license   = "GNU GPL v2",
		layer     = 5,
		enabled   = false
	}
end

function widget:Initialize()
	Load()
end

function widget:Shutdown()
	Save()
end



function widget:KeyPress(key, modifier, isRepeat)
	if (modifier.shift) then
		shiftPressed = true
	end
	if (modifier.alt) then
		altPressed = true
	end
	if (modifier.ctrl) then
		controlPressed = true
	end
	if (key == 110) then
		-- new waypoint 'N'
		local mx, my, lmb, _, _ = GetMouseState()
		local _, coors = TraceScreenRay(mx, my, true)
		if (coors ~= nil) then
			AddWaypoint(unpack(coors))
		end
	end
	if (key == 109) then
		-- delete waypoint 'M'
		if (selectedWaypoint ~= nil) then
			for k,v in pairs(connections) do
				if (v[1] == selectedWaypoint) or (v[2] == selectedWaypoint) then
					connections[k] = nil
				end
			end
			waypoints[selectedWaypoint.id] = nil
			selectedWaypoint = nil
			selectedTargetWaypoint = nil
		end
	end
	if (key == 115) then
		-- save data 'S'
		Save()
	end
	if (key == 108) then
		-- load data 'L'
		Load()
	end
end



function widget:KeyRelease(key)
	if (key == shiftKey) then
		shiftPressed = false
	end
	if (key == altKey) then
		altPressed = false
	end
	if (key == controlKey) then
		controlPressed = false
	end
end



function GetDist(x, y, p, q)
	local dx = x - p
	local dy = y - q
	return sqrt(dx * dx + dy * dy)
end



function UpdateWaypoint(mx, my)
	local _, coors = TraceScreenRay(mx, my, true)
	local dict = {}

	if (coors ~= nil) and (selectedWaypoint ~= nil) then
		if (selectedTargetWaypoint ~= nil) then
			ToggleConnection(selectedWaypoint, selectedTargetWaypoint)
		else
			-- move a waypoint
			local x, y, z = coors[1], coors[2], coors[3]
			selectedWaypoint[1], selectedWaypoint[2], selectedWaypoint[3] = x, y, z
		end
	end
end



local function MouseReleased(mx, my)
	UpdateWaypoint(mx, my)
end


local function FindWaypoint(mx, my)
	for _, waypoint in pairs(waypoints) do
		local x, y, z = waypoint[1], waypoint[2], waypoint[3]
		local p, q = WorldToScreenCoords(x, y, z)
		local d = GetDist(mx, my, p, q)

		if (d < 64) then
			return waypoint
		end
	end
	return nil
end


function widget:Update(_)
	local mx, my, lmb, _, _ = GetMouseState()

	if (not lmb) then
		if (lmbOld) then
			-- we stopped dragging
			MouseReleased(mx, my)
			selectedWaypoint = nil
			selectedTargetWaypoint = nil
		end
	else
		if (not lmbOld) then
			selectedWaypoint = FindWaypoint(mx, my)
		else
			selectedTargetWaypoint = FindWaypoint(mx, my)
			if (selectedWaypoint == selectedTargetWaypoint) then
				selectedTargetWaypoint = nil
			end
		end
	end

	lmbOld = lmb
end



function widget:DrawWorld()
	local mx, my, lmb, _, _ = GetMouseState()
	local _, coors = TraceScreenRay(mx, my, true)

	--glLineWidth(5.0)
	glColor(0.0, 1.0, 0.0, 1.0)

	for _,v in pairs(connections) do
		local a, b = v[1], v[2]

		glBeginEnd(GL.LINES,
			function()
				glVertex(a[1], a[2], a[3])
				glVertex(b[1], b[2], b[3])
			end
		)
	end

	for _, waypoint in pairs(waypoints) do
		local x, y, z = waypoint[1], waypoint[2], waypoint[3]
		local p, q = WorldToScreenCoords(x, y, z)
		local d = GetDist(mx, my, p, q)
		local commandID = waypoint[5]

		if (d < 64) or (waypoint == selectedWaypoint) or (waypoint == selectedTargetWaypoint) then
			glColor(1.0, 1.0, 1.0, 1.0)
			glLineWidth(3.0)
			glDrawGroundCircle(x, y, z, 64, 16)
			glLineWidth(1.0)
			glColor(0.0, 1.0, 0.0, 1.0)
		else
			glDrawGroundCircle(x, y, z, 64, 16)
		end
	end

	if (coors ~= nil) and (selectedWaypoint ~= nil) then
		-- draw line from waypoint to world-coors of mouse cursor
		local x, y, z = selectedWaypoint[1], selectedWaypoint[2], selectedWaypoint[3]
		local k, l, m = coors[1], coors[2], coors[3]
		local pattern = (65536 - 775)
		local shift = floor(mod(GetGameSeconds() * 16, 16))

		glColor(1.0, 1.0, 1.0, 1.0)
		glLineStipple(2, pattern, -shift)
		glBeginEnd(GL.LINES,
			function()
				glVertex(x, y, z)
				glVertex(k, l, m)
			end
		)
		glLineStipple(false)
	end

	--glLineWidth(1.0)
	glColor(1.0, 1.0, 1.0, 1.0)
end
