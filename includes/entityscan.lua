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
	
	-- Scan Timer
	vai_entityscan[id]=vai_entityscan[id]+-1
	if vai_entityscan[id]<=0 then
		vai_entityscan[id]=math.random(400,600)
		
		-- mode check
		if vai_mode[id]~=20 or vai_mode[id]~=21 or vai_mode[id]~=22 or vai_mode[id]~=23 then
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