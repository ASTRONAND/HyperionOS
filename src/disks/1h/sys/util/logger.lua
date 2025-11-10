local args={...}
local computer=args[1]
local logs={["nil"]=""}
local hooks={["nil"]=function()end}
local log={api={}}

local function convert_epoch(epoch)
    return computer.date("[%b %d %H:%M:%S]", epoch/1000)
end

function log.getProcess(func)
    if type(func)=="function" then
        log.getProcess=func
    else
        return "Hyprkrnl"
    end
end

function log.api.log(text, logID)
    local appendedText=convert_epoch(computer.time()).." "..log.getProcess()..":[IN] "..text
    logs[tostring(logID)]=logs[tostring(logID)]..appendedText.."\n"
    hooks[tostring(logID)](appendedText)
end

function log.api.warn(text, logID)
    local appendedText=convert_epoch(computer.time()).." "..log.getProcess()..":[WN] "..text
    logs[tostring(logID)]=logs[tostring(logID)]..appendedText.."\n"
    hooks[tostring(logID)](appendedText)
end

function log.api.fail(text, logID)
    local appendedText=convert_epoch(computer.time()).." "..log.getProcess()..":[FA] "..text
    logs[tostring(logID)]=logs[tostring(logID)]..appendedText.."\n"
    hooks[tostring(logID)](appendedText)
end

function log.api.debug(text, logID)
    local appendedText=convert_epoch(computer.time()).." "..log.getProcess()..":[DE] "..text
    logs[tostring(logID)]=logs[tostring(logID)]..appendedText.."\n"
    hooks[tostring(logID)](appendedText)
end

function log.api.error(text, logID)
    local appendedText=convert_epoch(computer.time()).." "..log.getProcess()..":[ER] "..text
    logs[tostring(logID)]=logs[tostring(logID)]..appendedText.."\n"
    hooks[tostring(logID)](appendedText)
end

function log.api.get(logID)
    return logs[tostring(logID)]
end

function log.setHook(func, logID)
    hooks[tostring(logID)]=func
    return {
        removeHook=function()
            hooks[tostring(logID)]=function()end
        end
    }
end

local UUID = 0
function log.api.createLog(logID)
    if logs[tostring(logID)]~=nil then error("cannot create duplicate log") end
    if logID==nil then UUID=UUID+1; logID=UUID end
    hooks[tostring(logID)]=function()end
    logs[tostring(logID)]=""
end

return log