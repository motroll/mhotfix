

 AreaRank = AreaRank or  {}

 local GhostService = require("GhostService")
 

function AreaRank:create()
	local o = RankBase:create(AreaRank)
	return o 
end  


function AreaRank:showScore()
	print("AreaRank:showScore 22")
    self.scoreList = {11, 82, 23, 16,76}
	self:printScore()
end 

function AreaRank:printLocalFunc()
	print("AreaRank:printLocalFunc 222")
	local  func = GhostService.getValue()
	local  a,b = func()
	print("AreaRank:printLocalFunc a = ", a," b = ", b)
end




