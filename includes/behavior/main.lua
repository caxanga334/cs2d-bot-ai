
---@type BotActionClass
local mainaction = {}
mainaction = BotAction("MainAction")

function mainaction_init()
	mainaction.Child = nil
	mainaction.OnStart = mainaction_onstart
	mainaction.Update = mainaction_update
	mainaction.Priority = BOT_PRIORITY.none
	if vai_set_gm == GAMEMODE.standard then
		if map("mission_bombspots") > 0 then
			mainaction.Parallel = bombdefuseaction_init()
		end
	end
	return mainaction
end

function mainaction_onstart(id)
end

function mainaction_update(id)
	if vai_hastarget[id] and vai_targetplayer[id] > 0 then
		fai_TrySuspendFor(id, attackaction_init(), "Attacking enemies!")
	end


	fai_SuspendFor(id, roamaction_init(), "Test")
	return nil
end


---@type BotActionClass
local bombdefuseaction = {}
bombdefuseaction = BotAction("BombDefuseMonitor")

function bombdefuseaction_init()
	bombdefuseaction.Update = bombdefuseaction_update
	bombdefuseaction.Priority = BOT_PRIORITY.verylow
	return bombdefuseaction
end

function bombdefuseaction_update(id)
	if player(id, "bomb") then
		fai_TrySuspendFor(id, gotobombsite_init(), "Going to plant the bomb!")
	end
end

---@type BotActionClass
local gotobombsite = {}
gotobombsite = BotAction("GoToBombSite")

local bombsitex = {}; local bombsitey = {}

for i = 1, 32, 1 do
	bombsitex[i] = -1
	bombsitey[i] = -1
end

function gotobombsite_init()
	gotobombsite.OnStart = gotobombsite_onstart
	gotobombsite.Update = gotobombsite_update
	gotobombsite.Priority = BOT_PRIORITY.medium
	return gotobombsite
end

function gotobombsite_onstart(id)
	local x, y = randomentity(5)

	for i = 1, 30, 1 do
		x = x + math.random(-2,2)
		y = y + math.random(-2,2)

		if tile(x , y, "walkable") and inentityzone(x,y,5) then
			bombsitex[id] = x
			bombsitey[id] = y
			return nil
		end
	end
end

function gotobombsite_update(id)
	if vai_hastarget[id] and vai_targetplayer[id] > 0 then
		fai_TrySuspendFor(id, attackaction_init(), "Attacking enemies!")
	end

	if vai_freeaim[id] then
		fai_walkaim(id)
	end

	if not player(id, "bomb") then
		fai_ActionDone(id, "I don't have a bomb!")
	end

	if bombsitex[id] < 0 then
		fai_ActionDone(id, "Invalid bombspot!")
	end

	local result = ai_goto(id, bombsitex[id], bombsitey[id])

	if result == 1 then
		fai_TrySuspendFor(id, plantbombaction_init(), "Planting the bomb!")
	end
end

---@type BotActionClass
local plantbombaction = {}
plantbombaction = BotAction("PlantBomb")

function plantbombaction_init()
	plantbombaction.OnStart = plantbombaction_onstart
	plantbombaction.Update = plantbombaction_update
	plantbombaction.Priority = BOT_PRIORITY.veryhigh
	return plantbombaction
end

function plantbombaction_onstart(id)
	ai_radio(id, 6)
	ai_rotate(id, math.random(0, 359))
end

function plantbombaction_update(id)
	if vai_hastarget[id] and vai_targetplayer[id] > 0 then
		fai_TrySuspendFor(id, attackaction_init(), "Attacking enemies!")
	end

	if not player(id, "bomb") then
		fai_ActionDone(id, "I don't have a bomb!")
	end
	
	if inentityzone(player(id, "tilex"), player(id, "tiley"), 5) then
		if player(id, "weapontype") ~= 55 then
			ai_selectweapon(id, 55)
		else
			ai_attack(id)
		end
	end
end