
-- Wait
-- id: player id
-- mode: switch to this mode
function fai_wait(id,mode)
	-- check timer
	if vai_timer[id]>0 then
		-- decrease
		vai_timer[id]=vai_timer[id]-1
	else
		-- switch mode
		vai_mode[id]=mode
	end
end

-- Angle Delta
-- a1: angle 1
-- a2: angle 2
function fai_angledelta(a1,a2)
	local d=(a2-a1)%360
	if d<-180 then d=d+360 end
	if d>180 then d=d-360 end
	return d
end

-- Angle to
-- x1|y1: position 1
-- x2|y2: position 2
function fai_angleto(x1,y1,x2,y2)
	return math.deg(math.atan2(x2-x1,y1-y2))
end

-- Checks if table t has element e
-- t: table
-- e: element
function fai_contains(t,e)
	for _, value in pairs(t) do
		if value == e then
			return true
		end
	end
	return false
end

-- Check if player has item in certain slot
-- id: player id
-- slot: slot
function fai_playerslotitems(id,slot)
	local items=playerweapons(id)
	for i=1,#items do
		if itemtype(items[i],"slot")==slot then
			return true
		end
	end
	return false
end

-- Walk Aim - aim in walking direction
-- id: player
function fai_walkaim(id)
	local x=player(id,"x")
	local y=player(id,"y")
	local angle=math.deg(math.atan2(x-(vai_px[id] or x),(vai_py[id] or y)-y))
	ai_aim(id,x+math.sin(math.rad(angle))*150,y-math.cos(math.rad(angle))*150)
	if vai_px[id]~=x then vai_px[id]=x end
	if vai_py[id]~=y then vai_py[id]=y end
end

-- Are two given players enemies?
-- id1: player 1
-- id2: player 2
function fai_enemies(id1,id2)
	-- Enemies if teams are different
	if player(id1,"team")~=player(id2,"team") then
		if player(id1,"team")>=2 and player(id2,"team")>=2 then
			-- Special case VIP: CTs (team 2) and VIP (team 3) are never enemies!
			return false
		else
			return true
		end
	-- Enemies if game mode is deathmatch
	elseif vai_set_gm==1 then
		return true
	end
	-- Otherwise: No Enemies
	return false
end

-- Get random (living) teammate
-- id: get random mate of this player (player id)
function fai_randommate(id)
	-- Get Team
	local team=player(id,"team")
	if team>2 then
		team=2
	end
	
	-- Get Random from Player Table
	local players=player(0,"team"..team.."living")
	if #players==0 then
		return 0
	end
	for i=1,10 do
		local randid=math.random(1,#players)
		if players[randid]~=id then
			return players[randid]
		end
	end
	
	-- No mate found
	return 0
end

-- Set destination to random adjacent tile
function fai_randomadjacent(id)
	px=player(id,"tilex")
	py=player(id,"tilex")
	
	-- 20 Search attempts
	for i=1,20 do
		-- Get coordinates of random adjacend tile
		x=px+math.random(-1,1)
		y=py+math.random(-1,1)
		
		-- It must not be the tile of the player...
		if (x~=px or y~=py) then
			-- ... and it must be walkable
			if tile(x,y,"walkable") then
				-- If all this is true, set it!
				vai_goalx[id]=x
				vai_goaly[id]=y
				return
			end
		end
	end
end

---
---Returns the Euclidean distance between the two points
---
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function fai_distance2d(x1, y1, x2, y2)
    return math.sqrt(math.pow((x2-x1), 2) + math.pow((y2-y1), 2))
end

---Gets a random walkable tile position
---@return number
---@return number
function fai_getrandomtile()
	local maxx = map("xsize")
	local maxy = map("ysize")
	local tilex = -1
	local tiley = -1
	
	for i = 1, 20, 1 do
		tilex = math.random(0, maxx)
		tiley = math.random(0, maxy)

		if tile(tilex, tiley, "deadly") == false and tile(tilex, tiley, "walkable") == true then
			return tilex, tiley
		end
	end

	return -1, -1
end

---Gets the vector magnitude
---@param x number
---@param y number
---@return number
function fai_vector_magnitude(x, y)
	return math.sqrt(x*x + y*y)
end

---Gets the normalized vector
---@param x number
---@param y number
---@return number x#Normalized vector X
---@return number y#Normalized vector Y
function fai_vector_normalized(x, y)
	local mag = fai_vector_magnitude(x,y)
	local normalx = x/mag
	local normaly = y/mag
	return normalx, normaly
end

--- makes a deep copy of a given table (the 2nd param is optional and for internal use)
---
--- circular dependencies are correctly copied.
---
--- From: http://lua-users.org/wiki/PitLibTablestuff
function table.Copy(t, lookup_table)

	local copy = {}
		for i,v in t do
			if type(v) ~= "table" then
					copy[i] = v
			else
				lookup_table = lookup_table or {}
				lookup_table[t] = copy
			if lookup_table[v] then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = table.Copy(v,lookup_table) -- not yet copied. copy it.
			end
		end
	end

	return copy
end

--[[---------------------------------------------------------
	Name: Empty( tab )
	Desc: Empty a table
-----------------------------------------------------------]]
function table.Empty( tab )
	for k, v in pairs( tab ) do
		tab[ k ] = nil
	end
end

--[[---------------------------------------------------------
	Name: IsEmpty( tab )
	Desc: Returns whether a table has iterable items in it, useful for non-sequential tables
-----------------------------------------------------------]]
function table.IsEmpty( tab )
	return next( tab ) == nil
end

--[[---------------------------------------------------------
	Name: HasValue
	Desc: Returns whether the value is in given table
-----------------------------------------------------------]]
function table.HasValue( t, val )
	for k, v in pairs( t ) do
		if ( v == val ) then return true end
	end
	return false
end

--[[---------------------------------------------------------
	Name: table.Count( table )
	Desc: Returns the number of keys in a table
-----------------------------------------------------------]]
function table.Count( t )
	local i = 0
	for k in pairs( t ) do i = i + 1 end
	return i
end

--[[---------------------------------------------------------
	Name: table.Random( table )
	Desc: Return a random key
-----------------------------------------------------------]]
function table.Random( t )
	local rk = math.random( 1, table.Count( t ) )
	local i = 1
	for k, v in pairs( t ) do
		if ( i == rk ) then return v, k end
		i = i + 1
	end
end