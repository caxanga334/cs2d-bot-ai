
-- If player has a valid target, fight it with the current weapon
-- Otherwise find a new goal

-- this function the BOT will see what to do with it's target object
function fai_enganeobject(id)
	if not object(vai_targetobj[id],"exists") then
			vai_mode[id]=0
		else
		if object(vai_targetobj[id],"health")>0 then
			local otype=object(vai_targetobj[id],"type")
			
			if otype==8 or otype==11 or otype==12 or otype==30 then -- turrets and NPCs
				if otype==30 then
					vai_smode[id]=1
				end
				vai_timer[id]=math.random(50,150)
				vai_cache[id]=math.random(0,360)
				vai_mode[id]=32
			else
				vai_destx[id],vai_desty[id]=fai_gettiletoobj(player(id,"tilex"),player(id,"tiley"),object(vai_targetobj[id],"tilex"),object(vai_targetobj[id],"tiley"))
				vai_mode[id]=31
			end
		else
			vai_mode[id]=0
		end
	end
end

function fai_rangedobject(id)
	ai_iattack(id)
	
	vai_timer[id]=vai_timer[id]-1
	if vai_timer[id]<=0 then
		vai_timer[id]=math.random(50,150)
		vai_cache[id]=math.random(0,360)
	end
	
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then
		
			local rnd=math.random(-2,2)
			if vai_smode[id]==1 then
				vai_aimx[id]=object(vai_targetobj[id],"x")
				vai_aimy[id]=object(vai_targetobj[id],"y")
			else
				vai_aimx[id]=object(vai_targetobj[id],"x")+16+rnd
				vai_aimy[id]=object(vai_targetobj[id],"y")+16-rnd		
			end

			ai_aim(id,vai_aimx[id],vai_aimy[id])
		
			-- melee combat?
			if itemtype(player(id,"weapontype"),"range")<50 then
				if vai_smode[id]==1 then -- NPCs
					if ai_goto(id,object(vai_targetobj[id],"tilex"),object(vai_targetobj[id],"tiley"))~=2 then
						vai_mode[id]=0
					end
				else
					vai_destx[id],vai_desty[id]=fai_gettiletoobj(player(id,"tilex"),player(id,"tiley"),object(vai_targetobj[id],"tilex"),object(vai_targetobj[id],"tiley"))
					vai_mode[id]=31				
				end
			else
				-- ranged attack
				
				if ai_move(id,vai_cache[id])==0 then
					-- Bot failed to walk (way blocked) -> turn
					if (id%2)==0 then
						vai_cache[id]=vai_cache[id]+45
					else
						vai_cache[id]=vai_cache[id]-45
					end
					vai_timer[id]=math.random(50,150)
				end				
			end
		end
		else
			vai_mode[id]=0
	end
end

function fai_meleeobject(id)
	if object(vai_targetobj[id],"exists") then
		if object(vai_targetobj[id],"health")>0 then

			if object(vai_targetobj[id],"type")==30 then
				vai_destx[id]=object(vai_targetobj[id],"tilex")
				vai_desty[id]=object(vai_targetobj[id],"tiley")
			else
				vai_destx[id],vai_desty[id]=fai_gettiletoobj(player(id,"tilex"),player(id,"tiley"),object(vai_targetobj[id],"tilex"),object(vai_targetobj[id],"tiley"))
			end
			
			local rnd=math.random(-2,2)
			local angle=fai_angleto(player(id,"x"),player(id,"y"),object(vai_targetobj[id],"x")+16,object(vai_targetobj[id],"y")+16)
			vai_aimx[id]=object(vai_targetobj[id],"x")+16+rnd
			vai_aimy[id]=object(vai_targetobj[id],"y")+16-rnd
			ai_aim(id,vai_aimx[id],vai_aimy[id])
			ai_move(id,angle)
			ai_selectweapon(id,50)
			ai_attack(id)
		else
			vai_mode[id]=0
		end
	else
		vai_mode[id]=0
	end
end