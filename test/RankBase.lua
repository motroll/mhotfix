
 RankBase = RankBase or {} 



local tbl_sort = table.sort 

function RankBase:create(o)
	o = o or {} 
	self.__index = self 
	setmetatable(o,self)
	return o 
end

function RankBase:sort(tbl)
	tbl_sort(tbl)
end 


function RankBase:printScore()
	local scoreList = self.scoreList or { 99, 88, 10, 31,49,19 }
	self:sort(scoreList)
	for _, v in pairs(scoreList) do 
		print(" v = ", v)
	end 
	print("RankBase:printScore 11")
	print("RankBase:printScore 27")
end 

