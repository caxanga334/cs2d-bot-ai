
---@type BotActionClass
local attackaction = {}
attackaction = BotAction("AttackAction")

function attackaction_init()
    attackaction.Priority = BOT_PRIORITY.combatmedium
    attackaction.Update = attackaction_update
    return attackaction
end

function attackaction_update(id)
    if not vai_hastarget[id] then
        if vai_lkpx[id] > 0 then
            fai_ChangeTo(id, seeklkpaction_init(), "Lost my target, moving to LKP!")
        else
            fai_ActionDone(id, "No target!")
        end

        return nil
    end

    local px = player(vai_targetplayer[id], "x")
    local py = player(vai_targetplayer[id], "y")
    local tx = player(vai_targetplayer[id], "tilex")
    local ty = player(vai_targetplayer[id], "tiley")
    vai_lkpx[id] = tx
    vai_lkpy[id] = ty

    if itemtype(player(id,"weapontype"),"range") < 50 then
        ai_goto(id, tx, ty)
    elseif fai_distance2d(player(id, "x"), player(id, "y"), px, py) > 140 then
        ai_goto(id, tx, ty)
    end

    if not fai_invisionrangepixels(id, px, py) then
        fai_ChangeTo(id, seeklkpaction_init(), "Target no longer in range, moving to LKP!")
    end
end

---@type BotActionClass
local seeklkpaction = {}
seeklkpaction = BotAction("SeekLKPAction")

function seeklkpaction_init()
    seeklkpaction.Priority = BOT_PRIORITY.combathigh
    seeklkpaction.Update = seeklkpaction_update
    return seeklkpaction
end

function seeklkpaction_update(id)
    if vai_hastarget[id] and vai_targetplayer[id] > 0 then
        fai_ChangeTo(id, attackaction_init(), "Found a target!")
        return nil
    end

    if ai_goto(id, vai_lkpx[id], vai_lkpy[id]) ~= 2 then
        fai_ActionDone(id, "Done seeking last know position")
        vai_lkpx[id] = -1
        vai_lkpy[id] = -1
    end
end