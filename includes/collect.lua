--[[

Scan for collectible items every 1-2 seconds.
Try to collect them if possible.

]]--

-- Collect Items
function fai_collect(id)
	
	-- Scan Timer
	vai_itemscan[id]=vai_itemscan[id]+1
	if vai_itemscan[id]>100 then
		vai_itemscan[id]=math.random(0,50)
		
		-- Not collecting yet AND not a zombie?
		if vai_mode[id]~=6 and not(player(id,"team")==1 and vai_set_gm==4) then
			-- Find and scan close items (5 tiles around)
			local items=closeitems(id,5)
			for i=1,#items do
				-- Not on same tile?
				if item(items[i],"x")~=player(id,"tilex") or item(items[i],"y")~=player(id,"tiley") then
					local itype=item(items[i],"type")
					local slot=itemtype(itype,"slot")
					local collect=false
					if slot==1 then
						-- Primary
						if not fai_playerslotitems(id,1) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==2 then
						-- Secondary
						if not fai_playerslotitems(id,2) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==3 then
						-- Melee
						if not fai_contains(playerweapons(id),itype) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==4 then
						-- Grenades
						if not fai_contains(playerweapons(id),itype) and player(id,"team")~=3 then
							collect=true
						end
					elseif slot==5 then
						-- Special
						if itype==55 then
							-- Bomb
							if player(id,"team")==1 then
								collect=true
							end
						elseif itype==77 and not fai_contains(playerweapons(id),77) and player(id,"team")~=3 then
							collect=true -- collect mines
						elseif itype==87 and not fai_contains(playerweapons(id),87) and player(id,"team")~=3 then
							collect=true -- collect laser mines
						end
					elseif slot==6 then
						-- ??
						if not fai_contains(playerweapons(id),itype) and player(id,"team")~=3 then
							collect=true
						end					
					elseif slot==0 then
						-- No Slot Items
						if itype==70 or itype==71 then
							-- Flags
							collect=true
						elseif itype>=66 and itype<=68 and player(id,"money")<16000 then
							-- Money
							collect=true
						elseif itype>=64 and itype<=65 and player(id,"health")<player(id,"maxhealth") then
							-- Health
							collect=true
						elseif itype==57 and player(id,"armor")<65 then
							-- Armor (kevlar)
							collect=true
						elseif itype==58 and player(id,"armor")<100 then
							-- Armor (kevlar+helm)
							collect=true
						elseif itype==79 and player(id,"armor")<=100 then
							-- Armor (light)
							collect=true
						elseif itype==80 and player(id,"armor")<=201 then
							-- Armor (medium)
							collect=true
						elseif itype==81 and player(id,"armor")<=202 then
							-- Armor (heavy)
							collect=true
						elseif itype==82 and player(id,"armor")<=203 then
							-- Armor (medic)
							collect=true
						elseif itype==83 and player(id,"armor")<=204 then
							-- Armor (super)
							collect=true
						elseif itype==84 and player(id,"armor")<=100 then -- only pick up stealth armor if we don't have any special armor.
							-- Armor (stealth)
							collect=true
						elseif itype==56 and player(id,"defusekit")==false and player(id,"team")==2 then -- only cts should collect defuse kits
							-- Collect defuse kit
							collect=true
						elseif itype==59 and player(id,"nightvision")==false then
							-- Collect night vision
							collect=true
						elseif itype==60 and player(id,"gasmask")==false then
							-- Collect gas mask
							collect=true
						end
					end
					
					--Perform collect?
					if collect then
						vai_mode[id]=6
						vai_smode[id]=itype
						vai_destx[id]=item(items[i],"x")
						vai_desty[id]=item(items[i],"y")
						break
					end
					
				end
			end
		end
	end
end