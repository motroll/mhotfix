


FightService = FightService or {} 



local  function  addDamage(tbl)
	print("addDamage ", tostring(tbl))
	for fld, v in pairs(tbl) do 
		if fld == "evade" then 
		else 
			tbl[fld] = tbl[fld] +1 
		end 		
	end 	
end 

function FightService:create()
	self.fight_group_list = {} 
	self.battle_group_num = 0 

	print("初始化了战斗服务~~~1")
end 

function  FightService:startBattle(index)
	
	local randA = math.random(10, 1000)
	local randB = math.random(10, 1000)

	local fightGroup = self.fight_group_list[index]
	fightGroup.roundNum = fightGroup.roundNum + 1 
	--print(index,"组进入战斗回合",fightGroup.roundNum )
	local lastScore =  fightGroup.player_list[1].battleScore 
	fightGroup.player_list[1].battleScore = lastScore + randA 
	lastScore = fightGroup.player_list[2].battleScore 
	fightGroup.player_list[2].battleScore = lastScore + randB

	if fightGroup.player_list[1].battleScore < fightGroup.player_list[2].battleScore then 
		print("战斗回合 ",fightGroup.player_list[1].name, " 胜")
	elseif fightGroup.player_list[1].battleScore > fightGroup.player_list[2].battleScore then
		print("战斗回合 ",fightGroup.player_list[2].name, " 胜")
	else
		print("战斗回合 ",fightGroup.player_list[1].name, " 和 ", fightGroup.player_list[2].name, " 平手")
	end 	
	self.fight_group_list[index] = fightGroup
	

end

function FightService:addOneBattle(batleName,defenceName)
	self.battle_group_num = self.battle_group_num + 1 
	
	index = self.battle_group_num
	self.fight_group_list[index] = {
		start_battle_time = os.time(),
		player_list = {
			[1] = {name = batleName,battleScore=0, roundNum = 0 },
			[2] = {name = defenceName,battleScore=0,roundNum = 0}
		}
		
	}
end 


function FightService:battleNum()
	print("当前产生了 ",  self.battle_group_num ,"组战斗")
	local foo = FooService:create()
	foo:printName()


	local curTime = os.time()
	--print("当前产生了 ",  self.battle_group_num ,"组战斗")
	for index, battle in pairs(self.fight_group_list) do
		playerList = battle.player_list

		--print("第 ", index , "组战斗开始时间:",battle.start_battle_time)
		if curTime - battle.start_battle_time > 3000 then 
		--	print("结束战斗 ",playerList[1].name )
			self.fight_group_list[index] = nil 
		else 
			self:startBattle(index)		
		end 
	
	end 
end 

function FightService:calDamage()
	local minTbl = {health = 10, physical = 12, evade=10}
	local areaRank = AreaRank:create()
	areaRank:showScore()
end 
