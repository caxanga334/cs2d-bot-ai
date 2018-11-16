-- make bots build something
function fai_findbuildspot(id)
	local team=player(id,"team")
	local money=player(id,"money")
	
	-- decide where should we build
	if team==1 then -- TERRORIST
	-- build1: map objective | build2: bot node if available | build3: random tile
		local r=math.random(1,3)
		local buildx=math.random(-3,3)
		local buildy=math.random(-3,3)
		if r==1 then -- build at entities of interest
			if map("mission_vips")>0 then
				vai_destx[id],vai_desty[id]=randomentity(6) -- info_escapepoint
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_hostages")>0 then
				vai_destx[id],vai_desty[id]=randomentity(4) -- info_rescuepoint
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_bombspots")>0 then
				vai_destx[id],vai_desty[id]=randomentity(5) -- info_bombspot
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_ctfflags")>0 then
				vai_destx[id],vai_desty[id]=randomentity(15,0,1) -- info_ctf_flag
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_dompoints")>0 then
				vai_destx[id],vai_desty[id]=randomentity(17,0,1) -- info_dom_point
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			else
				vai_destx[id],vai_desty[id]=randomentity(0) -- info_t
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=4 -- this will make bots build tele entrance instead of tele exit
			end
		elseif r==2 then -- BOT NODE
			if map("botnodes")>0 and math.random(1,2)==1 then
				vai_destx[id],vai_desty[id]=randomentity(19) -- info_botnode
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=2
			elseif math.random(1,10)>=4 then
				vai_destx[id],vai_desty[id]=randomentity(0) -- info_t
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=4
			else
				fai_randommaptile(id) -- select a random tile around the map
				vai_mode[id]=61
				vai_smode[id]=3
			end
		else
			fai_randommaptile(id) -- select a random tile around the map
			vai_mode[id]=61
			vai_smode[id]=3
		end
	else -- COUNTER-TERRORIST
		local r=math.random(1,3)
		local buildx=math.random(-3,3)
		local buildy=math.random(-3,3)
		if r==1 then -- build at entities of interest
			if map("mission_vips")>0 then
				vai_destx[id],vai_desty[id]=randomentity(6) -- info_escapepoint
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_hostages")>0 then
				vai_destx[id],vai_desty[id]=randomentity(4) -- info_rescuepoint
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_bombspots")>0 then
				vai_destx[id],vai_desty[id]=randomentity(5) -- info_bombspot
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_ctfflags")>0 then
				vai_destx[id],vai_desty[id]=randomentity(15,0,2) -- info_ctf_flag
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			elseif map("mission_dompoints")>0 then
				vai_destx[id],vai_desty[id]=randomentity(17,0,2) -- info_dom_point
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=1
			else
				vai_destx[id],vai_desty[id]=randomentity(1) -- info_ct
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=4
			end
		elseif r==2 then -- BOT NODE
			if map("botnodes")>0 and math.random(1,2)==1 then
				vai_destx[id],vai_desty[id]=randomentity(19) -- info_botnode
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=2
			elseif math.random(1,10)>=4 then
				vai_destx[id],vai_desty[id]=randomentity(1) -- info_ct
				vai_destx[id]=vai_destx[id]+buildx
				vai_desty[id]=vai_desty[id]+buildy
				vai_mode[id]=61
				vai_smode[id]=4
			else
				fai_randommaptile(id) -- select a random tile around the map
				vai_mode[id]=61
				vai_smode[id]=3
			end
		else
			fai_randommaptile(id) -- select a random tile around the map
			vai_mode[id]=61
			vai_smode[id]=3
		end
	end
	
	-- FAIL SAFE
	if not tile(vai_destx[id],vai_desty[id], "walkable") then
		vai_mode[id]=0
		vai_smode[id]=0
		if vai_set_debug==1 then
			print("build spot not walkable")
		end
	end
end