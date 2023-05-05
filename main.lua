

--print(package.path)


_MODULIST = {}
local HotFix = require("HotFix")

function  loadFiles(files,modules)
    --print("load files =", #files)

    --- 这里将目录 mhotfix\\test 设置为查找目录
    package.path = string.format("%s%s",package.path,";D:\\NewCode\\mhotfix\\test\\?.lua")
    for i, file in pairs(modules) do
       local chunk = require(file)
       
       if chunk then 
            _MODULIST[modules[i]] = chunk 
       else 
            print("require file  ret= ",f)
       end  
    end    
end


function  printModules()
    local loaded = package.loaded 
    for name, _ in pairs(loaded) do
        print("printModules name = ", name)
    end     
end

function  testBeforeUpdate()
    print("testBeforeUpdate ~")
    PlayerService:testBeforeUpdate()
end

function  updateModuleList(files,modules)
    for i, file in pairs(modules) do 
        if _MODULIST[modules[i]] then 
            package.loaded[file] = nil 
            _MODULIST[modules[i]] = file 
        end     
        require(file) 
    end     
end


function updateChunkList(files,modules)
    print("updateChunkList files =", #files)
    local oldName,oldChunk,src,modName 
    HotFix:reloadModule(modules)   
end

function  testAfterUpdate()
    print("testAfterUpdate qqq")
   -- BuddyService:printVal()
    PlayerService:testAfterUpdate()
end