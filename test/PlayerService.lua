

PlayerService = PlayerService or {} 


local a = 10 
local tbl = {x = 10, y = 11,z= a, name = "nick"}


function  foo(k)
  	function V ()
		a = a + k 
		return a 
	end 
	return V()
end

local function  HelloWorld()
	print("hello world~")
end

function PlayerService:loginIn()

	self.is_login = true 
	self.login_time = os.time()
	print("PlayerService:loginIn 2")
end 


function PlayerService:testBeforeUpdate()
	BuddyService:add(10)
	BuddyService:printVal()
end

function PlayerService:testAfterUpdate()
	BuddyService:add(10)
	BuddyService:printVal()

end

function PlayerService:startFight()
	print("player is in fight ")
	local senceId = SenceService:GetSceneId()
	if senceId == 0 then 
	end 
	
	print("player start fight 2")
	FightService:calDamage()
end 

function PlayerService:loginOut()
	self.is_login = false  
	print("PlayerService:loginOut ")
end 

function PlayerService:changePlayerName(name)
	self.nam = name 
	a = 12 
end  

Func = {}
Func[1] = PlayerService.loginIn
Func[2] = PlayerService.loginOut
Func[3] = PlayerService.changePlayerName

function  PlayerService:think()
	print("PlayerService:think 111")
	self:changePlayerName("pick")
	self:startFight()
	
end

function  PlayerService:test()
	print("PlayerService:test 111")
	print("PlayerService:test 223")
end

function  PlayerService:show()
	print("PlayerService:show ", foo(1))
end

function  PlayerService:Speak()
	print("PlayerService:show ", foo(1))
end

--PlayerService:startFight()