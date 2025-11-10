local driverutil={}
function driverutil.getFirst(type)
    if drivers[type] then
        if drivers[type][1] then
            return drivers[type][1]
        end
    end
end

function driverutil.list(type)
    if not type then
        local tmp={}
        for i,v in ipairs(drivers.raw) do
            tmp[#tmp+1] = {type=v.type, obj=v}
        end
        local i=0
        return function()
            i=i+1
            if tmp[i]==nil then return end
            return tmp[i].type, tmp[i].obj
        end
    else
        local tmp={}
        for i,v in ipairs(drivers[type]) do
            tmp[#tmp+1] = {type=v.type, obj=v}
        end
        local i=0
        return function()
            i=i+1
            if tmp[i]==nil then return end
            return tmp[i].type, tmp[i].obj
        end
    end
end

local function runAsKernel(path, ...)
    local func, err = load("return {'e'}", path, "t", _G)
    if not func then return false, "\t"..err end
    local ret = {xpcall(func, debug.traceback, ...)}
    if not ret[1] then
        return false, ret[2]
    end
    return true, table.unpack(ret, 2)
end

runAsKernel(e, driverutil)