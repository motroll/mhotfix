

local  GhostService = {} 

local a,b =10, 4

GhostService.createOne = function(name)
    self.name  = name
end


GhostService.getName = function(name)
    if not  self.name then self.name = "14" end 
    return self.name 
end

GhostService.getValue = function()
    return function()
        return a,b 
    end
end

GhostService.getBValue = function()
    return function()
        return b
    end
end



return GhostService 