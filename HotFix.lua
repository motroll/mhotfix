local HotFix = {}

--[[
    定义独立输出 
]]

LEVEL_ERROR = 1 
LEVEL_DEBUG = 2 
LEVEL_WARM  = 3 
LOG_LEVEL = LEVEL_DEBUG

function ERROR(str)
    if LOG_LEVEL >= LEVEL_ERROR then 
        print("ERROR ", str)
    end 
end

function  DEBUG(str)
    if LOG_LEVEL >= LEVEL_DEBUG then 
        print("DEBUG ", str)
    end     
end

function  WARM(str)
    if LOG_LEVEL >= LEVEL_WARM then 
        print("WARM ", str)
    end     
end

--[[
     设置热更环境 
]]
local realEnv = _ENV 

if not  setfenv then 
    findenv = function(f)
        local level = 1 
        repeat
            local name,  value = debug.getupvalue(f, level)
            if name == "_ENV" then 
                return level, value 
            end   
            level = level + 1  
        until name ==nil 
        return nil 
    end
    getfenv= function(f)
        return (select(2, findenv(f) or _G))
    end

    setfenv = function(f, env)
       -- DEBUG("11111111111")
        local level = findenv(f)
        if level then 
            debug.setupvalue( f, level, env)
        end    
      --  DEBUG("222222222222")
        return f 
    end
end    

function  HotFix:loadFile(file)
    local globaMt = {}
    for k, v  in pairs(_G) do 
        globaMt[k] = v 
    end      
    
end


function HotFix:init() 
    --- 初始化需要用的变量 
    HotFix._LOADED = {}
    HotFix.hotTable = {}

    HotFix.funcTbl = {}
     
   
end     


function HotFix:findLoader(name)
    for _, loader in pairs(package.searchers) do 
        local f, extra = loader(name)
        local fType = type(f)
        if fType == "function" then       
            return f, extra 
        else 
            
        end     
    end     
end     

function HotFix:updateChunk(chunk) 
    DEBUG("HotFix:updateChunk-------")
    for k, v in pairs(chunk) do
        if not _DUMY_TABLE_CACHE[k] then 
            _DUMY_TABLE_CACHE[k] = v 
            DEBUG(string.format("UPDATE  HotFix:updateChunk k= %s", k))
            local typeV = type(v) 
            local oldChunk = rawget(realEnv, k)
            if not oldChunk then 
                rawset(realEnv, k, v) 
            else 
                if typeV == "table" then 
                    HotFix:updateTable(k, oldChunk,v)
                    DEBUG(string.format("UPDATE table = %s", k))
                elseif typeV == "function" then 
                    HotFix.funcTbl[oldChunk] = v  --{ k =k , v =v , f = "updateChunk"}
                    HotFix:updateFunc(k, oldChunk,v)
                    
                    DEBUG(string.format("UPDATE function = %s", k))
                elseif typeV == "userdata" or typeV == "thread" then 
                    DEBUG("not support type-------")       
                end  
            end     
        end    
    end     
end     

function  HotFix:updateModule(mod,oldMod, newMod)

    if type(oldMod) == 'function' then 
       HotFix:updateFunc(mod,oldMod,newMod)
    elseif type(oldMod) == 'table' then    
        HotFix:updateTable(mod,oldMod, newMod) 
    end
    
end


function  HotFix:updateTable(mod,oldTbl, newTbl)
    local typeV 

    if  oldTbl == newTbl then 
        return 
    end     

    local tag = string.format("%s_%s", tostring(oldTbl),tostring(newTbl))
    if HotFix.hotTable[tag] then 
        return 
    end     

    HotFix.hotTable[mod] = true 

    for k, v in pairs(newTbl) do 
        if not oldTbl[k] then 
            rawset(oldTbl,k, v)
        else 
            typeV = type(v)
            if typeV == "table" then 
                DEBUG( string.format("updateTable table mod = %s, k = %s", mod, k))
                HotFix:updateTable(k,oldTbl[k],v)
            elseif typeV == "function" then 
                DEBUG( string.format("updateTable function mod = %s, k = %s", mod, k)) 
                HotFix.funcTbl[oldTbl[k]] ={k = k, v = v, f = "updateTable"}    
                rawset(oldTbl,k, v)
                HotFix:updateFunc(k,oldTbl[k],v)
            elseif typeV == "thread" or typeV == "userdata" then 
                WARM( string.format("updateTable  mod = %s, k = ", mod, k))
            else 
                
            end     
        end     
    end  

    if  newTbl == HotFix.fakeEnv then 
        return 
    end   
    
    local oldMetable = getmetatable(oldTbl)
    local newMetable = getmetatable(newTbl)
    local oldType = type(oldMetable)
    local newType = type(newMetable)
    if oldType == newType and  oldType == "table" then 
        HotFix:updateTable(mod,oldMetable, newMetable)
    end    
