local GetGameSeconds = Spring.GetGameSeconds
local GetSelectedUnits = Spring.GetSelectedUnits
local GetCommandQueue = Spring.GetCommandQueue
local GetUnitCommands = Spring.GetUnitCommands
local GetMouseState = Spring.GetMouseState
local GiveOrderToUnit = Spring.GiveOrderToUnit
local SelectUnitArray = Spring.SelectUnitArray

local WorldToScreenCoords = Spring.WorldToScreenCoords
local TraceScreenRay = Spring.TraceScreenRay

local floor = math.floor
local mod = math.fmod
local sqrt = math.sqrt
local getn = table.getn
local insert = table.insert

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
local tweakMode = false
local selectedWaypoint

local noShift = true
local doUpdate = false

local waypoints = {
	{ 6000, 33, 6000 },
	{ 6200, 33, 6000 },
}


function widget:GetInfo()
	return {
		name      = "Waypoint Editor",
		desc      = "Waypoint Editor for C.R.A.I.G.",
		author    = "Tobi Vollebregt (based on WaypointDragger by Kloot)",
		date      = "February 16, 2009",
		license   = "GNU GPL v2",
		layer     = 5,
		enabled   = true
	}
end

function widget:Initialize()
end

function widget:Shutdown()
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



function UpdateWaypoints(mx, my)
	local _, coors = TraceScreenRay(mx, my, true)
	local dict = {}

	if (coors ~= nil) and (selectedWaypoint ~= nil) then
		local x, y, z = coors[1], coors[2], coors[3]
		selectedWaypoint[1], selectedWaypoint[2], selectedWaypoint[3] = x, y, z
	end
end



function MouseReleased(mx, my)
	-- we were dragging a waypoint and released LMB
	-- while holding shift, finalize new waypoint
	UpdateWaypoints(mx, my)

	-- TODO: reselect all units from before LMB was
	-- released via SelectUnitArray(units) for better
	-- alwaysDrawQueue=1 support
end



function widget:Update(_)
	tweakMode = widgetHandler:InTweakMode()
	doUpdate = (shiftPressed or noShift)

	if (doUpdate) then
		local mx, my, lmb, _, _ = GetMouseState()

		if (not lmb) then
			if (lmbOld) then
				-- we stopped dragging
				MouseReleased(mx, my)
				selectedWaypoint = nil
			end
		else
			if (not lmbOld) then
				for i, waypoint in ipairs(waypoints) do
					local x, y, z = waypoint[1], waypoint[2], waypoint[3]
					local p, q = WorldToScreenCoords(x, y, z)
					local d = GetDist(mx, my, p, q)

					if (d < 64) then
						selectedWaypoint = waypoint
					end
				end
			end
		end

		lmbOld = lmb
	end
end



function widget:DrawWorld()
	local mx, my, lmb, _, _ = GetMouseState()
	local _, coors = TraceScreenRay(mx, my, true)

	glColor(1.0, 0.0, 0.0, 1.0)
	glLineWidth(5.0)

	for _, waypoint in pairs(waypoints) do
		local x, y, z = waypoint[1], waypoint[2], waypoint[3]
		local p, q = WorldToScreenCoords(x, y, z)
		local d = GetDist(mx, my, p, q)
		local commandID = waypoint[5]

		glDrawGroundCircle(x, y, z, 64, 16)
	end

	if (coors ~= nil) and (selectedWaypoint ~= nil) then
		-- draw line from waypoint to world-coors of mouse cursor
		local x, y, z = selectedWaypoint[1], selectedWaypoint[2], selectedWaypoint[3]
		local k, l, m = coors[1], coors[2], coors[3]
		local pattern = (65536 - 775)
		local shift = floor(mod(GetGameSeconds() * 16, 16))

		glLineStipple(2, pattern, -shift)
		glBeginEnd(GL.LINES,
			function()
				glVertex(x, y, z)
				glVertex(k, l, m)
			end
		)
		glLineStipple(false)
	end

	glLineWidth(1.0)
	glColor(1.0, 1.0, 1.0, 1.0)
end
