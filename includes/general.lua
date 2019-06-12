
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
	py=player(id,"tiley")
	
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
				vai_destx[id]=x
				vai_desty[id]=y
				return
			end
		end
	end
end

-- Set destination to random adjacent tile (entire map version)
function fai_randommaptile(id)
	px=player(id,"tilex")
	py=player(id,"tiley")
	
	-- 40 Search attempts
	for i=1,40 do
		-- Get coordinates of random adjacend tile
		x=math.random(0,map("xsize"))
		y=math.random(0,map("ysize"))
		
		-- It must not be the tile of the player...
		if (x~=px or y~=py) then
			-- ... and it must be walkable
			if tile(x,y,"walkable") then
				-- If all this is true, set it!
				vai_destx[id]=x
				vai_desty[id]=y
				if vai_set_debug==1 then
					print("Random Map Tile returned x: "..x..", y: "..y.."")
				end				
				return
			end
		end
	end
end

-- sets the bot destx and desty to a random tile in a N radius of a specific origin
-- the radius must always be negative
function fai_gettilerandomradius(id, radius, x, y)
	local radius2=math.abs(radius)
	local x2=0
	local y2=0
	
	-- 20 Search attempts
	for i=1,20 do
		x2=math.random(radius,radius2)
		y2=math.random(radius,radius2)
		
		if tile(x+x2,y+y2,"walkable") then
			return x+x2,y+y2
		end
	end
end

-- given an object type, return if it's solid
function fai_isobjectsolid(obtype)
	if obtype==2 or obtype==6 or obtype==13 or obtype==14 or obtype==30 then
		return false
	else
		return true
	end
end

-- this function returns true if an object is enemy
-- id - player id
-- obteam - object Team
-- obtype - object type
function fai_isobjectenemy(id, obteam, obtype)
	local plteam=player(id,"team")
	
	if obtype==30 then -- NPC
		return true
	end
	
	if obteam~=plteam then -- the object is not from the BOT's Team
		if obteam==0 then -- neutral Team
			if obtype==7 or obtype==9 then -- neutral dispenser and supply
				return false
			elseif obtype==1 or obtype>=3 and obtype<=5 or obtype==8 then -- neutral barricade,walls and turret
				return true
			else
				return false
			end
		else -- object is NOT neutral and is NOT from our Team
			if fai_isobjectsolid(obtype)==true then
				return true
			else
				return false
			end
		end
	end
end

-- object free line correction
-- only needed for solid objects
-- x1,y1 - player position
-- x2,y2 - object position
function fai_objflcorrection(x1, y1, x2, y2)
	local rx=0
	local ry=0
	
	-- for x
	if x1>x2 then -- right (object position)
		rx=x2+24
	else -- left, x2>x1
		rx=x2-24
	end
	-- for y
	if y1>y2 then -- botton (object position)
		ry=y2+24
	else -- top, x2>x1
		ry=y2-24
	end
	
	return rx,ry
end

-- get the nearest tile of an object
-- x1,y1 - player tile
-- x2,y2 - object tile
function fai_gettiletoobj(x1, y1, x2, y2)
	local left,right,top,botton=false
	local al,ar,at,ab=0
	
	-- for x
	if x1>x2 then -- right (object position)
		right=true
		ar=270
	else -- left, x2>x1
		left=true
		al=90
	end
	-- for y
	if y1>y2 then -- botton (object position)
		botton=true
		ab=0
	else -- top, x2>x1
		top=true
		at=180
	end
	
	
	
	-- position 1. x -1, y 0 (middle left)
	if tile(x2-1,y2, "walkable") and left==true then
		return x2-1,y2,al
	-- position 2. x 0, y -1 (middle top)
	elseif tile(x2,y2-1, "walkable") and top==true then
		return x2,y2-1,at
	-- position 3. x 0, y 1 (middle botton)
	elseif tile(x2,y2+1, "walkable") and botton==true then
		return x2,y2+1,ab
	-- position 4. x 1, y 0 (middle right)
	elseif tile(x2+1,y2, "walkable") and right==true then
		return x2+1,y2,ar
	end
end

-- check if a bot is low on ammo, used to collect ammo boxes
function fai_lowonammo(id)
	local weaponType = player(id, "weapontype")
	local ammoIn,ammo = playerammo(id, weaponType)
	if vai_set_debug==1 then
		print("BOT "..player(id,"name").." has ammo in: "..ammoIn..", ammo: "..ammo.."")
	end
	
	if playerammo(id, weaponType)==false then -- false, the BOT doesn't have this weapon
		return false
	end
	
	if weaponType>=1 and weaponType<=6 then -- IDs of weapon (secondary) with ammo
		if ammo<25 then
			return true
		else
			return false
		end
	elseif weaponType==10 or weaponType==11 then -- shotguns
		if ammo<10 then
			return true
		else
			return false
		end
	elseif weaponType>=20 and weaponType<=24 then -- SMGs
		if ammo<40 then
			return true
		else
			return false
		end
	elseif weaponType>=30 and weaponType<=39 then -- Rifles
		if ammo<15 then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- get distance
function fai_getdistance(a,b)
	return math.abs(a-b)
end