end

function  HotFix:updateFunc(mod, oldFunc,newFunc)
    HotFix:updateUpvalue(mod, oldFunc,newFunc) 
    local env = getfenv(oldFunc) or realEnv 
    local f = setfenv( newFunc,env)
    local ret, err = pcall(f)
    -- if err  then 
    --     ERROR(err)
    -- end     
end

function  HotFix:updateUpvalue(mod, oldFunc,newFunc) 
    local i, uvMap = 1, {}
    local  nameMap = {}
    local name, value
    while true do 
        name, value = debug.getupvalue( oldFunc, i)
        if not name  then break end 

        if name ~= "_ENV" then 
            uvMap[name] = {index = i, func = value}
            nameMap[name] = true 
        end     
        
        i = i + 1
    end    


    i =  1 
    local oldValue,oldValueType,newValueType
    while true  do 
        name, value = debug.getupvalue(newFunc, i)
        if not name  then break end 

        if name ~= "_ENV"  and nameMap[name] then 
            oldValue = uvMap[name].func 
            oldValueType = type(oldValue)
            newValueType = type(value)
            if oldValueType ~= newValueType then 
                ERROR( string.format( " updateUpvalue mod = %s, name = %s , oldType = %s, newType", mod, name,oldValueType,newValueType))
                break 
            end     

            if oldValueType == "function" then 
                HotFix.funcTbl[oldValue] = { k = name, v = value, f = "updateUpvalue"} 
                HotFix:updateFunc(mod,oldValue, value)
            elseif oldValueType == "table" then     
                HotFix:updateTable(mod,oldValue, value)
                debug.upvaluejoin(newFunc, i, oldFunc,uvMap[name].index)
            elseif oldValueType == "userdata" or oldValueType == "thread" then 
                
            else 
                debug.upvaluejoin(newFunc, i, oldFunc, uvMap[name].index)
            end

        elseif name ~= "_ENV" then  
            DEBUG(string.format("setupvalue mod = %s, name = %s, index = %d, val" ,mod, name, i)  ) 
            debug.setupvalue(newFunc, i, value )
        end     

        i = i + 1  

    end     
end

_DUMY_TABLE = {
    print = print, 
    require = require,  
    pairs = pairs,    
    table = table,  
    debug = debug  
}

 _DUMY_TABLE_CACHE = {}



function HotFix:makeDumyTable(list)
    local  LOADED = debug.getregistry()._LOADED

    local needLoad = {}
    local dummyTable = {}
    for _, mod in pairs(list) do 
        needLoad[mod] = true 
    end     


    for k, v  in pairs(LOADED) do 
        if not needLoad[k] then 
            dummyTable[k] = v 
        end     
	end 	

    HotFix.fakeEnv = HotFix:newFakeEnv()
    local loader, arg, chunk,  err,ret,fenvFunc 
    for  k, v  in pairs(dummyTable) do 
        loader, arg = HotFix:findLoader(k)
        if loader  then 
            chunk, err = pcall(loadfile, arg, k)
            if not err then 
                fenvFunc = setfenv(loader, HotFix.fakeEnv)
                ret = pcall(fenvFunc)
            end     
        else 
            HotFix.fakeEnv[k] = v     
        end     
    end     
    
end


function  HotFix:newFakeEnv()
    local fakeEnv = {} 
    setmetatable(fakeEnv, {__index = function(t, k)
        
    end})
    for k, v in pairs(_DUMY_TABLE) do 
        fakeEnv[k] = v
    end     
    return fakeEnv
