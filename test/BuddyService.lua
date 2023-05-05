

BuddyService = {}


local printFunc = AreaRank.printLocalFunc   

local CUR_VAL = 10 
function BuddyService:createBuddy()
    CUR_VAL = 0 
    self.level = 0 
end 


function  BuddyService:add(val)
    if not self.level then self.level = 0 end 
    self.level = self.level + val
    CUR_VAL = CUR_VAL + val 
end


function  BuddyService:printVal()
    print("BuddyService:printVal = ", self.level)
    print("BuddyService:CUR_VAL = 222", CUR_VAL)
    print("BuddyService:printVal = ", printFunc)
    print("BuddyService:printVal = ", AreaRank.printLocalFunc)

    local func = BuddyService:getClosure()
    local c, d = func()
    print("BuddyService:printVal d= ", c, " d =", d)

    
    printFunc()
    
end

local  c, d = 11, 23 
function  BuddyService:getClosure()
    return function()
        return c,d
    end
end


