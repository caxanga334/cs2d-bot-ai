-- Engage Enemies
-- Things to note about attacking objects, ai_goto will fail with solid objects.
-- ai_freeline will fail if we target the object center, we must target it's side (solid objects only)
-- It's better to use melee when attacking walls. Barricade can only be destroyed with melee.
-- vai_objx={}; vai_objy={}				-- target obj x|y
-- vai_targetobj={}						-- target (Object)
-- closeobjects returns based on ID, not distace. This is a problem.

function fai_engageobject(id)

	-- ############################################################ Find Target
	
	local px=player(id,"tilex")
	local py=player(id,"tiley")
	local sx=999999 -- shortest x
	local sy=999999 -- shortest y
	
	vai_objreaim[id]=vai_objreaim[id]-1
	if vai_objreaim[id]<0 then
		vai_objreaim[id]=20
		if player(id,"ai_flash")==0 then -- flashed mode is already handled by the player targeting
			-- Not flashed!
			-- search for object
			local objectlist=closeobjects(player(id,"x"),player(id,"y"),224) -- 7 tiles range
			for _,obj in pairs(objectlist) do -- bot will probably use the first object it sees. Objects are sorted by IDs. Maybe we should select a random object instead of always using the first in the list?
				local obtype=object(obj,"type")
				local obteam=object(obj,"team")
				local ox=object(obj,"tilex")
				local oy=object(obj,"tiley")
				
				if fai_isobjectenemy(id, obteam, obtype)==true then
					if obtype==30 or fai_isobjectsolid(obtype)==true then -- NPCs are not solid
						if fai_getdistance(px,sx) < sx then
							sx=fai_getdistance(px,sx)
							vai_targetobj[id]=obj
						end
					else
						vai_targetobj[id]=0 -- do not attack non solid objects for now
					end
				else
					vai_targetobj[id]=0 -- do not attack (team check)
				end
			end
		end
	end
	
	if vai_target[id]>0 then
		vai_targetobj[id]=0 -- Prefer attacking enemies
	end
	
	-- ############################################################ Target in Sight?
	if vai_targetobj[id]>0 then
		if not object(vai_targetobj[id],"exists") then
			-- If target object does not exist anymore -> reset
			vai_targetobj[id]=0
		else
			if object(vai_targetobj[id],"health")>0 then
				-- Cache Positions
				local x1=player(id,"x")
				local y1=player(id,"y")
				local x2=object(vai_targetobj[id],"x")+16 -- +16 for center
				local y2=object(vai_targetobj[id],"y")+16
				vai_objx[id]=x2+16
				vai_objy[id]=y2+16
				local x3,y3=fai_objflcorrection(x1,y1,x2,y2)
				
				-- In Range?
				if math.abs(x1-x2)<420 and math.abs(y1-y2)<235 then
					-- Freeline Scan
					vai_rescan[id]=vai_rescan[id]-1
					if vai_rescan[id]<0 then
						vai_rescan[id]=10
						if math.abs(x1-x2)>30 or math.abs(y1-y2)>30 then 
							if not ai_freeline(id,x3,y3) then
								vai_targetobj[id]=0
								msg("free line failed, object ID: "..vai_targetobj[id].."")
							end
						end
					end
				else
					-- Target player out of range -> reset
					vai_targetobj[id]=0
				end
			else
				-- Target player is dead, spectator or no enemy -> reset
				vai_targetobj[id]=0
			end
		end
	end
	
	-- ############################################################ Aim
	if vai_targetobj[id]>0 then
		vai_aimx[id]=object(vai_targetobj[id],"x")+16
		vai_aimy[id]=object(vai_targetobj[id],"y")+16
		-- Switch to Fight Mode
		if vai_mode[id]~=4 and vai_mode[id]~=5 and vai_mode[id]~=9  and vai_mode[id]~=10 and vai_mode[id]~=12 and vai_mode[id]~=13 and vai_mode[id]~=14 then
			vai_smode[id]=object(vai_targetobj[id],"type")
			vai_mode[id]=9
		end
	end

	ai_aim(id,vai_aimx[id],vai_aimy[id])
	
	-- ############################################################ Attack
	-- attack will be handled in another function
end