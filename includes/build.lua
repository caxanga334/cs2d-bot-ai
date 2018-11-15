-- selects a random building and build it
function fai_build(id)
	local rb=math.random(1,8)
	local px=player(id,"tilex")
	local py=player(id,"tiley")
	local rx=math.random(-1,1)
	local ry=math.random(-1,1)
	local bx=px+rx
	local by=py+ry

	ai_selectweapon(id,74)
	if rb==1 then
		ai_build(id,5,bx,by) -- Wall 3
		ai_sayteam(id,"I've built a wall 3")
		vai_smode[id]=1
	elseif rb==2 then
		ai_build(id,6,bx,by) -- Gate Field
		ai_sayteam(id,"I've built a gate field")
		vai_smode[id]=2
	elseif rb==3 then
		ai_build(id,7,bx,by) -- Dispenser
		ai_sayteam(id,"I've built a dispenser")
		vai_smode[id]=3
	elseif rb==4 then
		ai_build(id,8,bx,by) -- Turret
		ai_sayteam(id,"I've built a turret")
		vai_smode[id]=4
	elseif rb==5 then
		ai_build(id,9,bx,by) -- Supply
		ai_sayteam(id,"I've built a supply")
		vai_smode[id]=5
	elseif rb==6 then
		ai_build(id,13,bx,by) -- Tele Entrance
		ai_sayteam(id,"I've built a tele entrance")
		vai_smode[id]=6
	elseif rb==7 then
		ai_build(id,14,bx,by) -- Tele Exit
		ai_sayteam(id,"I've built a tele exit")
		vai_smode[id]=7
	elseif rb==8 then -- plant mines
		if fai_contains(playerweapons(id),77) then -- does the bot have mines? !!BUGBUG bots won't place mines if they don't have a wrench
			ai_selectweapon(id,77) -- select mines
			ai_attack(id)
			ai_sayteam(id,"I've planted some mines")
		end
	end
	-- finished building
	vai_mode[id]=0
	vai_smode[id]=0
	ai_selectweapon(id,50)
end