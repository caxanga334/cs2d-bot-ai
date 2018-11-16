
-- Engage Enemies
function fai_engage(id)

	local objectscan=1
	-- ############################################################ Find Target
	vai_reaim[id]=vai_reaim[id]-1
	if vai_reaim[id]<0 then
		vai_reaim[id]=20
		if player(id,"ai_flash")==0 then
			-- Not flashed!
			vai_target[id]=ai_findtarget(id)
			if vai_target[id]>0 then
				vai_rescan[id]=0
			end
		else
			-- Flashed! No target! Go to flashed mode
			vai_target[id]=0
			if vai_mode[id]~=8 then
				vai_mode[id]=8
				fai_randomadjacent(id)
			end
		end
		if objectscan==1 then -- NPC scan
			local co=closeobjects(player(id,"x"),player(id,"y"),224,30) -- this returns all ids of npcs in a 224 pixels radius
			if #co~=0 then
				for i=1,#co do
					if object(i,"exist")==true then
						if math.abs(player(id,"x")-object(i,"x"))<315 and math.abs(player(id,"y")-object(i,"y"))<235 then
							vai_targetnpc[id]=i
							vai_npcx[id]=object(i,"x")
							vai_npcy[id]=object(i,"y")
						else
							vai_targetnpc[id]=0
							vai_npcx[id]=0
							vai_npcy[id]=0
						end
					end
				end
			end
		end
		if objectscan==1 then -- BUILDING scan
			local px=player(id,"x")
			local py=player(id,"y")
			local plrteam=player(id,"team")
			local building=closeobjects(px,py,224) -- buildings have multiple IDs, we will filter them later
			if #building~=0 then
				for i=1,#building do
					if object(i,"exist")==true then
						local obx=object(i,"x")
						local oby=object(i,"y")
						local objtype=object(i,"type")
						local objteam=object(i,"team")
						local helpx=0
						local helpy=0
						-- target helper
						if ((py-oby)^2>(px-obx)^2) then
							helpx=16
						else
							if (px-obx)>0 then
								helpx=35
							elseif (px-obx)<0 then
								helpx=-3
							end
						end
						if ((px-obx)^2>(py-oby)^2) then
							helpy=16
						else
							if (py-oby)>0 then
								helpy=35
							elseif (py-oby)<0 then
								helpy=-3
							end
						end
						-- end target helper
						if objteam~=plrteam then -- team check
							if objtype>=3 and objtype<=12 or objtype==15 then
								if math.abs(px-obx)<315 and math.abs(py-oby)<235 then --distance check, is this really needed?
									vai_targetobj[id]=i
									vai_objx[id]=obx+helpx
									vai_objy[id]=oby+helpy
								else
									vai_targetobj[id]=0
									vai_objx[id]=0
									vai_objy[id]=0
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- ############################################################ Target in Sight?
	if vai_target[id]>0 then
		if not player(vai_target[id],"exists") then
			-- If target player does not exist anymore -> reset
			vai_target[id]=0
		else
			if player(vai_target[id],"health")>0 and player(vai_target[id],"team")>0 and fai_enemies(vai_target[id],id)==true then
				-- Cache Positions
				local x1=player(id,"x")
				local y1=player(id,"y")
				local x2=player(vai_target[id],"x")
				local y2=player(vai_target[id],"y")
				
				-- In Range?
				if math.abs(x1-x2)<420 and math.abs(y1-y2)<235 then
					-- Freeline Scan
					vai_rescan[id]=vai_rescan[id]-1
					if vai_rescan[id]<0 then
						vai_rescan[id]=10
						if math.abs(x1-x2)>30 or math.abs(y1-y2)>30 then 
							if not ai_freeline(id,x2,y2) then
								vai_target[id]=0
							end
						end
					end
				else
					-- Target player out of range -> reset
					vai_target[id]=0
				end
			else
				-- Target player is dead, spectator or no enemy -> reset
				vai_target[id]=0
			end
		end
	elseif vai_targetnpc[id]>0 then
		if not object(vai_targetnpc[id],"exists") then
			-- target npc does not exists anymore
			vai_targetnpc[id]=0
		else
			if object(vai_targetnpc[id],"health")>0 then
				if not ai_freeline(id,object(vai_targetnpc[id],"x"),object(vai_targetnpc[id],"y")) then
					vai_targetnpc[id]=0
				end
			else
				vai_targetnpc[id]=0
			end
		end
	elseif vai_targetobj[id]>0 then
		if not object(vai_targetobj[id],"exists") then
			-- target building does not exists anymore
			vai_targetobj[id]=0
		else
			if object(vai_targetobj[id],"health")>0 then
				if not ai_freeline(id,vai_objx[id],vai_objy[id]) then
					vai_targetobj[id]=0
				end
			else
				vai_targetobj[id]=0
			end
		end
	end
	
	-- ############################################################ Aim
	if vai_target[id]>0 then
		vai_aimx[id]=player(vai_target[id],"x")
		vai_aimy[id]=player(vai_target[id],"y")
		-- Switch to Fight Mode
		if vai_mode[id]~=4 and vai_mode[id]~=5 then
			vai_timer[id]=math.random(25,100)
			vai_smode[id]=math.random(0,360)
			vai_mode[id]=4
		end
	elseif vai_targetnpc[id]>0 then
		vai_aimx[id]=object(vai_targetnpc[id],"x")
		vai_aimy[id]=object(vai_targetnpc[id],"y")
		-- Switch to fight mode
		if vai_mode[id]~=9 and vai_mode[id]~=4 and vai_mode[id]~=5 then
			vai_timer[id]=math.random(25,100)
			vai_smode[id]=math.random(0,360)
			vai_mode[id]=9
		end
	elseif vai_targetobj[id]>0 then
		vai_aimx[id]=vai_objx[id]
		vai_aimy[id]=vai_objy[id]
		-- Switch to fight mode
		if vai_mode[id]~=10 and vai_mode[id]~=9 and vai_mode[id]~=4 and vai_mode[id]~=5 then
			vai_timer[id]=math.random(25,100)
			vai_smode[id]=math.random(0,360)
			vai_mode[id]=10
		end
	end

	ai_aim(id,vai_aimx[id],vai_aimy[id])
	
	-- ############################################################ Attack
	if vai_target[id]>0 then
		-- Right Direction?
		if math.abs(fai_angledelta(tonumber(player(id,"rot")),fai_angleto(player(id,"x"),player(id,"y"),player(vai_target[id],"x"),player(vai_target[id],"y"))))<20 then
			-- Do an "intelligent" attack (this includes automatic weapon selection and reloading)
			ai_iattack(id)
		end
	elseif vai_targetnpc[id]>0 then
		if math.abs(fai_angledelta(tonumber(player(id,"rot")),fai_angleto(player(id,"x"),player(id,"y"),object(vai_targetnpc[id],"x"),object(vai_targetnpc[id],"y"))))<20 then
			ai_iattack(id)
		end
	elseif vai_targetobj[id]>0 then
		if math.abs(fai_angledelta(tonumber(player(id,"rot")),fai_angleto(player(id,"x"),player(id,"y"),vai_objx[id],vai_objx[id])))<20 then
			ai_iattack(id)
		end
	end
end