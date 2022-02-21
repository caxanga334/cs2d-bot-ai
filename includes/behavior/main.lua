
---@type BotActionClass
local mainaction = {}
mainaction = BotAction("MainAction")

function mainaction_init()
	mainaction.Child = nil
	mainaction.OnStart = mainaction_onstart
	mainaction.Update = mainaction_update
	mainaction.Priority = BOT_PRIORITY.none
	return mainaction
end

function mainaction_onstart(id)

end

function mainaction_update(id)
	fai_SuspendFor(id, roamaction_init())
	return nil
end