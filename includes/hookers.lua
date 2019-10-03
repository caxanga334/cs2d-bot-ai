addhook("mapchange","hai_onmapchange")
function hai_onmapchange(newmap)
	fai_cleartable(gai_tuitems)
	fai_cleartable(gai_ctuitems)
	fai_cleartable(gai_configdata)
	vai_config_read=false
end

addhook("startround","hai_onstartround")
function hai_onstartround(mode)
	fai_cleartable(gai_tuitems)
	fai_cleartable(gai_ctuitems)
	fai_cleartable(gai_configdata)
	vai_config_read=false
	fai_read_config()
end

-- allows players to get coordinates by using server action without needing additional lua scripts
addhook("serveraction","hai_onserveraction")
function hai_onserveraction(id,action)
	if vai_set_debug == 1 then -- requires AI debug enabled
		msg2(id,"X: "..player(id,"tilex").." Y: "..player(id,"tiley"))
	end
end
