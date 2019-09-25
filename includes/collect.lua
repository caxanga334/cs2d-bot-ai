--[[

Scan for collectible items every 1-2 seconds.
Try to collect them if possible.

]]--

-- Collect Items
function fai_collect(id)
	
	-- Scan Timer
	vai_itemscan[id]=vai_itemscan[id]+1
	if vai_itemscan[id]>100 then
		vai_itemscan[id]=math.random(0,50)
		
		-- Not collecting yet AND not a zombie?
		if (vai_mode[id]~=6 or vai_mode[id]~=20 or vai_mode[id]~=21 or vai_mode[id]~=22 or vai_mode[id]~=23 or vai_mode[id]~=11) and not(player(id,"team")==1 and vai_set_gm==4) then
			-- Find and scan close items (8 tiles around)
			local items=closeitems(id,8)
			for i=1,#items do
				-- Not on same tile?
				if item(items[i],"x")~=player(id,"tilex") or item(items[i],"y")~=player(id,"tiley") then
					local itype=item(items[i],"type")
					local slot=itemtype(itype,"slot")
					local collect=false
					if slot==1 then
						-- Primary
						if not fai_playerslotitems(id,1) and player(id,"team")~=3 then
							collect=true
						else -- bot already have a primary, check tier
							if fai_isbetterweapon(id,itype) then
								collect=true
							end
						end
					elseif slot==2 then
						-- Secondary
						if not fai_playerslotitems(id,2) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==3 then
						-- Melee
						if not fai_contains(playerweapons(id),itype) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==4 then
						-- Grenades
						if not fai_contains(playerweapons(id),itype) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==5 then
						-- Special
						if itype==55 then
							-- Bomb
							if player(id,"team")==1 then
								collect=true
							end
						elseif itype==77 and not fai_contains(playerweapons(id),77) and player(id,"team")~=3 then
							collect=true -- collect mines
						elseif itype==87 and not fai_contains(playerweapons(id),87) and player(id,"team")~=3 then
							collect=true -- collect laser mines
						end
					elseif slot==6 then
						-- ??
						if not fai_contains(playerweapons(id),itype) and player(id,"team")~=3 then
							collect=true
						end					
					elseif slot==0 then
						-- No Slot Items
						if itype==70 or itype==71 then
							-- Flags
							collect=true
						elseif itype>=66 and itype<=68 and player(id,"money")<16000 then
							-- Money
							collect=true
						elseif itype>=64 and itype<=65 and player(id,"health")<player(id,"maxhealth") then
							-- Health
							collect=true
						elseif itype==57 and player(id,"armor")<65 then
							-- Armor (kevlar)
							collect=true
						elseif itype==58 and player(id,"armor")<100 then
							-- Armor (kevlar+helm)
							collect=true
						elseif itype==79 and player(id,"armor")<=100 then
							-- Armor (light)
							collect=true
						elseif itype==80 and player(id,"armor")<=201 then
							-- Armor (medium)
							collect=true
						elseif itype==81 and player(id,"armor")<=202 then
							-- Armor (heavy)
							collect=true
						elseif itype==82 and player(id,"armor")<=203 then
							-- Armor (medic)
							collect=true
						elseif itype==83 and player(id,"armor")<=204 then
							-- Armor (super)
							collect=true
						elseif itype==84 and player(id,"armor")<=100 then -- only pick up stealth armor if we don't have any special armor.
							-- Armor (stealth)
							collect=true
						elseif itype==56 and player(id,"defusekit")==false and player(id,"team")==2 then -- only cts should collect defuse kits
							-- Collect defuse kit
							collect=true
						elseif itype==59 and player(id,"nightvision")==false then
							-- Collect night vision
							collect=true
						elseif itype==60 and player(id,"gasmask")==false then
							-- Collect gas mask
							collect=true
						elseif itype==61 and fai_lowonammo(id,0)==true then
							-- Collect primary ammo
							collect=true
						elseif itype==62 and fai_lowonammo(id,1)==true then
							-- Collect secondary ammo
							collect=true
						end
					end
					
					--Perform collect?
					if collect then
						local objectid = objectat(item(items[i],"x"), item(items[i],"y"))
						
						if objectid > 0 then
							local obtype=object(objectid, "type")
							if fai_isobjectsolid(obtype) == true then
								break -- do not collect items inside solid objects
							end
						end
						
						if not tile(item(items[i],"x"), item(items[i],"y"), "walkable") then -- item must be on an walkable tile
							break
						end
						
						vai_mode[id]=6
						vai_smode[id]=itype
						vai_destx[id]=item(items[i],"x")
						vai_desty[id]=item(items[i],"y")
						break
					end
					
				end
			end
		end
	end
end

