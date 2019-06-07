-- object scan
-- TIP: To check if a teleporter entrance is ready, check the object 'mode'. mode 1 is ready.

function fai_scanforobject(id)
	
	-- global variables
	local pteam=player(id,"team")
	local health=player(id,"health")
	local maxhealth=player(id,"maxhealth")
	local money=player(id,"money")

	-- Scan Timer
	vai_objectscan[id]=vai_objectscan[id]+-1
	if vai_objectscan[id]<=0 then -- timer is 0 and bot is not already using something.
		vai_objectscan[id]=math.random(150,350)
		
		if vai_mode[id]~=21 or vai_mode[id]~=22 or vai_mode[id]~=23 or vai_mode[id]~=20 then
		
			local objectlist=closeobjects(player(id,"x"),player(id,"y"),224) -- 7 tiles range

			for _,obj in pairs(objectlist) do -- bot will probably use the first object it sees. Objects are sorted by IDs. Maybe we should select a random object instead of always using the first in the list?
				local obtype=object(obj,"type")
				local obteam=object(obj,"team")
				local obx=object(obj,"tilex")
				local oby=object(obj,"tiley")
				local obmode=object(obj,"mode")

				if obteam==pteam then -- object must be from our team
					if obtype==7 then -- dispenser
						if health < maxhealth or money < 16000 then -- check if bot needs to use a dispenser
							fai_gotoobject(id, obx, oby, obtype, obj)
							break
						end
					elseif obtype==13 then -- teleporter entrance
						if obmode==1 then -- teleporter is ready
							fai_gotoobject(id, obx, oby, obtype, obj)
							break
						end
					end
				end
			end
		end
	end
end

function fai_gotoobject(id, obx, oby, obtype, obj)
	-- this function receives the object position but some objects are solid
	local finalx=-1
	local finaly=-1
	local solid=false -- can the bot walk over the object?
	local found=false -- true when we found a valid position
	
	if obtype==7 then
		solid=true -- dispenser is solid
	end
	
	if solid==true then -- change the final destination to the side of the object
		-- being searching for a walkable tile around the object
		-- there are 8 possible positions
		-- x 0, y 0 = object tile
		
		-- position 1. x -1, y -1 (top left)
		if tile(obx-1,oby-1, "walkable")then
			finalx=obx-1
			finaly=oby-1
		-- position 2. x -1, y 0 (middle left)
		elseif tile(obx-1,oby, "walkable") then
			finalx=obx-1
			finaly=oby
		-- position 3. x -1, y 1 (botton left)
		elseif tile(obx-1,oby+1, "walkable") then
			finalx=obx-1
			finaly=oby+1
		-- position 4. x 0, y -1 (middle top)
		elseif tile(obx,oby-1, "walkable") then
			finalx=obx
			finaly=oby-1
		-- position 5. x 0, y 1 (middle botton)
		elseif tile(obx,oby+1, "walkable") then
			finalx=obx
			finaly=oby+1
		-- position 6. x 1, y -1 (top right)
		elseif tile(obx+1,oby-1, "walkable") then
			finalx=obx+1
			finaly=oby-1
		-- position 7. x 1, y 0 (middle right)
		elseif tile(obx+1,oby, "walkable") then
			finalx=obx+1
			finaly=oby
		-- position 8. x 1, y 1 (botton right)
		elseif tile(obx+1,oby+1, "walkable") then
			finalx=obx+1
			finaly=oby+1
		end
	else
		finalx=obx
		finaly=oby
	end
	
	if finalx~=-1 then
		if obtype== 13 then	-- tele entrance
			vai_mode[id]=23 -- special for teleporters
			vai_smode[id]=obj -- smode should store the teleporter ID		
		else
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
	vai_timer[id]=800 -- to do: make this timer based on the bot's money and health
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