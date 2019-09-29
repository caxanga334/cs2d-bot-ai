-- entity scan

function fai_scanforentity(id)

	-- global function variables
	local interact=false
	local px=player(id,"tilex") -- player tile
	local py=player(id,"tiley")
	local ex=0 -- entity tile
	local ey=0
	local dx=0 -- distance between bot and the entity
	local dy=0
	local top=false
	local left=false
	local botton=false
	local right=false
	
	-- Scan Timer
	vai_entityscan[id]=vai_entityscan[id]+-1
	if vai_entityscan[id]<=0 then
		vai_entityscan[id]=math.random(200,400)
		
		-- mode check
		if vai_mode[id]~=4 and vai_mode[id]~=20 and vai_mode[id]~=21 and vai_mode[id]~=22 and vai_mode[id]~=23 and vai_mode[id]~=24 and vai_mode[id]~=11 and vai_mode[id]~=12 and vai_mode[id]~=63 then
			local elist=entitylist(93) -- scans for Trigger_Use
			local buttons = {}
			local i=1
			local interact=false
			for _,e in pairs(elist) do
				ex=e.x -- entity tile
				ey=e.y
				dx=0 -- distance between bot and the entity
				dy=0
				if entity(ex,ey,"exists") then -- check if there is really an entity in there
					-- distance check, we don't want the BOT going to the other side of the map because of a button
					-- CHEAT!! BOT will see invisible buttons!
					local r = util_getdistance(px,py,e.x,e.y)
					
					if r < 12.0 then -- bot is near the entity
						if entity(ex,ey,"int2")==0 or player(id,"team")==entity(ex,ey,"int2") then -- button is all team or my team
							interact=true
							buttons[i] = {}
							buttons[i].id = e
							buttons[i].x = e.x
							buttons[i].y = e.y
							i = i + 1
						end
					end
				end
			end
			if interact==true then
				vai_mode[id]=20
				vai_smode[id]=93 -- smode should store the entity ID
				local randbutton = math.random( #buttons )
				vai_destx[id]=buttons[randbutton].x
				vai_desty[id]=buttons[randbutton].y
			end
			if not interact then -- bot is already interacting with another entity
				-- Breakable
				local ebr=entitylist(25) -- scans for Env_Breakable
				for _,e in pairs(ebr) do
					ex=e.x -- entity tile
					ey=e.y
					dx=0 -- distance between bot and the entity
					dy=0
					if entity(ex,ey,"exists") then -- check if there is really an entity in there
						-- distance check, we don't want the BOT going to the other side of the map because of a Breakable
						-- CHEAT!! BOT will see invisible breakables!
						local r = util_getdistance(px,py,e.x,e.y)
						
						interact=false
						if r < 12.0 then -- bot is near the entity
							if entity(ex,ey,"int1") < 1000 then -- ignore Env_Breakable with lots of health, we don't want the bot trying to breaking something with 999999 health
								vai_cache[id]=entity(ex,ey,"int1") -- caches the breakable health
								interact=true
								break
							end
						end
					end
				end
				if interact==true then
					vai_mode[id]=11
					vai_timer[id]=vai_cache[id]+70 -- set attack timer based on breakable health
					vai_aimx[id]=ex*32+16
					vai_aimy[id]=ey*32+16
					local fx,fy=fai_findbpapos2(px,py,ex,ey)
					if fx~=-1 then
						vai_destx[id]=fx
						vai_desty[id]=fy
					end
				end
			end
		end
	end
end

-- makes bot press their use button and reset
function fai_usentity(id)
	ai_use(id)
	vai_mode[id]=0
	vai_smode[id]=0
	vai_entityscan[id]=1500 -- increase scan time to avoid getting stuck pressing the same button
end

function fai_destroybreakable(id)
	local angles=fai_angleto(player(id,"x"),player(id,"y"),vai_aimx[id],vai_aimy[id])
	ai_aim(id,vai_aimx[id],vai_aimy[id])
	ai_selectweapon(id,50)
	ai_attack(id)
	-- check timer
	if vai_timer[id]>0 then
		vai_timer[id]=vai_timer[id]-1
		if ai_move(id,angles)~=0 then
			
		end
	else
		-- switch mode
		vai_mode[id]=0
		vai_entityscan[id]=1500
	end

end