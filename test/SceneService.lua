
SenceService = SenceService or {} 

function SenceService:GetSceneId()
	self.sence_id = self.sence_id or 0 
	return self.sence_id
end 

function SenceService:moveScene(scene_id)
	self.sence_id = scene_id
end 


function SenceService:initJiuGongGe(scene_id)
	self.gridList = {}
	self.moveScene(scene_id)
end 