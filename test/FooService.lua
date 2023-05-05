

FooService = FooService or  {}  --tableName = 'pick', age = 20
function FooService:create(o)
    o = o or {} 
    setmetatable(o,self)
    self.__index = self 
    self.name = "cke"
    return o 
end    

function FooService:changeUpdateVal(age)
    self.age  = age
end

function  FooService:printName()
    self.name = "Jack"
    print("FooService:printName name = ",self.name)
    self:changeUpdateVal(100)
    print("FooService:printName age = ",self.age)
	
	print("FooService:printName tableName = ",self.tableName)
end

function  FooService:SetTableName(tableName)
    self.tableName = tableName
    Func[3]("Hello")
end     

