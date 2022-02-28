--------------------------------------------------
-- CS2D Standard Bot AI                         --
-- V1: 01.08.2010 - www.UnrealSoftware.de       --
-- Last Update: 26.04.2017                      --
--                                              --
-- Used prefixes in this script                 --
-- ai_ = AI function (AI API, invoked by CS2D)  --
-- vai_ = AI variable                           --
-- fai_ = AI helper function                    --
--                                              --
--------------------------------------------------

-- Includes
dofile("bots/includes/settings.lua")				-- track settings
dofile("bots/includes/enums.lua")					-- global enums
dofile("bots/includes/general.lua")					-- general helper functions
dofile("bots/includes/engage.lua")					-- bot find and engage enemies
dofile("bots/includes/corebehavior.lua")			-- core behavior file
dofile("bots/includes/behavior/main.lua")			-- main behavior file
dofile("bots/includes/behavior/roam.lua")			-- roam behavior file
dofile("bots/includes/behavior/combat.lua")			-- combat behavior file

-- Setting Cache
vai_set_gm=0							-- Game Mode Setting (equals "sv_gamemode", Cache)
vai_set_botskill=0						-- Bot Skill Setting (equals "bot_skill", Cache)
vai_set_botweapons=0					-- Bot Weapons Setting (equals "bot_weapons", Cache)
vai_set_debug=0							-- Debug Setting (equals "debugai", Cache)
fai_update_settings()

-- Global per bot variables
vai_goalx = {}; vai_goaly = {} 			-- Bot move goal position
vai_aimx={}; vai_aimy={}				-- aim at x|y
vai_px={}; vai_py={}					-- previous x|y
vai_lkpx={}; vai_lkpy={}				-- last known position x|y
vai_targetplayer = {}					-- Bot target player
vai_targetobject = {}					-- Bot target object
vai_hastarget = {}						-- Has target?
vai_freeaim = {}						-- Bot aim is free (ie: no target)
vai_playerscan = {}						-- Player targetting scan timer
---@type BotActionClass
vai_action = {} -- Table containing Actions
for i=1,32 do
	vai_goalx[i] = 0; vai_goaly[i] = 0
	vai_aimx[i]=0; vai_aimy[i]=0
	vai_px[i]=0; vai_px[i]=0
	vai_lkpx[i]=0; vai_lkpy[i]=0;
	vai_action[i] = nil
	vai_targetplayer[i] = -1
	vai_targetobject[i] = -1
	vai_hastarget[i] = false
	vai_freeaim[i] = true
	vai_playerscan[i] = -1
end

-- "ai_onspawn" - AI On Spawn Function
-- This function is called by CS2D automatically after each spawn of a bot
-- Parameter: id = player ID of the bot
function ai_onspawn(id)
	fai_update_settings()
	vai_action[id] = nil
	vai_targetplayer[id] = -1
	vai_targetobject[id] = -1
	vai_hastarget[id] = false
	vai_playerscan[id] = -1
	fai_setmainaction(id, mainaction_init())
end

-- "ai_update_living" - AI Update Living Function
-- This function is called by CS2D automatically for each *LIVING* bot each frame
-- Parameter: id = player ID of the bot
function ai_update_living(id)

	-- Execute the combat system
	fai_scanforplayers(id) -- Scan for enemy players

	-- Execute the action system
	fai_runbehavior(id)

	-- Debug
	if vai_set_debug then
		if vai_action[id].Parallel ~= nil and vai_action[id].Child ~= nil then
			if vai_action[id].Child.Parallel ~= nil then
				ai_debug(id, ""..vai_action[id].Name.."("..vai_action[id].Parallel.Name..")<<"..vai_action[id].Child.Name.."("..vai_action[id].Child.Parallel.Name..")")
			else
				ai_debug(id, ""..vai_action[id].Name.."("..vai_action[id].Parallel.Name..")<<"..vai_action[id].Child.Name)
			end
		elseif vai_action[id].Parallel ~= nil and vai_action[id].Child == nil then
			ai_debug(id, ""..vai_action[id].Name.."("..vai_action[id].Parallel.Name..")")
		elseif vai_action[id].Parallel == nil and vai_action[id].Child ~= nil then
			if vai_action[id].Child.Parallel ~= nil then
				ai_debug(id, ""..vai_action[id].Name.."<<"..vai_action[id].Child.Name.."("..vai_action[id].Child.Parallel.Name..")")
			else
				ai_debug(id, ""..vai_action[id].Name.."<<"..vai_action[id].Child.Name)
			end
		else
			ai_debug(id, ""..vai_action[id].Name)
		end
	end

end

-- "ai_update_dead" - AI Update Dead Function
-- This function is called by CS2D automatically for each *DEAD* bot each second
-- Parameter: id = player ID of the bot
function ai_update_dead(id)
	-- Try to respawn (if not in normal gamemode)
	fai_update_settings()
	if vai_set_gm~=0 then
		ai_respawn(id)
		vai_action[id] = nil
		fai_setmainaction(id, mainaction_init())
	end
end

-- "ai_hear_radio" - AI Hear Radio
-- This function is called once for each radio message
-- Parameter: source = player ID of the player who sent the radio message
-- Parameter: radio = radio message ID
function ai_hear_radio(source,radio)

end

-- "ai_hear_chat" - AI Hear Chat
-- This function is called once for each chat message
-- Parameter: source = player ID of the player who sent the radio message
-- Parameter: msg = chat text message
-- Parameter: teamonly = team only chat message (1) or public chat message (0)
function ai_hear_chat(source,msg,teamonly)
	-- This bot implementation simply ignores all chat messages
end