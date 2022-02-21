
---@class BotActionClass
---@field OnStart function
---@field OnEnd function
---@field OnSuspend function
---@field OnResume function
---@field Update function
---@field Parallel BotActionClass
---@field Child BotActionClass
---@field Priority number
---@field Name string
local BotActionClass = {}
BotActionClass.OnStart = nil -- On Start function
BotActionClass.OnEnd = nil -- On End Function
BotActionClass.OnSuspend = nil -- On Suspend Function
BotActionClass.OnResume = nil -- On Resume Function
BotActionClass.Update = nil -- Update Function
BotActionClass.Parallel = nil -- The Action that will be executed in parallel to this one
BotActionClass.Child = nil -- Child Action
BotActionClass.Priority = BOT_PRIORITY.none -- Action Priority
BotActionClass.Name = ""

---Constructs a new bot action class
---@return table
function BotAction(name)
	---@type BotActionClass
	local newaction = {}
	newaction.Name = name
	newaction.OnStart = nil
	newaction.OnEnd = nil
	newaction.OnSuspend = nil
	newaction.OnResume = nil
	newaction.Update = nil
	newaction.Parallel = nil
	newaction.Child = nil
	newaction.Priority = BOT_PRIORITY.none
	return newaction
end

function fai_runbehavior(id)

	if vai_action[id] == nil then
		error("BOT "..player(id, "name").." doesn't have an action to run!")
	end

	-- Don't bother to check if update is nil. ALL ACTIONS should have an update function
	vai_action[id].Update(id)

	if vai_action[id].Parallel ~= nil then
		vai_action[id].Parallel.Update(id)
	end

	return nil
end

---Clears the bot actions and sets the main action
---@param id number #BOT ID
---@param mainaction BotActionClass #BOT Action
function fai_setmainaction(id, mainaction)
	vai_action[id] = mainaction
	mainaction.OnStart(id)
end

---Marks the top action as done
---
---This will call the action's OnEnd function
---@param id number #BOT player ID
---@param reason string #Reason string for debugging
function fai_ActionDone(id, reason)
	if vai_set_debug then
		print("BOT "..player(id, "name").." done with action "..vai_action[id].Name..". Reason: "..reason)
	end

	if vai_action[id].OnEnd ~= nil then
		vai_action[id].OnEnd(id)
	end

	if vai_action[id].Parallel ~= nil then
		if vai_action[id].Parallel.OnEnd ~= nil then
			vai_action[id].Parallel.OnEnd(id)
		end
	end

	---@type BotActionClass
	local childaction = vai_action[id].Child
	vai_action[id] = nil

	if childaction ~= nil then
		vai_action[id] = childaction

		if childaction.OnResume ~= nil then
			childaction.OnResume(id)
		end

		if childaction.Child ~= nil then
			vai_action[id].Child = childaction.Child
		else
			vai_action[id].Child = nil
		end

		if childaction.Parallel ~= nil then
			vai_action[id].Parallel = childaction.Parallel

			if childaction.Parallel.OnResume ~= nil then
				childaction.Parallel.OnResume(id)
			end
		end
	end
end

---Suspends the current action for another.
---
---The current action is set as a child action of the new action.
---@param id number
---@param newaction BotActionClass
function fai_SuspendFor(id, newaction)
	if vai_set_debug then
		print("BOT "..player(id, "name").." suspended action "..vai_action[id].Name.." for "..newaction.Name)
	end

	if vai_action[id].OnSuspend ~= nil then
		vai_action[id].OnSuspend(id)
	end

	if vai_action[id].Parallel ~= nil then
		if vai_action[id].Parallel.OnSuspend ~= nil then
			vai_action[id].Parallel.OnSuspend(id)
		end
	end

	if newaction.OnStart ~= nil then
		newaction.OnStart(id)
	end

	if newaction.Parallel ~= nil then
		if newaction.Parallel.OnStart ~= nil then
			newaction.Parallel.OnStart(id)
		end
	end

	newaction.Child = vai_action[id]
	vai_action[id] = newaction
	return nil
end

---Changes the current action to the new action
---
---Note that this does not set the current action as a child action!
---@param id number
---@param newaction BotActionClass
function fai_ChangeTo(id, newaction)
	if vai_set_debug then
		print("BOT "..player(id, "name").." changed action "..vai_action[id].Name.." for "..newaction.Name)
	end

	if vai_action[id].OnEnd ~= nil then
		vai_action[id].OnEnd(id)
	end

	if vai_action[id].Parallel ~= nil then
		if vai_action[id].Parallel.OnEnd ~= nil then
			vai_action[id].Parallel.OnEnd(id)
		end
	end

	if newaction.OnStart ~= nil then
		newaction.OnStart(id)
	end

	if newaction.Parallel ~= nil then
		if newaction.Parallel.OnStart ~= nil then
			newaction.Parallel.OnStart(id)
		end
	end

	vai_action[id] = newaction
	return nil
end

---Tries to suspend the current action for another.
---
---The action will only change if the new action's **priority** is equal or higher than the current action.
---
---The current action is set as a child action of the new action.
---@param id number
---@param newaction BotActionClass
function fai_TrySuspendFor(id, newaction)
	if newaction.Priority < vai_action[id].Priority then
		return false
	end

	if vai_set_debug then
		print("BOT "..player(id, "name").." suspended action "..vai_action[id].Name.." for "..newaction.Name)
	end

	if vai_action[id].OnSuspend ~= nil then
		vai_action[id].OnSuspend(id)
	end

	if vai_action[id].Parallel ~= nil then
		if vai_action[id].Parallel.OnSuspend ~= nil then
			vai_action[id].Parallel.OnSuspend(id)
		end
	end

	if newaction.OnStart ~= nil then
		newaction.OnStart(id)
	end

	if newaction.Parallel ~= nil then
		if newaction.Parallel.OnStart ~= nil then
			newaction.Parallel.OnStart(id)
		end
	end

	newaction.Child = vai_action[id]
	vai_action[id] = newaction
	return true
end

---Tries to change the current action to the new action.
---
---The action will only change if the new action's **priority** is equal or higher than the current action.
---
---Note that this does not set the current action as a child action!
---@param id number
---@param newaction BotActionClass
---@return boolean
function fai_TryChangeTo(id, newaction)
	if newaction.Priority < vai_action[id].Priority then
		return false
	end

	if vai_set_debug then
		print("BOT "..player(id, "name").." changed action "..vai_action[id].Name.." for "..newaction.Name)
	end

	if vai_action[id].OnEnd ~= nil then
		vai_action[id].OnEnd(id)
	end

	if vai_action[id].Parallel ~= nil then
		if vai_action[id].Parallel.OnEnd ~= nil then
			vai_action[id].Parallel.OnEnd(id)
		end
	end

	if newaction.OnStart ~= nil then
		newaction.OnStart(id)
	end

	if newaction.Parallel ~= nil then
		if newaction.Parallel.OnStart ~= nil then
			newaction.Parallel.OnStart(id)
		end
	end

	vai_action[id] = newaction
	return true
end