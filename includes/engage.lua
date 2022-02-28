
---Sets the bot target player
---
---Set target to **-1** to clear target
---@param id number #BOT ID
---@param target number #Target player ID
function fai_settargetplayer(id, target)
	if target < 1 then
		vai_targetplayer[id] = target
		vai_hastarget[id] = false
		vai_freeaim[id] = true
	else
		vai_targetplayer[id] = target
		vai_hastarget[id] = true
		vai_freeaim[id] = false
	end
end

function fai_scanforplayers(id)
	-- Scan for target

	if player(id, "ai_flash") ~= 0 then
		fai_settargetplayer(id, -1)
		vai_playerscan[id] = 1
		return nil
	end

	-- Scan for players
	vai_playerscan[id] = vai_playerscan[id] - 1
	if vai_playerscan[id] < 0 then
		local target = ai_findtarget(id)

		if target > 0 then
			if not ai_freeline(id, player(target, "x"), player(target, "y")) then
				fai_settargetplayer(id, -1)
				vai_playerscan[id] = math.random(5, 10)
				return nil
			elseif not fai_enemies(target, id) then
				fai_settargetplayer(id, -1)
				vai_playerscan[id] = math.random(5, 10)
				return nil
			else
				fai_settargetplayer(id, target)
				vai_playerscan[id] = math.random(10, 20)
			end
		end
	end

	-- Validade current target
	if vai_hastarget[id] and vai_targetplayer[id] > 0 then
		if not player(vai_targetplayer[id], "exists") or player(vai_targetplayer[id], "health") < 1 or player(vai_targetplayer[id], "team") == CSTEAM.neutral then
			fai_settargetplayer(id, -1)
			return nil
		end

		local x2 = player(vai_targetplayer[id], "x") -- TARGET X pixel position
		local y2 = player(vai_targetplayer[id], "y") -- TARGET Y pixel position

		if not fai_invisionrangepixels(id, x2, y2) then
			fai_settargetplayer(id, -1)
			return nil
		end

		fai_attackplayer(id)
	end
end

function fai_attackplayer(id)
	local x = player(vai_targetplayer[id], "x") -- TARGET X pixel position
	local y = player(vai_targetplayer[id], "y") -- TARGET Y pixel position

	ai_aim(id, x, y)

	-- Right Direction?
	if math.abs(fai_angledelta(tonumber(player(id,"rot")),fai_angleto(player(id,"x"),player(id,"y"),player(vai_targetplayer[id],"x"),player(vai_targetplayer[id],"y"))))<20 then
		-- Do an "intelligent" attack (this includes automatic weapon selection and reloading)
		ai_iattack(id)
	end
end