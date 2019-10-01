--[[

Chat messages allow players to control bots.
Bots may (randomly) do what they receive via chat.

]]--

function fai_chat(source,message,teamonly)
	local validcall=false
	
	if string.find(message,"bot")~=nil then -- all messages to bots must have the word 'bot'
		validcall=true
	end

	if teamonly == 1 and validcall then -- TEAM messages
		if string.find(message,"come")~=nil and string.find(message,"here")~=nil then
			local mate=fai_randommate(source)
			if mate~=0 then
				vai_mode[mate]=2
				vai_destx[mate]=player(source,"tilex")
				vai_desty[mate]=player(source,"tiley")
				ai_sayteam(mate, "roger that!")
			end
		end
		
		if string.find(message, "build")~=nil then
			local building=-1
			
			if string.find(message, "dispenser")~=nil then
				building=7
			end
			if string.find(message, "supply")~=nil then
				building=9
			end
			if string.find(message, "turret")~=nil then
				building=8
			end
			if string.find(message, "entrance")~=nil then
				building=13
			end
			if string.find(message, "exit")~=nil then
				building=14
			end
			if string.find(message, "wall")~=nil then
				building=5
			end
			if string.find(message, "gate")~=nil then
				building=6
			end
			
			local mate=fai_randommate(source)
			if mate~=0 and building~=-1 then
				vai_mode[mate]=63
				vai_smode[mate]=building
				vai_destx[mate]=player(source,"tilex")+math.random(-1,1)
				vai_desty[mate]=player(source,"tiley")+math.random(-1,1)
				ai_sayteam(mate, "roger that!")
			end
		end
		
		if string.find(message, "defend")~=nil or string.find(message, "camp")~=nil then
			local mate=fai_randommate(source)
			if mate~=0 then
				vai_mode[mate]=9
				vai_smode[mate]=0
				vai_destx[mate]=player(source,"tilex")
				vai_desty[mate]=player(source,"tiley")
				ai_sayteam(mate, "roger that!")
			end			
		end
		
		if string.find(message, "help")~=nil and string.find(message, "upgrade")~=nil then
			local mate=fai_randommate(source)
			if mate~=0 then
				vai_mode[mate]=9
				vai_smode[mate]=1
				vai_destx[mate]=player(source,"tilex")
				vai_desty[mate]=player(source,"tiley")
				ai_sayteam(mate, "roger that!")
			end			
		end
		
		if string.find(message, "use")~=nil or string.find(message, "destroy")~=nil then
			local mate=fai_randommate(source)
			if mate~=0 then
				vai_mode[mate]=9
				vai_smode[mate]=2
				vai_destx[mate]=player(source,"tilex")
				vai_desty[mate]=player(source,"tiley")
				ai_sayteam(mate, "roger that!")
			end			
		end
		
		if string.find(message, "collect")~=nil or string.find(message, "pick")~=nil then
			local mate=fai_randommate(source)
			if mate~=0 then
				vai_mode[mate]=9
				vai_smode[mate]=3
				vai_destx[mate]=player(source,"tilex")
				vai_desty[mate]=player(source,"tiley")
				ai_sayteam(mate, "roger that!")
			end			
		end
	end
end