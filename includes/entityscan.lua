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
		if vai_mode[id]~=20 or vai_mode[id]~=21 or vai_mode[id]~=22 or vai_mode[id]~=23 or vai_mode[id]~=11 or vai_mode[id]~=12 then
			local elist=entitylist(93) -- scans for Trigger_Use
			for _,e in pairs(elist) do
				ex=e.x -- entity tile
				ey=e.y
				dx=0 -- distance between bot and the entity
				dy=0
				if entity(ex,ey,"exists") then -- check if there is really an entity in there
					-- distance check, we don't want the BOT going to the other side of the map because of a button
					-- CHEAT!! BOT will see invisible buttons!
					if ex>px then
						dx=ex-px
					elseif px>ex then
						dx=px-ex
					end
					if ey>py then
						dy=ey-py
					elseif py>ey then
						dy=py-ey
					end
					interact=false
					if dx<=7 and dy<=7 then -- bot is near the entity
						if entity(ex,ey,"int2")==0 or player(id,"team")==entity(ex,ey,"int2") then -- button is all team or my team
							interact=true
							break
						end
					end
				end
			end
			if interact==true then
				vai_mode[id]=20
				vai_smode[id]=93 -- smode should store the entity ID
				vai_destx[id]=ex
				vai_desty[id]=ey
				if vai_set_debug==1 then
					print("BOT @ ("..px..","..py..") interacting with entity @ ("..ex..","..ey..") distance ("..dx..","..dy..")")
				end
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
						top=false
						left=false
						botton=false
						right=false
						if ex>px then -- bot is at the left of the entity
							dx=ex-px
							left=true
						elseif px>ex then
							right=true
							dx=px-ex
						end
						if ey>py then
							dy=ey-py
							top=true
						elseif py>ey then
							botton=true
							dy=py-ey
						end
						interact=false
						if dx<=7 and dy<=7 then -- bot is near the entity
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
					-- walkable check
					-- position 1. x -1, y 0 (middle left)
					if tile(ex-1,ey, "walkable") and left==true then
						vai_destx[id]=ex-1
						vai_desty[id]=ey
						vai_smode[id]=90 -- smode should store the angle the bot is going to face when attacking
					-- position 2. x 0, y -1 (middle top)
					elseif tile(ex,ey-1, "walkable") and top==true then
						vai_destx[id]=ex
						vai_desty[id]=ey-1
						vai_smode[id]=180
					-- position 3. x 0, y 1 (middle botton)
					elseif tile(ex,ey+1, "walkable") and botton==true then
						vai_destx[id]=ex
						vai_desty[id]=ey+1
						vai_smode[id]=0
					-- position 4. x 1, y 0 (middle right)
					elseif tile(ex+1,ey, "walkable") and right==true then
						vai_destx[id]=ex+1
						vai_desty[id]=ey
						vai_smode[id]=270
					end
					if vai_set_debug==1 then
						print("BOT @ ("..px..","..py..") interacting with entity @ ("..ex..","..ey..") distance ("..dx..","..dy..")")
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
	ai_aim(id,vai_aimx[id],vai_aimy[id])
	ai_selectweapon(id,50)
	ai_attack(id)
	-- check timer
	if vai_timer[id]>0 then
		vai_timer[id]=vai_timer[id]-1
		if ai_move(id,vai_smode[id])~=0 then
			
		end
	else
		-- switch mode
		vai_mode[id]=0
		vai_entityscan[id]=1500
	end

end