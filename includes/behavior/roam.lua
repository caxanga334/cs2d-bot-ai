--[[
	Roam Action
	Move to a random tile of the map
--]]

---@type BotActionClass
local roamaction = {}
roamaction = BotAction("RoamAction")

function roamaction_init()
	roamaction.Child = nil
	roamaction.OnStart = roamaction_onstart
	roamaction.Update = roamaction_update
	roamaction.Priority = BOT_PRIORITY.none
	return roamaction
end

function roamaction_onstart(id)
	print("BOT "..player(id, "name").." started action "..roamaction.Name)
	vai_goalx[id], vai_goaly[id] = fai_getrandomtile()
end

function roamaction_update(id)
	local result = ai_goto(id, vai_goalx[id], vai_goaly[id])
	fai_walkaim(id)

	if result ~= 2 then
		fai_ActionDone(id, "Done roaming")
		vai_goalx[id] = -1
		vai_goaly[id] = -1
		return nil
	end
end