-- returns the tier of the given weapon
function fai_getweapontier(weapon)
	local tier=0
	
	if weapon == 10 or weapon == 11 then -- Shotguns
		tier=1
	end
	
	if weapon >= 20 and weapon <= 24 then -- SMGs
		tier=2
	end
	
	if weapon >= 30 and weapon <= 39 then -- Rifles + Snipers
		tier=3
	end
	
	if weapon >= 46 and weapon <= 49 then -- Specials
		tier=4
	end
	
	if weapon == 90 or weapon == 91 then -- M134 and FN F2000
		tier=4
	end
	
	if weapon == 45 then -- Laser
		tier=5
	end
	
	return tier
end

-- returns the best weapon the bot have
function fai_getbesttier(id)
	local weaponstable=playerweapons(id)
	local tier=0
	local weapon=0
	
	for _, value in pairs(weaponstable) do
		if value == 10 or value == 11 then
			tier=1
			weapon=value
			break
		end
		
		if value >= 20 and value <= 24 then
			tier=2
			weapon=value
			break
		end
		
		if value >= 30 and value <= 39 then
			tier=3
			weapon=value
			break
		end
		
		if value >= 46 and value <= 49 then
			tier=4
			weapon=value
			break
		end
		
		if value == 90 or value == 91 then
			tier=4
			weapon=value
			break
		end
		
		if value == 45 then
			tier=5
			weapon=value
			break
		end
	end

	return weapon,tier
end

-- returns true if it's a better weapon
-- param id: bot ID
-- param item: item TYPE ID
function fai_isbetterweapon(id,item)
	local itemtier=fai_getweapontier(item)
	local currentitem,currenttier=fai_getbesttier(id) -- gets the bot's current wep tier and weapon type id
	
	if itemtier == 0 then
		return false
	end
	
	if itemtier <= currenttier then
		return false
	end
	
	
	ai_selectweapon(id,currentitem)
	ai_drop(id)
	return true
end

-- returns the bot's primary weapon
function fai_getprimaryweapon(id)
	local weaponstable=playerweapons(id)
	local weapon=0
	
	for _, value in pairs(weaponstable) do
		if value == 10 or value == 11 then
			weapon=value
			break
		end
		
		if value >= 20 and value <= 24 then
			weapon=value
			break
		end
		
		if value >= 30 and value <= 39 then
			weapon=value
			break
		end
		
		if value >= 46 and value <= 49 then
			weapon=value
			break
		end
		
		if value == 90 or value == 91 then
			weapon=value
			break
		end
		
		if value == 45 then
			weapon=value
			break
		end
	end

	return weapon
end

-- returns the bot's secondary weapon
function fai_getsecondaryweapon(id)
	local weaponstable=playerweapons(id)
	local weapon=0
	
	for _, value in pairs(weaponstable) do
		if value == 1 or value == 6 then
			weapon=value
			break
		end
	end

	return weapon
end

-- check if a bot is low on ammo, used to collect ammo boxes
-- params: id = bot ID | type = 0 for primary, 1 for secondary
function fai_lowonammo(id,type)
	local weaponType=0
	local ammoIn,ammo=0
	local weaponType=0
	
	if type == 0 then
		weaponType=fai_getprimaryweapon(id)
	else
		weaponType=fai_getsecondaryweapon(id)
	end
	
	local ammoIn,ammo=playerammo(id,weaponType)
	
	if playerammo(id,weaponType)==false then -- false, the BOT doesn't have this weapon
		return false
	end
	
	if ammoIn==nil then
		return false
	end
	
	if ammo==nil then
		return false
	end
	
	if vai_set_debug==1 then
		print("BOT "..player(id,"name").." has ammo in: "..ammoIn..", ammo: "..ammo.."")
	end
	
	if weaponType>=1 and weaponType<=6 then -- IDs of weapon (secondary) with ammo
		if ammo<25 then
			return true
		end
	elseif weaponType==10 or weaponType==11 then -- shotguns
		if ammo<10 then
			return true
		end
	elseif weaponType>=20 and weaponType<=24 then -- SMGs
		if ammo<40 then
			return true
		end
	elseif weaponType>=30 and weaponType<=39 then -- Rifles
		if ammo<15 then
			return true
		end
	elseif weaponType== 40 or weaponType== 46 then
		if ammo<50 then
			return true
		end
	elseif weaponType== 45 then
		if ammo<10 then
			return true
		end
	elseif weaponType== 47 then
		if ammo<2 then
			return true
		end
	elseif weaponType== 48 or weaponType== 49 then
		if ammo<20 then
			return true
		end
	elseif weaponType== 90 then
		if ammo<100 then
			return true
		end
	elseif weaponType== 91 then
		if ammo<30 then
			return true
		end
	end
	
	return false
end