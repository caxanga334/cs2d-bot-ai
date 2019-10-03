-- build data from the config file
function fai_read_config()
	local mapname=map("name")
	local file = io.open("bots/config/"..mapname..".ini", "r")
	vai_config_read=true
	
	if file == nil then
		print("Config file bots/config/"..mapname..".ini not found")
		return
	end
	
	print("Reading file: bots/config/"..mapname..".ini")
	local i = 1
	for line in file:lines() do
		local x, y, team, hint, data1, data2 = file:read("*number", "*number", "*number", "*number", "*number", "*number")
		gai_configdata[i] = {}
		gai_configdata[i].id = i
		gai_configdata[i].x = x
		gai_configdata[i].y = y
		gai_configdata[i].team = team
		gai_configdata[i].hint = hint
		gai_configdata[i].data1 = data1
		gai_configdata[i].data2 = data2
		if vai_set_debug == 1 then
			print("Data added: "..i, x, y, team, hint, data1, data2)
		end
		i = i + 1
	end
	print("Config file parsed. "..i.." lines.")
	file:close()
end

function fai_config_available()
	if gai_configdata[1] == nil then
		return false
	else
		return true
	end
end

-- returns hint data
function fai_get_config(teamid,hintid)
	if gai_configdata[1] == nil then
		return nil
	end
	
	local validhints = {}
	local i = 1
	
	for k, v in pairs(gai_configdata) do
		if gai_configdata[k].team == teamid and gai_configdata[k].hint == hintid then
			validhints[i] = gai_configdata[k].id
			i = i + 1
		end
	end
	
	if validhints[1] == nil then
		return nil
	end
	
	local r=math.random( #validhints )
	local index=validhints[r]
	return gai_configdata[index].x,gai_configdata[index].y,gai_configdata[index].data1,gai_configdata[index].data2
end