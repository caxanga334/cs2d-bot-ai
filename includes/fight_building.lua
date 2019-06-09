
-- If player has a valid target, fight it with the current weapon
-- Otherwise find a new goal
function fai_fightbuilding(id)
	local ptx=player(id,"tilex")
	local pty=player(id,"tiley")
	local otx=object(vai_targetobj[id],"tilex")
	local oty=object(vai_targetobj[id],"tiley")
	local cx,cy,angle=0
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then
			cx,cy,angle=fai_gettiletoobj(ptx,pty,otx,oty)
			-- object exists and is not dead/destroyed
			-- Melee Combat?
			if itemtype(player(id,"weapontype"),"range")<50 then
				-- Yes, melee! Run to target
				local go=ai_goto(id,cx,cy)
				if go==1 then -- bot reached destination
					fai_meleebuilding(id,angle)
				elseif go==0 then -- bot failed to reach destination
					vai_mode[id]=0
				end
			else
				if vai_smode[id]==8 or vai_smode[id]==11 or vai_smode[id]==12 or vai_smode[id]==30 then -- turrets and NPCs
					ai_iattack(id) -- always do ranged attack agains turrets/NPCs
				else
					local go=ai_goto(id,cx,cy)
					if go==1 then -- bot reached destination
						fai_meleebuilding(id,angle)
					elseif go==0 then -- bot failed to reach destination
						vai_mode[id]=0
					end
				end
			end
		else
			vai_mode[id]=0 -- object is dead
		end
	else
		vai_mode[id]=0 -- object does not exists
	end
end

function fai_meleebuilding(id,angle)
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then
			ai_aim(id,vai_objx[id],vai_objy[id])
			ai_selectweapon(id,50)
			ai_attack(id)		
		end
	else
		vai_mode[id]=0
	end
	ai_move(id,angle)
	ai_rotate(id,angle)
end