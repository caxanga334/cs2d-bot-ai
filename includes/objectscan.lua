-- object scan

function fai_scanforobject(id)

	-- Scan Timer
	vai_objectscan[id]=vai_objectscan[id]+-1
	if vai_objectscan[id]<=0 then
		vai_objectscan[id]=math.random(500,700)
		
	
	end
end