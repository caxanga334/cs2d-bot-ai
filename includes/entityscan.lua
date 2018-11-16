-- entity scan

function fai_scanforentity(id)

	-- global function variables
	local interact=false
	
	-- Scan Timer
	vai_entityscan[id]=vai_entityscan[id]+-1
	if vai_entityscan[id]<=0 then
		vai_entityscan[id]=math.random(400,600)
		
		-- mode check
		if vai_mode[id]~=20 then
			local elist=entitylist(93) -- scans for Trigger_Use
			for _,e in pairs(elist) do
				local px=player(id,"tilex") -- player tile
				local py=player(id,"tiley")
				local ex=e.x -- entity tile
				local ey=e.y
				local dx=0 -- distance between bot and the entity
				local dy=0
				if entity(ex,ey,"exists") then -- check if there is really an entity in there
					-- distance check
					if ex>px then
						dx=ex-px
					elseif px>ex then
						dx=px-ex
					end
					if ey>py then
						dy=ey-py
					elseif px>ex then
						dy=py-ey
					end
					if dx<=5 and dy<=5 then -- bot is near the entity
						interact=true
					end
				end
				if interact==true then
					vai_mode[id]=20
					vai_smode[id]=93 -- smode should store the entity ID
					vai_destx[id]=ex
					vai_desty[id]=ey
					if vai_set_debug==1 then
						print("BOT interacting with entity @ ("..ex..","..ey..")")
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
	vai_entityscan[id]=3000 -- increase scan time to avoid getting stuck pressing the same button
end