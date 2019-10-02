-- object scan
-- TIP: To check if a teleporter entrance is ready, check the object 'mode'. mode 1 is ready.

function fai_scanforobject(id)
	
	-- global variables
	local pteam=player(id,"team")
	local health=player(id,"health")
	local maxhealth=player(id,"maxhealth")
	local money=player(id,"money")
	local weaponstable=playerweapons(id)
	local canupgrade=false
	
	-- checks if the bot contains a wrench
	if fai_contains(weaponstable,74) and money > 8000 then
		canupgrade=true
	end

	-- Scan Timer
	vai_objectscan[id]=vai_objectscan[id]+-1
	if vai_objectscan[id]<=0 then -- timer is 0 and bot is not already using something.
		vai_objectscan[id]=math.random(150,350)
		
		if vai_mode[id] ~= 21 and vai_mode[id]~=9 and vai_mode[id]~=22 and vai_mode[id]~=23 and vai_mode[id]~=20 and vai_mode[id]~=24 and vai_mode[id]~=63 then
		
			local objectlist=closeobjects(player(id,"x"),player(id,"y"),256) -- 8 tiles range
			health = health + 20 -- health tolerance
			money = money + 1500 -- money tolerance

			for _,obj in pairs(objectlist) do -- bot will probably use the first object it sees. Objects are sorted by IDs. Maybe we should select a random object instead of always using the first in the list?
				local obtype=object(obj,"type")
				local obteam=object(obj,"team")
				local obx=object(obj,"tilex")
				local oby=object(obj,"tiley")
				local obmode=object(obj,"mode")
				local builder=object(obj,"player")

				if obteam==pteam then -- object must be from our team
					if obtype==7 then -- dispenser
						if health < maxhealth or money < 16000 then -- check if bot needs to use a dispenser
							fai_gotoobject(id, obx, oby, obtype, obj, 0)
							break
						end
					elseif obtype==13 then -- teleporter entrance
						if obmode==1 then -- teleporter is ready
							fai_gotoobject(id, obx, oby, obtype, obj, 0)
							break
						end
					elseif obtype==8 or obtype==11 and canupgrade then -- turrets and supply
						fai_gotoobject(id, obx, oby, obtype, obj, 1)
						break
					elseif obtype==9 and canupgrade then
						if player(builder,"exists") then
							if not player(builder,"bot") then -- do not upgrade supplies built by bots
								fai_gotoobject(id, obx, oby, obtype, obj, 1)
								break
							end
						end
					end
				end
			end
		end
	end
end

function fai_gotoobject(id, obx, oby, obtype, obj, side)
	-- this function receives the object position but some objects are solid
	local finalx=-1
	local finaly=-1
	local solid=false -- can the bot walk over the object?
	
	if obtype==7 then
		solid=true -- dispenser is solid
	end
	
	if solid==true then -- change the final destination to the side of the object
		if side == 0 then
			finalx,finaly=fai_findbpab(id,obj)
		else
			finalx,finaly=fai_findbpab2(id,obj) -- no diagonals
		end
	else
		finalx=obx
		finaly=oby
	end
	
	if finalx~=-1 then
		if obtype== 13 then	-- tele entrance
			vai_mode[id]=23 -- special for teleporters
			vai_smode[id]=obj -- smode should store the teleporter ID
		elseif obtype==8 or obtype==11 or obtype==9 then
			vai_mode[id]=24 -- upgrade object
			vai_smode[id]=0
			vai_cache[id]=obj -- object ID
		else -- dispenser
			vai_mode[id]=21
			vai_smode[id]=obtype -- smode should store the object type
		end

		vai_destx[id]=finalx
		vai_desty[id]=finaly
		if vai_set_debug==1 then
			print("BOT is using an object! type: "..obtype..", x: "..finalx..", y: "..finaly.."")
		end
	else -- invalid position
		vai_mode[id]=0
		vai_smode[id]=0
	end
end

function fai_usedispenser(id)	
	vai_mode[id]=22
	vai_smode[id]=0
	local timer=0
	local maxhp=player(id,"maxhealth")
	local hp=player(id,"health")
	local money=player(id,"money")
	
	if hp < maxhp then
		timer = ((maxhp - hp) * (101 - vai_set_disphealth)) * 0.2
		timer = math.floor(timer)
	end
	
	if timer < 1 then
		timer = (16000 - money) * 0.1
		timer = math.floor(timer)
	end
	
	vai_timer[id]=timer -- to do: make this timer based on the bot's money and health
end

function fai_usetele(id) -- simply reset the AI on teleporter usage
	vai_mode[id]=0
	vai_smode[id]=0
end

-- checks if a teleporter has been used
function fai_checkteleport(id, obj)
	if object(obj,"exists") then -- teleport exists
		if object(obj,"mode")==0 then -- teleport is not ready
			fai_usetele(id) -- reset
			if vai_set_debug==1 then
				print("Teleporter is not ready, resetting AI!")
			end
		end
	else
		fai_usetele(id) -- teleport does not exists, reset
	end
end

-- make bots upgrade an object
function fai_upgradeobject(id,oid)

	if not object(oid, "exists") or object(oid, "health") < 1 then
		vai_mode[id]=0
	end
	
	local objecttype=object(oid, "type")
	if objecttype == 12 or objecttype == 15 then
		vai_mode[id]=0
	end
	
	if player(id, "money") < 6000 then
		vai_mode[id]=0
	end

	vai_destx[id],vai_desty[id]=fai_findbpab2(id,oid)
	
	-- SUB MODE 0: Go to target object
	if vai_smode[id] == 0 then
		local result=ai_goto(id,vai_destx[id],vai_desty[id])
		if result == 0 then -- failed to find path
			vai_mode[id]=0
		elseif result == 1 then -- bot reached it's destination
			vai_smode[id]=1
		else
			fai_walkaim(id)
		end
	-- SUB MODE 1: Move closer to target object
	elseif vai_smode[id] == 1 then
		local angles=fai_angleto(player(id,"x"),player(id,"y"),object(oid,"x")+16,object(oid,"y")+16)
		local aimx=object(oid,"x")+math.random(-1,1)+16
		local aimy=object(oid,"y")+math.random(-1,1)+16
		ai_aim(id,aimx,aimy)
		local result=ai_move(id,angles)
		if result == 0 then -- bot reached target object
			vai_smode[id]=2
		end
	-- SUB MODE 2: Upgrade the object
	elseif vai_smode[id] == 2 then
		local aimx=object(oid,"x")+math.random(-1,1)+16
		local aimy=object(oid,"y")+math.random(-1,1)+16
		ai_selectweapon(id,74)
		ai_aim(id,aimx,aimy)
		ai_attack(id)
	end
end