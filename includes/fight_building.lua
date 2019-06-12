
-- If player has a valid target, fight it with the current weapon
-- Otherwise find a new goal
function fai_fightbuilding(id)
	local ptx=player(id,"tilex")
	local pty=player(id,"tiley")
	local otx=object(vai_targetobj[id],"tilex")
	local oty=object(vai_targetobj[id],"tiley")

	-- this function will tell if we should use melee or do a ranged attack
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then
			-- object exists and is not dead
			if itemtype(player(id,"weapontype"),"range")<50 then
				-- Yes, melee! Run to target
				if vai_smode[id]==30 then
					vai_destx[id],vai_desty[id]=otx,oty -- NPC
				else
					vai_destx[id],vai_desty[id]=fai_gettilerandomradius(id, -1, otx, oty)
				end
				vai_mode[id]=13
			else
				if vai_smode[id]==8 or vai_smode[id]==11 or vai_smode[id]==12 or vai_smode[id]==30 then -- turrets and NPCs
					vai_mode[id]=12
				else -- use melee for these
					vai_destx[id],vai_desty[id]=fai_gettilerandomradius(id, -1, otx, oty)
					vai_mode[id]=13
				end
			end			
		end
	end
end

function fai_meleebuilding(id)
	local a=math.random(-1,1)
	local angle=fai_angleto(player(id,"x"),player(id,"y"),vai_objx[id],vai_objy[id])
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then
			ai_selectweapon(id,50)
			ai_attack(id)	
			if vai_smode[id]==30 then -- NPC
				ai_goto(id,object(vai_targetobj[id],"tilex"),object(vai_targetobj[id],"tiley"))
			else
				ai_move(id,angle)
			end
		else
			vai_mode[id]=0
		end
	else
		vai_mode[id]=0
	end
	--ai_rotate(id,angle)
	ai_aim(id,vai_objx[id]+a,vai_objy[id]-a)
end

function fai_attackobjranged(id)
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then
			ai_aim(id,vai_objx[id],vai_objy[id])
			ai_iattack(id)		
		end
	else
		vai_mode[id]=0
	end
end