end

function HotFix:copyDumyTable()

    for k, _ in pairs(_DUMY_TABLE_CACHE) do 
        _DUMY_TABLE_CACHE[k] = nil 
    end     

    for k, v in pairs(HotFix.fakeEnv) do 
        _DUMY_TABLE_CACHE[k] = v 
    end     
end     


function  HotFix:checkModule(mod)
 
    DEBUG("HotFix:checkModule-------")
    
    local f,arg = HotFix:findLoader(mod)
    local fenvf = setfenv(f, HotFix.fakeEnv)
  
    local err,newTbl = pcall(fenvf, mod, arg)
    if err then 
        ERROR( string.format("func excute %s error", err)) 
       -- return 
    end  

    --- 如果有返回值,返回是表需要单独更新 
    DEBUG(string.format("HotFix:checkModule-------%s", type(newTbl)))
    local typeP = type(newTbl)  
    if typeP == "table" then 
        local oldTbl = package.loaded[mod]
        HotFix:updateTable(mod,oldTbl,newTbl)
    end     


    --- 更新模块里的变量
   local  func, err = loadfile(arg, "bt", realEnv)
   if err then 
        ERROR( string.format("load file %s error", mod)) 
        return 
    end 
        
   local fenvFunc= setfenv(func, HotFix.fakeEnv)
   local ret,err = pcall(fenvFunc)
   if err  then 
        ERROR(string.format("fakeEnv call func %s error", err))
        --return 
   end  
  
   HotFix._LOADED[mod] = HotFix.fakeEnv 
   HotFix:updateChunk(HotFix.fakeEnv)
end




function HotFix:reloadModule(list)
    HotFix:init()
    HotFix:makeDumyTable(list)
    HotFix:copyDumyTable()
    local f,arg,func, err
    for _, mod in pairs(list) do 
        HotFix:checkModule(mod)
    end     
    HotFix:updateFuncFrame()
end

function  HotFix:printFuncTbl(funTbl)
    DEBUG(string.format("HotFix:printFuncTbl----"))
    for k, v in pairs(funTbl) do 
        DEBUG(string.format(" k = %s, name = %s, v=%s f=%s  ", k,v.k,v.v,v.f))
    end     
end

function  HotFix:updateFuncFrame()

    --local _update_func 
    print("HotFix:updateFuncFrame--11-")
    local root = debug.getregistry()
    local getmetatable = debug.getmetatable 
    local exclude = {} 
    --HotFix:printFuncTbl(HotFix.funcTbl)
    local function _update_func(root, k)
        if exclude[root] then 
            return 
        end     
        local t = type(root)

		if t == "table" then
			exclude[root] = true
			local mt = debug.getmetatable(root)
			if mt then _update_func(mt) end
            for k, v in pairs(root) do   
                if HotFix.funcTbl[v] then 
                    rawset(root,k,HotFix.funcTbl[v].v )
                    _update_func(v, k)
                    print("HotFix:updateFuncFrame k =",k )
                else      
                    _update_func(v, k)
                end  
            end     
		elseif t == "userdata" then
			exclude[root] = true
			local mt = getmetatable(root)
			if mt then _update_func(mt) end
            local uv = debug.getuservalue(root)
            if uv then 
                local tmp = HotFix.funcTbl[uv] 
                if tmp then 
                    debug.setupvalue(root,tmp)
                    _update_func(tmp)
                else 
                    _update_func(uv)
                end     
            end     
		elseif t == "thread" then
			exclude[root] = true
		elseif t == "function" then
			exclude[root] = true
			local i = 1
            while true  do 
        
                local name, val = debug.getupvalue(root,i)
         
                if not name then break end 

                --print(" name = ", name, " val =", val)
                local nv = HotFix.funcTbl[val]

                if name ~= "_ENV" and nv then 
                    debug.setupvalue(root,i,nv.v )
                    _update_func(val)
                elseif type(v) == "table" then     
                    _update_func(val)
                end  
                

                i = i + 1 
            end     
		end
    end    
    
    _update_func(root)
    
end






return HotFix
